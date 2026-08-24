package sn.ucad.cotisations.dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import sn.ucad.cotisations.config.JpaUtil;
import sn.ucad.cotisations.model.Utilisateur;

import java.util.List;
import java.util.Optional;

/**
 * DAO pour l'entité Utilisateur.
 */
public class UtilisateurDao {

    public Optional<Utilisateur> findByEmail(String email) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Utilisateur u = em.createNamedQuery("Utilisateur.findByEmail", Utilisateur.class)
                    .setParameter("email", email)
                    .getSingleResult();
            return Optional.of(u);
        } catch (NoResultException e) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    public Optional<Utilisateur> findById(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return Optional.ofNullable(em.find(Utilisateur.class, id));
        } finally {
            em.close();
        }
    }

    public List<Utilisateur> findAllActive() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("Utilisateur.findAllActive", Utilisateur.class).getResultList();
        } finally {
            em.close();
        }
    }

    public Utilisateur save(Utilisateur utilisateur) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(utilisateur);
            em.getTransaction().commit();
            return utilisateur;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public Utilisateur update(Utilisateur utilisateur) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Utilisateur merged = em.merge(utilisateur);
            em.getTransaction().commit();
            return merged;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void deactivate(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Utilisateur u = em.find(Utilisateur.class, id);
            if (u != null) {
                u.setActif(false);
                em.merge(u);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
