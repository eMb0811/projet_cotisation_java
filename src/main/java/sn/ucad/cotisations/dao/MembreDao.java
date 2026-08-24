package sn.ucad.cotisations.dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import sn.ucad.cotisations.config.JpaUtil;
import sn.ucad.cotisations.model.Membre;
import sn.ucad.cotisations.model.StatutMembre;

import java.util.List;
import java.util.Optional;

/**
 * DAO pour l'entité Membre.
 */
public class MembreDao {

    public List<Membre> findAll() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT m FROM Membre m JOIN FETCH m.utilisateur u ORDER BY m.nom, m.prenom",
                Membre.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    public List<Membre> findAllActive() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("Membre.findAllActive", Membre.class).getResultList();
        } finally {
            em.close();
        }
    }

    public Optional<Membre> findById(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            List<Membre> result = em.createQuery(
                "SELECT m FROM Membre m JOIN FETCH m.utilisateur u WHERE m.id = :id",
                Membre.class
            ).setParameter("id", id).getResultList();
            return result.isEmpty() ? Optional.empty() : Optional.of(result.get(0));
        } finally {
            em.close();
        }
    }

    public Optional<Membre> findByIdWithDetails(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            List<Membre> result = em.createQuery(
                "SELECT m FROM Membre m JOIN FETCH m.utilisateur u WHERE m.id = :id",
                Membre.class
            ).setParameter("id", id).getResultList();
            return result.isEmpty() ? Optional.empty() : Optional.of(result.get(0));
        } finally {
            em.close();
        }
    }

    public Optional<Membre> findByUtilisateurId(Long utilisateurId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            List<Membre> result = em.createQuery(
                "SELECT m FROM Membre m WHERE m.utilisateur.id = :uid",
                Membre.class
            ).setParameter("uid", utilisateurId).getResultList();
            return result.isEmpty() ? Optional.empty() : Optional.of(result.get(0));
        } finally {
            em.close();
        }
    }

    public Optional<Membre> findByTelephone(String telephone) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Membre m = em.createNamedQuery("Membre.findByTelephone", Membre.class)
                    .setParameter("telephone", telephone)
                    .getSingleResult();
            return Optional.of(m);
        } catch (NoResultException e) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    public long countActive() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("Membre.countActive", Long.class).getSingleResult();
        } finally {
            em.close();
        }
    }

    public Membre save(Membre membre) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(membre);
            em.getTransaction().commit();
            return membre;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public Membre update(Membre membre) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Membre merged = em.merge(membre);
            em.getTransaction().commit();
            return merged;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void updateStatut(Long id, StatutMembre statut) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Membre m = em.find(Membre.class, id);
            if (m != null) {
                m.setStatut(statut);
                em.merge(m);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void deleteById(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Membre m = em.find(Membre.class, id);
            if (m != null) {
                sn.ucad.cotisations.model.Utilisateur u = m.getUtilisateur();
                em.remove(m);
                if (u != null) {
                    sn.ucad.cotisations.model.Utilisateur attachedUser = em.find(sn.ucad.cotisations.model.Utilisateur.class, u.getId());
                    if (attachedUser != null) {
                        em.remove(attachedUser);
                    }
                }
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
