package sn.ucad.cotisations.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import sn.ucad.cotisations.model.*;
import sn.ucad.cotisations.service.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * Servlet de gestion des membres (CRUD complet).
 * Routes :
 *   GET  /membres              → liste
 *   GET  /membres?action=detail&id=X     → fiche membre
 *   GET  /membres?action=nouveau         → formulaire création
 *   POST /membres?action=creer           → crée un membre
 *   GET  /membres?action=modifier&id=X   → formulaire modification
 *   POST /membres?action=modifier&id=X   → enregistre la modification
 *   POST /membres?action=desactiver&id=X → désactive
 */
@WebServlet(name = "MembreServlet", urlPatterns = {"/membres"})
public class MembreServlet extends HttpServlet {

    private final MembreService membreService = new MembreService();
    private final ExcelService  excelService  = new ExcelService();
    private final EmailService  emailService  = new EmailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) action = "liste";

        switch (action) {
            case "detail" -> showDetail(req, resp);
            case "nouveau" -> showForm(req, resp, null);
            case "modifier" -> {
                Long id = parseLong(req.getParameter("id"));
                if (id == null) { resp.sendRedirect(req.getContextPath() + "/membres"); return; }
                var opt = membreService.getMembreById(id);
                opt.ifPresentOrElse(
                    m -> { try { showForm(req, resp, m); } catch (Exception e) { throw new RuntimeException(e); } },
                    () -> { try { resp.sendRedirect(req.getContextPath() + "/membres"); } catch (IOException e) { throw new RuntimeException(e); } }
                );
            }
            case "excel" -> exportExcel(req, resp);
            default -> showListe(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) action = "liste";

        switch (action) {
            case "creer"      -> doCreate(req, resp);
            case "modifier"   -> doUpdate(req, resp);
            case "desactiver" -> doDeactivate(req, resp);
            case "supprimer"  -> doSupprimer(req, resp);
            default           -> resp.sendRedirect(req.getContextPath() + "/membres");
        }
    }

    private void showListe(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Admin : tous les membres. Membre : seulement lui-même
        List<Membre> membres;
        if (AuthService.isAdmin(req.getSession(false))) {
            membres = membreService.getAllMembres();
        } else {
            Membre m = AuthService.getCurrentMembre(req.getSession(false));
            membres = m != null ? List.of(m) : List.of();
        }
        req.setAttribute("membres", membres);
        req.getRequestDispatcher("/WEB-INF/views/membres/liste.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long id = parseLong(req.getParameter("id"));
        if (id == null) { resp.sendRedirect(req.getContextPath() + "/membres"); return; }

        // Membres non-admin ne peuvent voir que leur propre fiche
        if (!AuthService.isAdmin(req.getSession(false))) {
            Membre current = AuthService.getCurrentMembre(req.getSession(false));
            if (current == null || !current.getId().equals(id)) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
        }

        membreService.getMembreById(id).ifPresentOrElse(
            m -> {
                try {
                    req.setAttribute("membre", m);
                    req.getRequestDispatcher("/WEB-INF/views/membres/detail.jsp").forward(req, resp);
                } catch (Exception e) { throw new RuntimeException(e); }
            },
            () -> {
                try { resp.sendRedirect(req.getContextPath() + "/membres"); }
                catch (IOException e) { throw new RuntimeException(e); }
            }
        );
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, Membre membre)
            throws ServletException, IOException {
        req.setAttribute("membre", membre);
        req.setAttribute("statuts", StatutMembre.values());
        req.getRequestDispatcher("/WEB-INF/views/membres/formulaire.jsp").forward(req, resp);
    }

    private void doCreate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Réservé admin
        if (!AuthService.isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        try {
            String email     = req.getParameter("email");
            String password  = req.getParameter("password");
            String nom       = req.getParameter("nom");
            String prenom    = req.getParameter("prenom");
            String telephone = req.getParameter("telephone");
            String dateStr   = req.getParameter("dateAdhesion");
            LocalDate dateAdhesion = (dateStr != null && !dateStr.isBlank())
                    ? LocalDate.parse(dateStr) : LocalDate.now();

            Membre nouveauMembre = membreService.createMembre(email, password, nom, prenom, telephone, dateAdhesion);

            // Construction de l'URL absolue pour changer le mot de passe
            String scheme = req.getScheme();
            String serverName = req.getServerName();
            int serverPort = req.getServerPort();
            String contextPath = req.getContextPath();
            String portStr = ((scheme.equals("http") && serverPort == 80) || (scheme.equals("https") && serverPort == 443)) ? "" : (":" + serverPort);
            String changePasswordUrl = scheme + "://" + serverName + portStr + contextPath + "/changer-mot-de-passe?email=" + java.net.URLEncoder.encode(email, java.nio.charset.StandardCharsets.UTF_8);

            try {
                emailService.sendBienvenueNouveauMembre(nouveauMembre, password, changePasswordUrl);
            } catch (Exception eMailEx) {
                // Non bloquant si SMTP non configuré
            }

            req.getSession().setAttribute("successMsg", "Membre créé avec succès ! Un e-mail contenant ses identifiants et le lien de modification lui a été envoyé.");
            resp.sendRedirect(req.getContextPath() + "/membres");
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("statuts", StatutMembre.values());
            req.getRequestDispatcher("/WEB-INF/views/membres/formulaire.jsp").forward(req, resp);
        }
    }

    private void doUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!AuthService.isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        Long id = parseLong(req.getParameter("id"));
        if (id == null) { resp.sendRedirect(req.getContextPath() + "/membres"); return; }

        try {
            String nom       = req.getParameter("nom");
            String prenom    = req.getParameter("prenom");
            String telephone = req.getParameter("telephone");
            String statutStr = req.getParameter("statut");
            StatutMembre statut = statutStr != null ? StatutMembre.valueOf(statutStr) : StatutMembre.ACTIF;

            membreService.updateMembre(id, nom, prenom, telephone, statut);
            req.getSession().setAttribute("successMsg", "Membre mis à jour !");
            resp.sendRedirect(req.getContextPath() + "/membres");
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("statuts", StatutMembre.values());
            req.getRequestDispatcher("/WEB-INF/views/membres/formulaire.jsp").forward(req, resp);
        }
    }

    private void doDeactivate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!AuthService.isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        Long id = parseLong(req.getParameter("id"));
        if (id != null) {
            try { membreService.deactivateMembre(id); }
            catch (Exception e) { req.getSession().setAttribute("errorMsg", e.getMessage()); }
        }
        resp.sendRedirect(req.getContextPath() + "/membres");
    }

    private void doSupprimer(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!AuthService.isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        Long id = parseLong(req.getParameter("id"));
        if (id != null) {
            try {
                membreService.deleteMembre(id);
                req.getSession().setAttribute("successMsg", "Le membre et toutes ses données associées ont été définitivement supprimés de la base de données.");
            } catch (Exception e) {
                req.getSession().setAttribute("errorMsg", "Erreur suppression : " + e.getMessage());
            }
        }
        resp.sendRedirect(req.getContextPath() + "/membres");
    }

    private void exportExcel(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!AuthService.isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        byte[] data = excelService.exportMembres(membreService.getAllMembres());
        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=\"membres_ucad.xlsx\"");
        resp.getOutputStream().write(data);
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Long.parseLong(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }
}
