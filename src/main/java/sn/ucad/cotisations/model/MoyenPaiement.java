package sn.ucad.cotisations.model;

/**
 * Modes de règlement acceptés pour les cotisations et amendes.
 */
public enum MoyenPaiement {
    /** Règlement en numéraire */
    ESPECES,

    /** Paiement via Wave, Orange Money, Free Money */
    MOBILE_MONEY,

    /** Virement bancaire */
    VIREMENT,

    /** Chèque bancaire */
    CHEQUE
}
