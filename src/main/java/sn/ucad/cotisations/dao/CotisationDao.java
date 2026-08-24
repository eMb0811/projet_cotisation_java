package sn.ucad.cotisations.dao;

import jakarta.persistence.EntityManager;
import sn.ucad.cotisations.config.JpaUtil;
import sn.ucad.cotisations.model.Cotisation;
import sn.ucad.cotisations.model.StatutCotisation;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * DAO pour l'entité Cotisation.
 */
public class CotisationDao {

    public List<Cotisation> findAll() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT c FROM Cotisation c JOIN FETCH c.membre m JOIN FETCH m.utilisateur u ORDER BY c.annee DESC, c.mois DESC",
                Cotisation.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    public Optional<Cotisation> findById(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            List<Cotisation> list = em.createQuery(
                "SELECT c FROM Cotisation c JOIN FETCH c.membre m JOIN FETCH m.utilisateur u WHERE c.id = :id",
                Cotisation.class
            ).setParameter("id", id).getResultList();
            return list.isEmpty() ? Optional.empty() : Optional.of(list.get(0));
        } finally {
            em.close();
        }
    }

    public List<Cotisation> findByMembre(Long membreId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("Cotisation.findByMembre", Cotisation.class)
                    .setParameter("membreId", membreId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<Cotisation> findByPeriode(int annee, int mois) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("Cotisation.findByPeriode", Cotisation.class)
                    .setParameter("annee", annee)
                    .setParameter("mois", mois)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<Cotisation> findOverdue() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNamedQuery("Cotisation.findOverdue", Cotisation.class).getResultList();
        } finally {
            em.close();
        }
    }

    public boolean existsByMembreAndPeriode(Long membreId, int annee, int mois) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                "SELECT COUNT(c) FROM Cotisation c WHERE c.membre.id = :membreId AND c.annee = :annee AND c.mois = :mois",
                Long.class
            ).setParameter("membreId", membreId)
             .setParameter("annee", annee)
             .setParameter("mois", mois)
             .getSingleResult();
            return count > 0;
        } finally {
            em.close();
        }
    }

    public BigDecimal sumTotalPaid() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Object result = em.createNamedQuery("Cotisation.sumTotalPaid").getSingleResult();
            return result == null ? BigDecimal.ZERO : (BigDecimal) result;
        } finally {
            em.close();
        }
    }

    public long countByStatut(StatutCotisation statut) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT COUNT(c) FROM Cotisation c WHERE c.statut = :statut", Long.class
            ).setParameter("statut", statut).getSingleResult();
        } finally {
            em.close();
        }
    }

    public Cotisation save(Cotisation cotisation) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(cotisation);
            em.getTransaction().commit();
            return cotisation;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public Cotisation update(Cotisation cotisation) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Cotisation merged = em.merge(cotisation);
            em.getTransaction().commit();
            return merged;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** Sauvegarde une liste de cotisations en une seule transaction. */
    public void saveAll(List<Cotisation> cotisations) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            for (Cotisation c : cotisations) {
                em.persist(c);
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
