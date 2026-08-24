package sn.ucad.cotisations.dao;

import jakarta.persistence.EntityManager;
import sn.ucad.cotisations.config.JpaUtil;
import sn.ucad.cotisations.model.EmailLog;
import sn.ucad.cotisations.model.Membre;
import sn.ucad.cotisations.model.StatutNotification;

import java.util.List;
import java.util.Optional;

/**
 * DAO pour l'entité EmailLog.
 */
public class EmailLogDao {

    public List<EmailLog> findAll() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("EmailLog.findAllRecent", EmailLog.class).getResultList();
        } finally {
            em.close();
        }
    }

    public Optional<EmailLog> findById(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return Optional.ofNullable(em.find(EmailLog.class, id));
        } finally {
            em.close();
        }
    }

    public List<EmailLog> findByMembre(Long membreId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("EmailLog.findByMembre", EmailLog.class)
                    .setParameter("membreId", membreId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<EmailLog> findRecentWithLimit(int limit) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("EmailLog.findAllRecent", EmailLog.class)
                    .setMaxResults(limit)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public EmailLog save(EmailLog log) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(log);
            em.getTransaction().commit();
            return log;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** Sauvegarde un log même en cas d'erreur d'envoi. */
    public EmailLog logEmail(Membre membre, String destinataire, String sujet, String contenu, boolean success, String erreur) {
        EmailLog log = new EmailLog(
                membre,
                destinataire,
                sujet,
                contenu,
                success ? StatutNotification.ENVOYE : StatutNotification.ECHEC
        );
        if (!success) {
            log.setErreurMessage(erreur != null ? erreur.substring(0, Math.min(erreur.length(), 490)) : "Erreur inconnue");
        }
        return save(log);
    }
}
