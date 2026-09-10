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
    private static final String DEFAULT_PERSISTENCE_UNIT = "CotisationPU";
    private static EntityManagerFactory emf;

    private JpaUtil() { }

    /**
     * Initialise la factory JPA. Appelé par AppInitializerListener au démarrage.
     */
    public static synchronized void init() {
        if (emf == null || !emf.isOpen()) {
            try {
                String puName = getEnvOrProperty("PERSISTENCE_UNIT", DEFAULT_PERSISTENCE_UNIT);

                // Si DB_URL est définie (ex: environnement Kubernetes) et que l'unité par défaut est active,
                // on bascule automatiquement sur ucadCotisationsPU si l'URL pointe vers postgresql
                String dbUrl = getEnvOrProperty("DB_URL", null);
                if (DEFAULT_PERSISTENCE_UNIT.equals(puName) && dbUrl != null && dbUrl.contains("postgresql")) {
                    puName = "ucadCotisationsPU";
                }

                LOGGER.info("Initialisation de l'EntityManagerFactory (PU: " + puName + ")...");

                java.util.Map<String, Object> overrides = new java.util.HashMap<>();
                if (dbUrl != null && !dbUrl.isBlank()) {
                    overrides.put("jakarta.persistence.jdbc.url", dbUrl);
                }
                String dbUser = getEnvOrProperty("DB_USER", null);
                if (dbUser != null && !dbUser.isBlank()) {
                    overrides.put("jakarta.persistence.jdbc.user", dbUser);
                }
                String dbPassword = getEnvOrProperty("DB_PASSWORD", null);
                if (dbPassword != null && !dbPassword.isBlank()) {
                    overrides.put("jakarta.persistence.jdbc.password", dbPassword);
                }

                emf = overrides.isEmpty()
                        ? Persistence.createEntityManagerFactory(puName)
                        : Persistence.createEntityManagerFactory(puName, overrides);

                LOGGER.info("EntityManagerFactory initialisée avec succès.");
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Échec de l'initialisation JPA", e);
                throw new RuntimeException("Impossible de créer l'EntityManagerFactory", e);
            }
        }
    }

    private static String getEnvOrProperty(String key, String defaultValue) {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) {
            value = System.getProperty(key);
        }
        return (value != null && !value.isBlank()) ? value : defaultValue;
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
