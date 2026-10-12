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
 * La factory est initialisée au démarrage via AppInitializerListener avec un mécanisme de retry
 * pour attendre la disponibilité de la base de données (notamment sous Docker).
 */
public class JpaUtil {

    private static final Logger LOGGER = Logger.getLogger(JpaUtil.class.getName());
    private static final String DEFAULT_PERSISTENCE_UNIT = "CotisationPU";
    private static final int MAX_RETRIES = 12;
    private static final long RETRY_DELAY_MS = 3000;
    private static EntityManagerFactory emf;

    private JpaUtil() { }

    /**
     * Initialise la factory JPA. Tente plusieurs fois de se connecter si la base démarre.
     */
    public static synchronized void init() {
        if (emf == null || !emf.isOpen()) {
            String puName = getEnvOrProperty("PERSISTENCE_UNIT", DEFAULT_PERSISTENCE_UNIT);

            // Si DB_URL est définie et pointe vers postgresql, on bascule automatiquement sur ucadCotisationsPU
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

            Exception lastException = null;
            for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
                try {
                    emf = overrides.isEmpty()
                            ? Persistence.createEntityManagerFactory(puName)
                            : Persistence.createEntityManagerFactory(puName, overrides);

                    LOGGER.info("EntityManagerFactory initialisée avec succès (tentative " + attempt + ").");
                    return;
                } catch (Exception e) {
                    lastException = e;
                    LOGGER.log(Level.WARNING, "Tentative " + attempt + "/" + MAX_RETRIES
                            + " d'initialisation JPA échouée. Attente de la base de données... (" + e.getMessage() + ")");
                    if (attempt < MAX_RETRIES) {
                        try {
                            Thread.sleep(RETRY_DELAY_MS);
                        } catch (InterruptedException ie) {
                            Thread.currentThread().interrupt();
                            break;
                        }
                    }
                }
            }

            LOGGER.log(Level.SEVERE, "Échec de l'initialisation JPA après " + MAX_RETRIES + " tentatives", lastException);
            throw new RuntimeException("Impossible de créer l'EntityManagerFactory", lastException);
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
     * Retourne un EntityManager. Tente une réinitialisation paresseuse si nécessaire.
     */
    public static EntityManager getEntityManager() {
        if (emf == null || !emf.isOpen()) {
            init();
        }
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
            init();
        }
        if (emf == null || !emf.isOpen()) {
            throw new IllegalStateException("EntityManagerFactory non initialisée.");
        }
        SessionFactory sf = emf.unwrap(SessionFactory.class);
        Session session = sf.openSession();
        return session.doReturningWork(conn -> conn);
    }
}
