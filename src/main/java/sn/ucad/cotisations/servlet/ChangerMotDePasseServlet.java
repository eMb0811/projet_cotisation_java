package sn.ucad.cotisations.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import sn.ucad.cotisations.model.Utilisateur;
import sn.ucad.cotisations.service.AuthService;
import sn.ucad.cotisations.service.MembreService;

import java.io.IOException;
import java.util.Optional;

/**
 * Servlet dédiée au changement initial ou renouvellement de mot de passe.
 * Accessible publiquement sur /changer-mot-de-passe via le lien reçu par e-mail.
 */
@WebServlet(name = "ChangerMotDePasseServlet", urlPatterns = {"/changer-mot-de-passe"})
public class ChangerMotDePasseServlet extends HttpServlet {

    private final MembreService membreService = new MembreService();
    private final AuthService   authService   = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        req.setAttribute("email", email != null ? email.trim() : "");
        req.getRequestDispatcher("/WEB-INF/views/auth/changer-mot-de-passe.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email       = req.getParameter("email");
        String ancien      = req.getParameter("ancienPassword");
        String nouveau     = req.getParameter("nouveauPassword");
        String confirm     = req.getParameter("confirmPassword");

        if (email == null || email.isBlank() || ancien == null || nouveau == null || confirm == null) {
            req.setAttribute("error", "Tous les champs sont obligatoires.");
            req.setAttribute("email", email != null ? email : "");
            req.getRequestDispatcher("/WEB-INF/views/auth/changer-mot-de-passe.jsp").forward(req, resp);
            return;
        }

        if (!nouveau.equals(confirm)) {
            req.setAttribute("error", "Le nouveau mot de passe et sa confirmation ne sont pas identiques.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/changer-mot-de-passe.jsp").forward(req, resp);
            return;
        }

        if (nouveau.length() < 6) {
            req.setAttribute("error", "Le nouveau mot de passe doit comporter au moins 6 caractères.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/changer-mot-de-passe.jsp").forward(req, resp);
            return;
        }

        try {
            membreService.changerMotDePasse(email.trim(), ancien, nouveau);

            // Connexion automatique directe pour une expérience fluide
            HttpSession session = req.getSession(true);
            Optional<Utilisateur> optUser = authService.login(email.trim(), nouveau, session);

            if (optUser.isPresent()) {
                req.getSession().setAttribute("successMsg", "Mot de passe personnalisé avec succès ! Bienvenue dans votre espace.");
                resp.sendRedirect(req.getContextPath() + "/cotisations");
            } else {
                req.getSession().setAttribute("successMsg", "Mot de passe modifié avec succès ! Connectez-vous avec vos nouveaux identifiants.");
                resp.sendRedirect(req.getContextPath() + "/login");
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/changer-mot-de-passe.jsp").forward(req, resp);
        }
    }
}
