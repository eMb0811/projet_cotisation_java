package sn.ucad.cotisations.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import sn.ucad.cotisations.dao.EmailLogDao;
import sn.ucad.cotisations.model.Membre;
import sn.ucad.cotisations.model.RoleEnum;
import sn.ucad.cotisations.model.Utilisateur;
import sn.ucad.cotisations.service.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Servlet du tableau de bord : agrège les KPIs et l'activité récente.
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final MembreService      membreService      = new MembreService();
    private final CotisationService  cotisationService  = new CotisationService();
    private final AmendeService      amendeService      = new AmendeService();
    private final EmailLogDao        emailLogDao        = new EmailLogDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!AuthService.isAdmin(session)) {
            // Les membres n'ont pas besoin de tableau de bord -> redirection vers leurs cotisations
            resp.sendRedirect(req.getContextPath() + "/cotisations");
            return;
        }

        // KPIs Administrateur
        req.setAttribute("nbMembresActifs",       membreService.countMembresActifs());
        req.setAttribute("totalCotisationsPayees", cotisationService.getTotalCotisationsPayees());
        req.setAttribute("totalAmendesImpayees",   amendeService.getTotalAmendesImpayees());
        req.setAttribute("nbCotisationsEnRetard",  cotisationService.countEnRetard());
        req.setAttribute("nbAmendesImpayees",      amendeService.countAmendesImpayees());
        req.setAttribute("devise",                 sn.ucad.cotisations.config.AppConfig.getInstance().getDevise());

        // Données récentes complètes
        req.setAttribute("cotisationsRecentes",
            cotisationService.getAllCotisations().stream().limit(10).toList());
        req.setAttribute("amendesRecentes",
            amendeService.getAllAmendes().stream().limit(5).toList());
        req.setAttribute("emailsRecents",
            emailLogDao.findRecentWithLimit(5));

        req.getRequestDispatcher("/WEB-INF/views/dashboard/index.jsp").forward(req, resp);
    }
}
