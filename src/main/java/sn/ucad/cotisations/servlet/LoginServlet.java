package sn.ucad.cotisations.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import sn.ucad.cotisations.model.Utilisateur;
import sn.ucad.cotisations.service.AuthService;

import java.io.IOException;

/**
 * Servlet de connexion : GET affiche le formulaire, POST traite l'authentification.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Si déjà connecté → dashboard pour ADMIN, cotisations pour MEMBRE
        HttpSession session = req.getSession(false);
        if (AuthService.isAuthenticated(session)) {
            if (AuthService.isAdmin(session)) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/cotisations");
            }
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Veuillez saisir votre e-mail et votre mot de passe.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        var optUser = authService.login(email.trim(), password, session);

        if (optUser.isPresent()) {
            Utilisateur user = optUser.get();
            if (sn.ucad.cotisations.model.RoleEnum.ADMIN.equals(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/cotisations");
            }
        } else {
            session.invalidate();
            req.setAttribute("error", "Email ou mot de passe incorrect.");
            req.setAttribute("emailSaisi", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }
}
