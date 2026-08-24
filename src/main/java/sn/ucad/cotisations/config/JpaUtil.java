package sn.ucad.cotisations.config;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import org.hibernate.Session;
import org.hibernate.SessionFactory;

import java.sql.Connection;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Utilitaire JPA : gère le cycle de vie de l'EntityManagerFactory (singleton).
 * La factory est initialisée une seule fois au démarrage via AppInitializerListener.
 */
public class JpaUtil {

    private static final Logger LOGGER = Logger.getLogger(JpaUtil.class.getName());
    private static final String PERSISTENCE_UNIT = "CotisationPU";
    private static EntityManagerFactory emf;

    private JpaUtil() { }

    /**
     * Initialise la factory JPA. Appelé par AppInitializerListener au démarrage.
     */
    public static synchronized void init() {
        if (emf == null || !emf.isOpen()) {
            try {
                LOGGER.info("Initialisation de l'EntityManagerFactory (PU: " + PERSISTENCE_UNIT + ")...");
                emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT);
                LOGGER.info("EntityManagerFactory initialisée avec succès.");
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Échec de l'initialisation JPA", e);
                throw new RuntimeException("Impossible de créer l'EntityManagerFactory", e);
            }
        }
    }

    /**
     * Retourne un EntityManager. Chaque appelant doit le fermer après usage.
     */
    public static EntityManager getEntityManager() {
        if (emf == null || !emf.isOpen()) {
            throw new IllegalStateException("EntityManagerFactory non initialisée. Appelez JpaUtil.init() d'abord.");
        }
        return emf.createEntityManager();
    }

    /**
     * Ferme la factory. Appelé par AppInitializerListener à l'arrêt.
     */
    public static synchronized void close() {
        if (emf != null && emf.isOpen()) {
            emf.close();
            LOGGER.info("EntityManagerFactory fermée.");
        }
    }

    public static boolean isInitialized() {
        return emf != null && emf.isOpen();
    }

    /**
     * Ouvre une connexion JDBC native via la SessionFactory Hibernate.
     * L'appelant est responsable de fermer la connexion après usage.
     */
    public static Connection getConnection() throws Exception {
        if (emf == null || !emf.isOpen()) {
            throw new IllegalStateException("EntityManagerFactory non initialisée.");
        }
        SessionFactory sf = emf.unwrap(SessionFactory.class);
        Session session = sf.openSession();
        return session.doReturningWork(conn -> conn);
    }
}
