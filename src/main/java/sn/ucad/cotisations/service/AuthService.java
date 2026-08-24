package sn.ucad.cotisations.service;

import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;
import sn.ucad.cotisations.dao.MembreDao;
import sn.ucad.cotisations.dao.UtilisateurDao;
import sn.ucad.cotisations.model.Membre;
import sn.ucad.cotisations.model.RoleEnum;
import sn.ucad.cotisations.model.Utilisateur;

import java.util.Optional;
import java.util.logging.Logger;

/**
 * Service d'authentification : login, logout, gestion de session.
 */
public class AuthService {

    private static final Logger LOGGER = Logger.getLogger(AuthService.class.getName());
    public static final String SESSION_USER     = "sessionUser";
    public static final String SESSION_MEMBRE   = "sessionMembre";
    public static final String SESSION_ROLE     = "sessionRole";

    private final UtilisateurDao utilisateurDao = new UtilisateurDao();
    private final MembreDao membreDao = new MembreDao();

    /**
     * Tente d'authentifier un utilisateur.
     * @return l'utilisateur si les credentials sont valides, Optional.empty() sinon.
     */
    public Optional<Utilisateur> login(String email, String motDePasse, HttpSession session) {
        if (email == null || motDePasse == null || email.isBlank()) {
            return Optional.empty();
        }

        Optional<Utilisateur> opt = utilisateurDao.findByEmail(email.trim().toLowerCase());
        if (opt.isEmpty()) {
            LOGGER.warning("Tentative de connexion avec email inconnu : " + email);
            return Optional.empty();
        }

        Utilisateur user = opt.get();
        if (!user.getActif()) {
            LOGGER.warning("Tentative de connexion sur compte inactif : " + email);
            return Optional.empty();
        }

        if (!BCrypt.checkpw(motDePasse, user.getMotDePasseHash())) {
            LOGGER.warning("Mot de passe incorrect pour : " + email);
            return Optional.empty();
        }

        // Créer la session
        session.setAttribute(SESSION_USER, user);
        session.setAttribute(SESSION_ROLE, user.getRole().name());

        // Charger le profil membre associé
        Optional<Membre> membre = membreDao.findByUtilisateurId(user.getId());
        membre.ifPresent(m -> session.setAttribute(SESSION_MEMBRE, m));

        LOGGER.info("Connexion réussie : " + email + " [" + user.getRole() + "]");
        return Optional.of(user);
    }

    /** Invalide la session HTTP. */
    public void logout(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
    }

    /** Vérifie si une session est authentifiée. */
    public static boolean isAuthenticated(HttpSession session) {
        return session != null && session.getAttribute(SESSION_USER) != null;
    }

    /** Vérifie si l'utilisateur connecté est admin. */
    public static boolean isAdmin(HttpSession session) {
        if (!isAuthenticated(session)) return false;
        String role = (String) session.getAttribute(SESSION_ROLE);
        return RoleEnum.ADMIN.name().equals(role);
    }

    /** Récupère l'utilisateur courant depuis la session. */
    public static Utilisateur getCurrentUser(HttpSession session) {
        return session != null ? (Utilisateur) session.getAttribute(SESSION_USER) : null;
    }

    /** Récupère le membre courant depuis la session. */
    public static Membre getCurrentMembre(HttpSession session) {
        return session != null ? (Membre) session.getAttribute(SESSION_MEMBRE) : null;
    }
}
