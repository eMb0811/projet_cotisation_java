package sn.ucad.cotisations.model;

/**
 * Statuts du journal d'envoi d'e-mails.
 */
public enum StatutNotification {
    /** E-mail transmis avec succès au serveur SMTP */
    ENVOYE,

    /** Échec lors de la tentative d'envoi */
    ECHEC
}
