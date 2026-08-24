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

    // -------------------------------------------------------------------------
    // Base de données
    // -------------------------------------------------------------------------
    public String getDbDriver()   { return props.getProperty("db.driver"); }
    public String getDbUrl()      { return props.getProperty("db.url"); }
    public String getDbUser()     { return props.getProperty("db.user"); }
    public String getDbPassword() { return props.getProperty("db.password", ""); }

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
    public String getSmtpHost()        { return props.getProperty("mail.smtp.host"); }
    public int    getSmtpPort()        { return Integer.parseInt(props.getProperty("mail.smtp.port", "587")); }
    public String getSmtpUsername()    { return props.getProperty("mail.smtp.username"); }
    public String getSmtpPassword()    { return props.getProperty("mail.smtp.password"); }
    public String getMailFrom()        { return props.getProperty("mail.from"); }
    public boolean isSmtpAuth()        { return Boolean.parseBoolean(props.getProperty("mail.smtp.auth", "true")); }
    public boolean isSmtpStarttls()    { return Boolean.parseBoolean(props.getProperty("mail.smtp.starttls.enable", "true")); }

    /** Récupère une propriété arbitraire. */
    public String getProperty(String key, String defaultValue) {
        return props.getProperty(key, defaultValue);
    }
}
