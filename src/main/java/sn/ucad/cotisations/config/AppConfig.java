package sn.ucad.cotisations.config;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Charge et expose la configuration depuis application.properties.
 * Singleton initialisé au démarrage de l'application.
 */
public class AppConfig {

    private static final Logger LOGGER = Logger.getLogger(AppConfig.class.getName());
    private static final String CONFIG_FILE = "/application.properties";
    private static AppConfig instance;
    private final Properties props = new Properties();

    private AppConfig() {
        try (InputStream is = AppConfig.class.getResourceAsStream(CONFIG_FILE)) {
            if (is == null) {
                throw new RuntimeException("Fichier de configuration introuvable : " + CONFIG_FILE);
            }
            props.load(is);
            LOGGER.info("Configuration chargée depuis " + CONFIG_FILE);
        } catch (IOException e) {
            throw new RuntimeException("Impossible de charger " + CONFIG_FILE, e);
        }
    }

    public static synchronized AppConfig getInstance() {
        if (instance == null) {
            instance = new AppConfig();
        }
        return instance;
    }

    private String getEnvOrProp(String envKey, String propKey, String defaultValue) {
        String val = System.getenv(envKey);
        if (val != null && !val.isBlank()) {
            return val;
        }
        val = System.getProperty(envKey);
        if (val != null && !val.isBlank()) {
            return val;
        }
        return props.getProperty(propKey, defaultValue);
    }

    // -------------------------------------------------------------------------
    // Base de données
    // -------------------------------------------------------------------------
    public String getDbDriver()   { return getEnvOrProp("DB_DRIVER", "db.driver", "com.mysql.cj.jdbc.Driver"); }
    public String getDbUrl()      { return getEnvOrProp("DB_URL", "db.url", "jdbc:mysql://db:3306/cotisations_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"); }
    public String getDbUser()     { return getEnvOrProp("DB_USER", "db.user", "root"); }
    public String getDbPassword() { return getEnvOrProp("DB_PASSWORD", "db.password", "votre_mot_de_passe"); }

    // -------------------------------------------------------------------------
    // Paramètres métier
    // -------------------------------------------------------------------------
    public BigDecimal getCotisationMontantDefaut() {
        return new BigDecimal(props.getProperty("app.cotisation.montant_mensuel_defaut", "10000.00"));
    }

    public BigDecimal getAmendeMontantDefaut() {
        return new BigDecimal(props.getProperty("app.amende.montant_retard_defaut", "2500.00"));
    }

    public String getDevise() {
        return props.getProperty("app.devise", "FCFA");
    }

    // -------------------------------------------------------------------------
    // Configuration SMTP
    // -------------------------------------------------------------------------
    public String getSmtpHost()        { return getEnvOrProp("SMTP_HOST", "mail.smtp.host", "sandbox.smtp.mailtrap.io"); }
    public int    getSmtpPort()        { return Integer.parseInt(getEnvOrProp("SMTP_PORT", "mail.smtp.port", "587")); }
    public String getSmtpUsername()    { return getEnvOrProp("SMTP_USERNAME", "mail.smtp.username", ""); }
    public String getSmtpPassword()    { return getEnvOrProp("SMTP_PASSWORD", "mail.smtp.password", ""); }
    public String getMailFrom()        { return getEnvOrProp("SMTP_FROM", "mail.from", "noreply@ucad.sn"); }
    public boolean isSmtpAuth()        { return Boolean.parseBoolean(getEnvOrProp("SMTP_AUTH", "mail.smtp.auth", "true")); }
    public boolean isSmtpStarttls()    { return Boolean.parseBoolean(getEnvOrProp("SMTP_STARTTLS", "mail.smtp.starttls.enable", "true")); }

    /** Récupère une propriété arbitraire. */
    public String getProperty(String key, String defaultValue) {
        String envKey = key.toUpperCase().replace('.', '_');
        return getEnvOrProp(envKey, key, defaultValue);
    }
}
