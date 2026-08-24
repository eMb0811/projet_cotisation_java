package sn.ucad.cotisations.model;

/**
 * Statuts possibles d'un membre de l'association UCAD.
 */
public enum StatutMembre {
    /** Membre actif à jour de ses activités */
    ACTIF,

    /** Membre inactif ou désactivé par l'administrateur */
    INACTIF,

    /** Membre suspendu suite à des retards cumulés */
    SUSPENDU
}
