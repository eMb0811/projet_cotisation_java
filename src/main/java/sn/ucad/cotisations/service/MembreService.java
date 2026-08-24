package sn.ucad.cotisations.service;

import org.mindrot.jbcrypt.BCrypt;
import sn.ucad.cotisations.config.JpaUtil;
import sn.ucad.cotisations.dao.MembreDao;
import sn.ucad.cotisations.dao.UtilisateurDao;
import sn.ucad.cotisations.model.*;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;

/**
 * Service métier pour la gestion des membres.
 */
public class MembreService {

    private static final Logger LOGGER = Logger.getLogger(MembreService.class.getName());
    private final MembreDao membreDao = new MembreDao();
    private final UtilisateurDao utilisateurDao = new UtilisateurDao();

    public List<Membre> getAllMembres() {
        return membreDao.findAll();
    }

    public List<Membre> getMembresActifs() {
        return membreDao.findAllActive();
    }

    public Optional<Membre> getMembreById(Long id) {
        return membreDao.findByIdWithDetails(id);
    }

    public long countMembresActifs() {
        return membreDao.countActive();
    }

    /**
     * Crée un nouveau membre avec son compte utilisateur associé.
     * Exécuté dans une transaction unique.
     */
    public Membre createMembre(String email, String motDePasse,
                                String nom, String prenom,
                                String telephone, LocalDate dateAdhesion) {
        // Vérifications basiques
        Optional<Utilisateur> existing = utilisateurDao.findByEmail(email);
        if (existing.isPresent()) {
            throw new IllegalArgumentException("Un utilisateur existe déjà avec l'email : " + email);
        }
        if (membreDao.findByTelephone(telephone).isPresent()) {
            throw new IllegalArgumentException("Ce numéro de téléphone est déjà utilisé : " + telephone);
        }

        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            String hash = BCrypt.hashpw(motDePasse, BCrypt.gensalt(10));
            Utilisateur utilisateur = new Utilisateur(email.trim().toLowerCase(), hash, RoleEnum.MEMBRE);
            em.persist(utilisateur);
            em.flush();

            Membre membre = new Membre(utilisateur, nom.trim().toUpperCase(), prenom.trim(), telephone.trim(), dateAdhesion);
            em.persist(membre);

            tx.commit();
            LOGGER.info("Nouveau membre créé : " + prenom + " " + nom + " (" + email + ")");
            return membre;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw new RuntimeException("Erreur lors de la création du membre", e);
        } finally {
            em.close();
        }
    }

    /**
     * Met à jour les informations d'un membre.
     */
    public Membre updateMembre(Long id, String nom, String prenom,
                                String telephone, StatutMembre statut) {
        Membre membre = membreDao.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Membre introuvable : " + id));

        // Vérifier unicité téléphone (sauf le même membre)
        Optional<Membre> byTel = membreDao.findByTelephone(telephone);
        if (byTel.isPresent() && !byTel.get().getId().equals(id)) {
            throw new IllegalArgumentException("Ce numéro de téléphone est déjà utilisé.");
        }

        membre.setNom(nom.trim().toUpperCase());
        membre.setPrenom(prenom.trim());
        membre.setTelephone(telephone.trim());
        membre.setStatut(statut);
        return membreDao.update(membre);
    }

    /** Désactive un membre (INACTIF). */
    public void deactivateMembre(Long id) {
        Membre membre = membreDao.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Membre introuvable : " + id));
        membre.setStatut(StatutMembre.INACTIF);
        membre.getUtilisateur().setActif(false);
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Membre m = em.merge(membre);
            Utilisateur u = em.merge(membre.getUtilisateur());
            u.setActif(false);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw new RuntimeException("Erreur lors de la désactivation", e);
        } finally {
            em.close();
        }
    }

    /**
     * Change le mot de passe d'un utilisateur après vérification de l'ancien.
     */
    public boolean changerMotDePasse(String email, String ancienMotDePasse, String nouveauMotDePasse) {
        if (email == null || ancienMotDePasse == null || nouveauMotDePasse == null || nouveauMotDePasse.length() < 6) {
            throw new IllegalArgumentException("Le nouveau mot de passe doit contenir au moins 6 caractères.");
        }
        Utilisateur user = utilisateurDao.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur introuvable avec l'email : " + email));

        if (!BCrypt.checkpw(ancienMotDePasse, user.getMotDePasseHash())) {
            throw new IllegalArgumentException("L'ancien mot de passe saisi est incorrect.");
        }

        String nouveauHash = BCrypt.hashpw(nouveauMotDePasse, BCrypt.gensalt(10));
        user.setMotDePasseHash(nouveauHash);
        utilisateurDao.update(user);
        LOGGER.info("Mot de passe mis à jour avec succès pour l'utilisateur : " + email);
        return true;
    }

    /**
     * Met à jour directement le mot de passe d'un utilisateur identifié par son ID.
     */
    public void updateMotDePasse(Long utilisateurId, String ancienMotDePasse, String nouveauMotDePasse) {
        if (nouveauMotDePasse == null || nouveauMotDePasse.length() < 6) {
            throw new IllegalArgumentException("Le nouveau mot de passe doit contenir au moins 6 caractères.");
        }
        Utilisateur user = utilisateurDao.findById(utilisateurId)
                .orElseThrow(() -> new IllegalArgumentException("Compte utilisateur introuvable : " + utilisateurId));

        if (!BCrypt.checkpw(ancienMotDePasse, user.getMotDePasseHash())) {
            throw new IllegalArgumentException("L'ancien mot de passe saisi est incorrect.");
        }

        String nouveauHash = BCrypt.hashpw(nouveauMotDePasse, BCrypt.gensalt(10));
        user.setMotDePasseHash(nouveauHash);
        utilisateurDao.update(user);
    }

    /**
     * Supprime définitivement un membre de la base de données.
     * Les cotisations et amendes sont supprimées en cascade (ON DELETE CASCADE).
     */
    public void deleteMembre(Long id) {
        Membre membre = membreDao.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Membre introuvable : " + id));

        // Protection de l'administrateur
        if (membre.getUtilisateur() != null && RoleEnum.ADMIN.equals(membre.getUtilisateur().getRole())) {
            throw new IllegalStateException("Impossible de supprimer le compte administrateur.");
        }

        membreDao.deleteById(id);
        LOGGER.info("Membre supprimé définitivement de la base de données (ID: " + id + ", Nom: " + membre.getNomComplet() + ")");
    }
}
