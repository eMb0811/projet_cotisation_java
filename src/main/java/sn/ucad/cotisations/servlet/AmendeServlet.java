package sn.ucad.cotisations.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import sn.ucad.cotisations.model.*;
import sn.ucad.cotisations.service.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Servlet de gestion des amendes.
 * Routes :
 *   GET  /amendes                       → liste
 *   GET  /amendes?action=payer&id=X     → formulaire paiement
 *   POST /amendes?action=payer&id=X     → enregistre paiement
 *   POST /amendes?action=creer          → création manuelle (ADMIN)
 */
@WebServlet(name = "AmendeServlet", urlPatterns = {"/amendes"})
public class AmendeServlet extends HttpServlet {

    private final AmendeService  amendeService  = new AmendeService();
    private final EmailService   emailService   = new EmailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "liste";

        switch (action) {
            case "payer" -> showPaiement(req, resp);
            default      -> showListe(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "liste";

        switch (action) {
            case "payer"  -> doPayer(req, resp);
            case "creer"  -> doCreate(req, resp);
            default       -> resp.sendRedirect(req.getContextPath() + "/amendes");
        }
    }

    private void showListe(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Amende> amendes;
        if (AuthService.isAdmin(req.getSession(false))) {
            amendes = amendeService.getAllAmendes();
        } else {
            Membre m = AuthService.getCurrentMembre(req.getSession(false));
            amendes = m != null ? amendeService.getAmendesByMembre(m.getId()) : List.of();
        }
        req.setAttribute("amendes", amendes);
        req.setAttribute("devise", sn.ucad.cotisations.config.AppConfig.getInstance().getDevise());
        req.setAttribute("moyens", MoyenPaiement.values());
        req.getRequestDispatcher("/WEB-INF/views/amendes/liste.jsp").forward(req, resp);
    }

    private void showPaiement(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long id = parseLong(req.getParameter("id"));
        if (id == null) { resp.sendRedirect(req.getContextPath() + "/amendes"); return; }
        amendeService.getAmendeById(id).ifPresentOrElse(
            a -> {
                try {
                    req.setAttribute("amende", a);
                    req.setAttribute("moyens", MoyenPaiement.values());
                    req.getRequestDispatcher("/WEB-INF/views/amendes/paiement.jsp").forward(req, resp);
                } catch (Exception e) { throw new RuntimeException(e); }
            },
            () -> { try { resp.sendRedirect(req.getContextPath() + "/amendes"); } catch (IOException e) { throw new RuntimeException(e); } }
        );
    }

    private void doPayer(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Long id = parseLong(req.getParameter("id"));
        if (id == null) { resp.sendRedirect(req.getContextPath() + "/amendes"); return; }
        try {
            String moyenStr  = req.getParameter("moyenPaiement");
            String reference = req.getParameter("referencePaiement");
            MoyenPaiement moyen = moyenStr != null ? MoyenPaiement.valueOf(moyenStr) : MoyenPaiement.ESPECES;
            amendeService.payerAmende(id, moyen, reference);
            req.getSession().setAttribute("successMsg", "Amende réglée avec succès !");
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Erreur : " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/amendes");
    }

    private void doCreate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!AuthService.isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        try {
            Long membreId = parseLong(req.getParameter("membreId"));
            String motif  = req.getParameter("motif");
            String montantStr = req.getParameter("montant");
            BigDecimal montant = (montantStr != null && !montantStr.isBlank())
                    ? new BigDecimal(montantStr) : null;

            amendeService.createAmende(membreId, motif, montant);
            req.getSession().setAttribute("successMsg", "Amende créée avec succès !");
        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Erreur création amende : " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/amendes");
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Long.parseLong(s.trim()); } catch (NumberFormatException e) { return null; }
    }
}
