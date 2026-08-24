package sn.ucad.cotisations.dao;

import jakarta.persistence.EntityManager;
import sn.ucad.cotisations.config.JpaUtil;
import sn.ucad.cotisations.model.Amende;
import sn.ucad.cotisations.model.StatutAmende;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * DAO pour l'entité Amende.
 */
public class AmendeDao {

    public List<Amende> findAll() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT a FROM Amende a JOIN FETCH a.membre m JOIN FETCH m.utilisateur u ORDER BY a.dateGeneration DESC",
                Amende.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    public Optional<Amende> findById(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            List<Amende> list = em.createQuery(
                "SELECT a FROM Amende a JOIN FETCH a.membre m JOIN FETCH m.utilisateur u WHERE a.id = :id",
                Amende.class
            ).setParameter("id", id).getResultList();
            return list.isEmpty() ? Optional.empty() : Optional.of(list.get(0));
        } finally {
            em.close();
        }
    }

    public List<Amende> findByMembre(Long membreId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("Amende.findByMembre", Amende.class)
                    .setParameter("membreId", membreId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<Amende> findUnpaidByMembre(Long membreId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("Amende.findUnpaidByMembre", Amende.class)
                    .setParameter("membreId", membreId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<Amende> findAllUnpaid() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT a FROM Amende a JOIN FETCH a.membre m JOIN FETCH m.utilisateur u WHERE a.statut = :statut ORDER BY a.dateGeneration DESC",
                Amende.class
            ).setParameter("statut", StatutAmende.IMPAYEE).getResultList();
        } finally {
            em.close();
        }
    }

    public BigDecimal sumTotalUnpaid() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Object result = em.createNamedQuery("Amende.sumTotalUnpaid").getSingleResult();
            return result == null ? BigDecimal.ZERO : (BigDecimal) result;
        } finally {
            em.close();
        }
    }

    public long countByStatut(StatutAmende statut) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT COUNT(a) FROM Amende a WHERE a.statut = :statut", Long.class
            ).setParameter("statut", statut).getSingleResult();
        } finally {
            em.close();
        }
    }

    public Amende save(Amende amende) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(amende);
            em.getTransaction().commit();
            return amende;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public Amende update(Amende amende) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Amende merged = em.merge(amende);
            em.getTransaction().commit();
            return merged;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
