package sn.ucad.cotisations.model;

/**
 * Statuts possibles d'une cotisation mensuelle.
 */
public enum StatutCotisation {
    /** Cotisation réglée avec succès */
    PAYEE,

    /** Cotisation en attente de versement */
    EN_ATTENTE,

    /** Cotisation non réglée après la date limite */
    EN_RETARD
}
