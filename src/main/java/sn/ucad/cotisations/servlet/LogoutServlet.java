package sn.ucad.cotisations.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import sn.ucad.cotisations.service.AuthService;

import java.io.IOException;

/**
 * Servlet de déconnexion : invalide la session et redirige vers /login.
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        authService.logout(req.getSession(false));
        resp.sendRedirect(req.getContextPath() + "/login?msg=deconnecte");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doGet(req, resp);
    }
}
