package sn.ucad.cotisations.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import sn.ucad.cotisations.model.Membre;
import sn.ucad.cotisations.model.Utilisateur;
import sn.ucad.cotisations.service.AuthService;
import sn.ucad.cotisations.service.MembreService;

import java.io.IOException;

/**
 * Servlet de gestion du profil utilisateur et du changement de mot de passe.
 * Accessible aux Administrateurs et aux Membres sur /profil.
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profil"})
public class ProfileServlet extends HttpServlet {

    private final MembreService membreService = new MembreService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Utilisateur user = AuthService.getCurrentUser(session);
        Membre membre = AuthService.getCurrentMembre(session);

        req.setAttribute("user", user);
        req.setAttribute("membre", membre);
        req.getRequestDispatcher("/WEB-INF/views/profile/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Utilisateur user = AuthService.getCurrentUser(session);
        Membre membre = AuthService.getCurrentMembre(session);
        String action = req.getParameter("action");

        if ("update-infos".equals(action)) {
            if (membre != null) {
                try {
                    String nom = req.getParameter("nom");
                    String prenom = req.getParameter("prenom");
                    String telephone = req.getParameter("telephone");

                    Membre updated = membreService.updateMembre(membre.getId(), nom, prenom, telephone, membre.getStatut());
                    session.setAttribute(AuthService.SESSION_MEMBRE, updated);
                    req.getSession().setAttribute("successMsg", "Vos informations personnelles ont été mises à jour avec succès !");
                } catch (Exception e) {
                    req.getSession().setAttribute("errorMsg", "Erreur lors de la mise à jour : " + e.getMessage());
                }
            }
            resp.sendRedirect(req.getContextPath() + "/profil");
            return;
        }

        if ("update-password".equals(action)) {
            String ancien = req.getParameter("ancienPassword");
            String nouveau = req.getParameter("nouveauPassword");
            String confirm = req.getParameter("confirmPassword");

            if (nouveau == null || !nouveau.equals(confirm)) {
                req.getSession().setAttribute("errorMsg", "Le nouveau mot de passe et sa confirmation ne correspondent pas.");
                resp.sendRedirect(req.getContextPath() + "/profil");
                return;
            }

            try {
                membreService.updateMotDePasse(user.getId(), ancien, nouveau);
                req.getSession().setAttribute("successMsg", "Votre mot de passe a été modifié avec succès !");
            } catch (Exception e) {
                req.getSession().setAttribute("errorMsg", "Erreur mot de passe : " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/profil");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/profil");
    }
}
