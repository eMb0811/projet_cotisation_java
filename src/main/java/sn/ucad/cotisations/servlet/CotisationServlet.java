package sn.ucad.cotisations.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import sn.ucad.cotisations.model.*;
import sn.ucad.cotisations.service.*;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Servlet de gestion des cotisations.
 * Routes :
 *   GET  /cotisations                          → liste (tous ou les siennes)
 *   GET  /cotisations?action=periode&mois=X&annee=Y → rapport par période
 *   POST /cotisations?action=generer           → génération mensuelle (ADMIN)
 *   POST /cotisations?action=payer&id=X        → enregistrement paiement
 *   POST /cotisations?action=retards           → détection retards (ADMIN)
 *   GET  /cotisations?action=pdf&id=X          → reçu PDF
 *   GET  /cotisations?action=excel             → export Excel (ADMIN)
 */
@WebServlet(name = "CotisationServlet", urlPatterns = {"/cotisations"})
public class CotisationServlet extends HttpServlet {

    private final CotisationService cotisationService = new CotisationService();
    private final EmailService      emailService      = new EmailService();
    private final PdfService        pdfService        = new PdfService();
    private final ExcelService      excelService      = new ExcelService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "liste";

        switch (action) {
            case "periode" -> showPeriode(req, resp);
            case "pdf"     -> downloadPdf(req, resp);
            case "excel"   -> downloadExcel(req, resp);
            case "payer"   -> showPaiement(req, resp);
            default        -> showListe(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "liste";

        switch (action) {
            case "generer"  -> doGenerer(req, resp);
            case "payer"    -> doPayer(req, resp);
            case "retards"  -> doTraiterRetards(req, resp);
            default         -> resp.sendRedirect(req.getContextPath() + "/cotisations");
        }
    }

    private void showListe(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Cotisation> cotisations;
        boolean isAdmin = AuthService.isAdmin(req.getSession(false));
        String filtre = req.getParameter("filtre");
        boolean isFiltreMoi = "moi".equalsIgnoreCase(filtre);

        if (isAdmin && !isFiltreMoi) {
            cotisations = cotisationService.getAllCotisations();
        } else {
            Membre m = AuthService.getCurrentMembre(req.getSession(false));
            cotisations = m != null ? cotisationService.getCotisationsByMembre(m.getId()) : List.of();
        }
        req.setAttribute("cotisations", cotisations);
        req.setAttribute("filtreMoi", isFiltreMoi);
        req.setAttribute("montantDefaut", sn.ucad.cotisations.config.AppConfig.getInstance().getCotisationMontantDefaut());
        req.setAttribute("devise", sn.ucad.cotisations.config.AppConfig.getInstance().getDevise());
        req.setAttribute("moyens", MoyenPaiement.values());
        req.getRequestDispatcher("/WEB-INF/views/cotisations/liste.jsp").forward(req, resp);
    }

    private void showPeriode(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int mois  = parseIntOrDefault(req.getParameter("mois"),  LocalDate.now().getMonthValue());
        int annee = parseIntOrDefault(req.getParameter("annee"), LocalDate.now().getYear());
        List<Cotisation> cotisations = cotisationService.getCotisationsByPeriode(annee, mois);
        req.setAttribute("cotisations", cotisations);
        req.setAttribute("mois",  mois);
        req.setAttribute("annee", annee);
        req.setAttribute("montantDefaut", sn.ucad.cotisations.config.AppConfig.getInstance().getCotisationMontantDefaut());
        req.setAttribute("devise", sn.ucad.cotisations.config.AppConfig.getInstance().getDevise());
        req.setAttribute("moyens", MoyenPaiement.values());
        req.getRequestDispatcher("/WEB-INF/views/cotisations/liste.jsp").forward(req, resp);
    }

    private void showPaiement(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long id = parseLong(req.getParameter("id"));
        if (id == null) { resp.sendRedirect(req.getContextPath() + "/cotisations"); return; }
        cotisationService.getCotisationById(id).ifPresentOrElse(
            c -> {
                try {
                    req.setAttribute("cotisation", c);
                    req.setAttribute("moyens", MoyenPaiement.values());
                    req.getRequestDispatcher("/WEB-INF/views/cotisations/paiement.jsp").forward(req, resp);
                } catch (Exception e) { throw new RuntimeException(e); }
            },
            () -> { try { resp.sendRedirect(req.getContextPath() + "/cotisations"); } catch (IOException e) { throw new RuntimeException(e); } }
        );
    }

    private void doGenerer(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!AuthService.isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/cotisations");
            return;
        }
        int mois  = parseIntOrDefault(req.getParameter("mois"),  LocalDate.now().getMonthValue());
        int annee = parseIntOrDefault(req.getParameter("annee"), LocalDate.now().getYear());
        String montantStr = req.getParameter("montant");
        java.math.BigDecimal montant = null;
        if (montantStr != null && !montantStr.isBlank()) {
            try {
                montant = new java.math.BigDecimal(montantStr.trim().replace(",", "."));
            } catch (Exception ignored) {}
        }

        try {
            int nb = cotisationService.genererCotisationsMensuelles(annee, mois, montant);
            req.getSession().setAttribute("successMsg", nb + " cotisation(s) générée(s) pour " + mois + "/" + annee + (montant != null ? " (" + montant + " FCFA)" : ""));
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Erreur génération : " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/cotisations");
    }

    private void doPayer(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Long id = parseLong(req.getParameter("id"));
        if (id == null) { resp.sendRedirect(req.getContextPath() + "/cotisations"); return; }
        try {
            String moyenStr  = req.getParameter("moyenPaiement");
            String reference = req.getParameter("referencePaiement");
            MoyenPaiement moyen = moyenStr != null ? MoyenPaiement.valueOf(moyenStr) : MoyenPaiement.ESPECES;
            Cotisation c = cotisationService.payerCotisation(id, moyen, reference);

            // Envoi e-mail de confirmation
            try { emailService.sendConfirmationPaiement(c.getMembre(), c); }
            catch (Exception ignored) { }

            req.getSession().setAttribute("successMsg", "Paiement enregistré avec succès !");
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Erreur paiement : " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/cotisations");
    }

    private void doTraiterRetards(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!AuthService.isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        int mois  = parseIntOrDefault(req.getParameter("mois"),  LocalDate.now().getMonthValue() - 1);
        int annee = parseIntOrDefault(req.getParameter("annee"), LocalDate.now().getYear());
        try {
            int nb = cotisationService.detecterEtTraiterRetards(annee, mois);
            req.getSession().setAttribute("successMsg", nb + " retard(s) traité(s) et amende(s) générée(s).");
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Erreur traitement retards : " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/cotisations");
    }

    private void downloadPdf(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Long id = parseLong(req.getParameter("id"));
        if (id == null) { resp.sendRedirect(req.getContextPath() + "/cotisations"); return; }
        var opt = cotisationService.getCotisationById(id);
        if (opt.isEmpty()) { resp.sendRedirect(req.getContextPath() + "/cotisations"); return; }

        Cotisation c = opt.get();
        byte[] pdf = pdfService.generateRecuCotisation(c);
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", "inline; filename=\"recu_cotisation_" + id + ".pdf\"");
        resp.getOutputStream().write(pdf);
    }

    private void downloadExcel(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!AuthService.isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        byte[] data = excelService.exportCotisations(cotisationService.getAllCotisations());
        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=\"cotisations_ucad.xlsx\"");
        resp.getOutputStream().write(data);
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Long.parseLong(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    private int parseIntOrDefault(String s, int def) {
        if (s == null || s.isBlank()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }
}
