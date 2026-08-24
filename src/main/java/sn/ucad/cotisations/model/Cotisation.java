package sn.ucad.cotisations.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Entité JPA représentant la cotisation d'un membre pour une période (mois / année).
 */
@Entity
@Table(name = "cotisations", indexes = {
    @Index(name = "idx_cotisation_periode", columnList = "annee, mois"),
    @Index(name = "idx_cotisation_statut", columnList = "statut"),
    @Index(name = "idx_cotisation_membre", columnList = "membre_id")
})
@NamedQueries({
    @NamedQuery(name = "Cotisation.findByMembre", query = "SELECT c FROM Cotisation c JOIN FETCH c.membre m JOIN FETCH m.utilisateur u WHERE m.id = :membreId ORDER BY c.annee DESC, c.mois DESC"),
    @NamedQuery(name = "Cotisation.findByPeriode", query = "SELECT c FROM Cotisation c JOIN FETCH c.membre m JOIN FETCH m.utilisateur u WHERE c.annee = :annee AND c.mois = :mois"),
    @NamedQuery(name = "Cotisation.findOverdue", query = "SELECT c FROM Cotisation c JOIN FETCH c.membre m JOIN FETCH m.utilisateur u WHERE c.statut = sn.ucad.cotisations.model.StatutCotisation.EN_RETARD"),
    @NamedQuery(name = "Cotisation.sumTotalPaid", query = "SELECT COALESCE(SUM(c.montant), 0) FROM Cotisation c WHERE c.statut = sn.ucad.cotisations.model.StatutCotisation.PAYEE")
})
public class Cotisation implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "membre_id", referencedColumnName = "id", nullable = false)
    private Membre membre;

    @Column(name = "montant", nullable = false, precision = 12, scale = 2)
    private BigDecimal montant;

    @Column(name = "mois", nullable = false)
    private Integer mois;

    @Column(name = "annee", nullable = false)
    private Integer annee;

    @Column(name = "date_paiement")
    private LocalDateTime datePaiement;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false, length = 20)
    private StatutCotisation statut = StatutCotisation.EN_ATTENTE;

    @Enumerated(EnumType.STRING)
    @Column(name = "moyen_paiement", length = 30)
    private MoyenPaiement moyenPaiement;

    @Column(name = "reference_paiement", length = 100)
    private String referencePaiement;

    public Cotisation() {
    }

    public Cotisation(Membre membre, BigDecimal montant, Integer mois, Integer annee) {
        this.membre = membre;
        this.montant = montant;
        this.mois = mois;
        this.annee = annee;
        this.statut = StatutCotisation.EN_ATTENTE;
    }

    // Getters et Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Membre getMembre() {
        return membre;
    }

    public void setMembre(Membre membre) {
        this.membre = membre;
    }

    public BigDecimal getMontant() {
        return montant;
    }

    public void setMontant(BigDecimal montant) {
        this.montant = montant;
    }

    public Integer getMois() {
        return mois;
    }

    public void setMois(Integer mois) {
        this.mois = mois;
    }

    public Integer getAnnee() {
        return annee;
    }

    public void setAnnee(Integer annee) {
        this.annee = annee;
    }

    public LocalDateTime getDatePaiement() {
        return datePaiement;
    }

    public void setDatePaiement(LocalDateTime datePaiement) {
        this.datePaiement = datePaiement;
    }

    public StatutCotisation getStatut() {
        return statut;
    }

    public void setStatut(StatutCotisation statut) {
        this.statut = statut;
    }

    public MoyenPaiement getMoyenPaiement() {
        return moyenPaiement;
    }

    public void setMoyenPaiement(MoyenPaiement moyenPaiement) {
        this.moyenPaiement = moyenPaiement;
    }

    public String getReferencePaiement() {
        return referencePaiement;
    }

    public void setReferencePaiement(String referencePaiement) {
        this.referencePaiement = referencePaiement;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Cotisation that = (Cotisation) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "Cotisation{" +
                "id=" + id +
                ", montant=" + montant +
                ", mois=" + mois +
                ", annee=" + annee +
                ", datePaiement=" + datePaiement +
                ", statut=" + statut +
                '}';
    }
}
