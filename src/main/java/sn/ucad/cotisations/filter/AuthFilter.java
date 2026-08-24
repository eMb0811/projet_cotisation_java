package sn.ucad.cotisations.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import sn.ucad.cotisations.service.AuthService;

import java.io.IOException;

/**
 * Filtre de sécurité : redirige les requêtes non authentifiées vers /login.
 * Laisse passer : /login, /logout, les ressources statiques.
 */
@WebFilter(urlPatterns = "/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();
        String ctx  = req.getContextPath();

        // Chemins publics (pas d'auth requise)
        boolean isPublic = path.equals("/login")
                || path.equals("/logout")
                || path.equals("/changer-mot-de-passe")
                || path.startsWith("/static/")
                || path.startsWith("/assets/")
                || path.endsWith(".css")
                || path.endsWith(".js")
                || path.endsWith(".ico")
                || path.endsWith(".png")
                || path.endsWith(".jpg");

        if (isPublic) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        if (AuthService.isAuthenticated(session)) {
            chain.doFilter(request, response);
        } else {
            resp.sendRedirect(ctx + "/login");
        }
    }
}
