package sn.ucad.cotisations.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import org.mindrot.jbcrypt.BCrypt;
import sn.ucad.cotisations.config.AppConfig;
import sn.ucad.cotisations.config.JpaUtil;
import sn.ucad.cotisations.model.*;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Listener de démarrage de l'application.
 * Déclaré dans web.xml (pas d'annotation @WebListener pour éviter une double initialisation).
 * Initialise la configuration, JPA, exécute data.sql (seed data), et s'assure que
 * l'administrateur par défaut existe.
 */
public class AppInitializerListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(AppInitializerListener.class.getName());
    private static final String ADMIN_EMAIL    = "admin@ucad.sn";
    private static final String ADMIN_PASSWORD = "admin123";

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("=== Démarrage de l'application Cotisations UCAD ===");

        // 1. Initialiser la configuration
        try {
            AppConfig.getInstance();
            LOGGER.info("[OK] Configuration chargée.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[ERREUR] Chargement configuration", e);
        }

        // 2. Initialiser JPA (crée les tables via hbm2ddl.auto=update)
        try {
            JpaUtil.init();
            LOGGER.info("[OK] EntityManagerFactory JPA initialisée.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "[ERREUR] Initialisation JPA — l'application peut ne pas fonctionner.", e);
            return;
        }

        // 3. Exécuter le script de données initiales (data.sql)
        try {
            executeSeedData();
            LOGGER.info("[OK] Données initiales (data.sql) chargées.");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[AVERT] Chargement data.sql échoué : " + e.getMessage(), e);
        }

        // 4. Créer/corriger l'admin par défaut (corrige le hash BCrypt si invalide)
        try {
            ensureDefaultAdminExists();
            LOGGER.info("[OK] Compte administrateur vérifié.");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[AVERT] Vérification admin échouée : " + e.getMessage(), e);
        }

        // 5. Insérer les utilisateurs de test supplémentaires
        try {
            seedTestUsers();
            LOGGER.info("[OK] Utilisateurs de test vérifiés.");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "[AVERT] Seed utilisateurs de test échoué : " + e.getMessage(), e);
        }

        LOGGER.info("=== Application démarrée avec succès — Accès : " + ADMIN_EMAIL + " / " + ADMIN_PASSWORD + " ===");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("=== Arrêt de l'application Cotisations UCAD ===");
        JpaUtil.close();
        LOGGER.info("[OK] EntityManagerFactory JPA fermée.");
    }

    /**
     * Insère 10 utilisateurs membres de test (mot de passe : "passer123").
     * Chaque utilisateur n'est créé que s'il n'existe pas déjà (idempotent).
     */
    private void seedTestUsers() {
        // Données : { email, nom, prenom, telephone, dateAdhesion }
        Object[][] users = {
            {"marie.diallo@ucad.sn",    "DIALLO",   "Marie",    "+221771000001", LocalDate.of(2025, 1, 10)},
            {"ousmane.ba@ucad.sn",      "BA",       "Ousmane",  "+221771000002", LocalDate.of(2025, 1, 15)},
            {"aminata.fall@ucad.sn",    "FALL",     "Aminata",  "+221771000003", LocalDate.of(2025, 2,  1)},
            {"cheikh.wade@ucad.sn",     "WADE",     "Cheikh",   "+221771000004", LocalDate.of(2025, 2, 10)},
            {"rokhaya.ndiaye@ucad.sn",  "NDIAYE",   "Rokhaya",  "+221771000005", LocalDate.of(2025, 3,  1)},
            {"modou.seck@ucad.sn",      "SECK",     "Modou",    "+221771000006", LocalDate.of(2025, 3, 20)},
            {"aissatou.diop@ucad.sn",   "DIOP",     "Aissatou", "+221771000007", LocalDate.of(2025, 4,  5)},
            {"mamadou.gaye@ucad.sn",    "GAYE",     "Mamadou",  "+221771000008", LocalDate.of(2025, 4, 18)},
            {"coumba.thiaw@ucad.sn",    "THIAW",    "Coumba",   "+221771000009", LocalDate.of(2025, 5,  2)},
            {"pape.mbaye@ucad.sn",      "MBAYE",    "Pape",     "+221771000010", LocalDate.of(2025, 5, 15)},
        };

        String passwordHash = BCrypt.hashpw("passer123", BCrypt.gensalt(10));
        int created = 0;

        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            for (Object[] u : users) {
                String email     = (String) u[0];
                String nom       = (String) u[1];
                String prenom    = (String) u[2];
                String telephone = (String) u[3];
                LocalDate date   = (LocalDate) u[4];

                // Vérifier si l'utilisateur existe déjà
                long count = em.createQuery(
                        "SELECT COUNT(u) FROM Utilisateur u WHERE u.email = :email", Long.class)
                        .setParameter("email", email)
                        .getSingleResult();

                if (count == 0) {
                    Utilisateur utilisateur = new Utilisateur(email, passwordHash, RoleEnum.MEMBRE);
                    em.persist(utilisateur);
                    em.flush(); // pour obtenir l'ID généré

                    Membre membre = new Membre(utilisateur, nom, prenom, telephone, date);
                    em.persist(membre);
                    created++;
                    LOGGER.info("[SEED] Utilisateur créé : " + email);
                }
            }
            tx.commit();
            LOGGER.info("[SEED] " + created + " utilisateur(s) de test insérés (sur " + users.length + " configurés).");
        } catch (Exception ex) {
            if (tx.isActive()) tx.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

    /**
     * Exécute le script sql/data.sql via EntityManager JPA (createNativeQuery) dans une
     * transaction explicite. Chaque instruction SQL (terminée par ';') est exécutée et
     * commitée en une seule transaction. Les lignes de commentaires (--) sont ignorées.
     */
    private void executeSeedData() throws Exception {
        InputStream is = getClass().getClassLoader().getResourceAsStream("sql/data.sql");
        if (is == null) {
            LOGGER.warning("[AVERT] Fichier sql/data.sql introuvable dans le classpath — seed data ignoré.");
            return;
        }

        // Lire le contenu complet du fichier
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();
                // Ignorer les lignes vides et les commentaires SQL
                if (trimmed.isEmpty() || trimmed.startsWith("--")) {
                    continue;
                }
                sb.append(trimmed).append("\n");
            }
        }

        // Découper par ';' pour obtenir les instructions individuelles
        String[] statements = sb.toString().split(";");

        // Exécuter via EntityManager JPA dans une transaction → commit garanti
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            for (String sql : statements) {
                String trimmedSql = sql.trim();
                if (!trimmedSql.isEmpty()) {
                    try {
                        em.createNativeQuery(trimmedSql).executeUpdate();
                        LOGGER.fine("[SQL] Exécuté : " + trimmedSql.substring(0, Math.min(80, trimmedSql.length())));
                    } catch (Exception ex) {
                        LOGGER.log(Level.WARNING, "[SQL] Erreur sur : "
                                + trimmedSql.substring(0, Math.min(80, trimmedSql.length()))
                                + " — " + ex.getMessage());
                    }
                }
            }
            tx.commit();
            LOGGER.info("[OK] Seed data committé avec succès.");
        } catch (Exception ex) {
            if (tx.isActive()) tx.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

    /**
     * Crée l'admin si absent, ou corrige son hash s'il est invalide (hash issu d'un seed data incorrect).
     * Credentials : admin@ucad.sn / admin123
     */
    private void ensureDefaultAdminExists() {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            Utilisateur admin;
            try {
                admin = em.createNamedQuery("Utilisateur.findByEmail", Utilisateur.class)
                        .setParameter("email", ADMIN_EMAIL)
                        .getSingleResult();

                // Vérifier que le hash est valide et correspond au bon mot de passe
                boolean hashValide = false;
                try {
                    hashValide = BCrypt.checkpw(ADMIN_PASSWORD, admin.getMotDePasseHash());
                } catch (Exception ignored) {
                    // Hash malformé → on le régénère
                }

                if (!hashValide) {
                    String newHash = BCrypt.hashpw(ADMIN_PASSWORD, BCrypt.gensalt(10));
                    admin.setMotDePasseHash(newHash);
                    admin.setActif(true);
                    em.merge(admin);
                    LOGGER.info("Hash admin mis à jour (hash seed data invalide corrigé).");
                } else {
                    LOGGER.info("Administrateur existant OK : " + ADMIN_EMAIL);
                }

            } catch (NoResultException e) {
                // Admin absent → le créer
                LOGGER.info("Création du compte administrateur par défaut...");
                String hash = BCrypt.hashpw(ADMIN_PASSWORD, BCrypt.gensalt(10));
                admin = new Utilisateur(ADMIN_EMAIL, hash, RoleEnum.ADMIN);
                em.persist(admin);
                em.flush();

                // Créer le profil membre associé s'il n'existe pas
                long membreCount = em.createQuery(
                    "SELECT COUNT(m) FROM Membre m WHERE m.utilisateur.id = :uid", Long.class)
                    .setParameter("uid", admin.getId())
                    .getSingleResult();

                if (membreCount == 0) {
                    Membre membreAdmin = new Membre(admin, "DIOP", "Amadou", "+221770000000", LocalDate.of(2025, 1, 1));
                    em.persist(membreAdmin);
                }
                LOGGER.info("Administrateur créé : " + ADMIN_EMAIL + " / " + ADMIN_PASSWORD);
            }

            tx.commit();
        } catch (Exception ex) {
            if (tx.isActive()) tx.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }
}
