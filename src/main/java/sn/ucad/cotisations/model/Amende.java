package sn.ucad.cotisations.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Entité JPA représentant une amende ou pénalité financière attribuée à un membre.
 */
@Entity
@Table(name = "amendes", indexes = {
    @Index(name = "idx_amende_membre", columnList = "membre_id"),
    @Index(name = "idx_amende_statut", columnList = "statut")
})
@NamedQueries({
    @NamedQuery(name = "Amende.findByMembre", query = "SELECT a FROM Amende a JOIN FETCH a.membre m JOIN FETCH m.utilisateur u WHERE m.id = :membreId ORDER BY a.dateGeneration DESC"),
    @NamedQuery(name = "Amende.findUnpaidByMembre", query = "SELECT a FROM Amende a JOIN FETCH a.membre m JOIN FETCH m.utilisateur u WHERE m.id = :membreId AND a.statut = sn.ucad.cotisations.model.StatutAmende.IMPAYEE"),
    @NamedQuery(name = "Amende.sumTotalUnpaid", query = "SELECT COALESCE(SUM(a.montant), 0) FROM Amende a WHERE a.statut = sn.ucad.cotisations.model.StatutAmende.IMPAYEE")
})
public class Amende implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "membre_id", referencedColumnName = "id", nullable = false)
    private Membre membre;

    @Column(name = "motif", nullable = false, length = 255)
    private String motif;

    @Column(name = "montant", nullable = false, precision = 12, scale = 2)
    private BigDecimal montant;

    @Column(name = "date_generation", nullable = false, updatable = false)
    private LocalDateTime dateGeneration;

    @Column(name = "date_paiement")
    private LocalDateTime datePaiement;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false, length = 20)
    private StatutAmende statut = StatutAmende.IMPAYEE;

    @Enumerated(EnumType.STRING)
    @Column(name = "moyen_paiement", length = 30)
    private MoyenPaiement moyenPaiement;

    @Column(name = "reference_paiement", length = 100)
    private String referencePaiement;

    public Amende() {
    }

    public Amende(Membre membre, String motif, BigDecimal montant) {
        this.membre = membre;
        this.motif = motif;
        this.montant = montant;
        this.statut = StatutAmende.IMPAYEE;
    }

    @PrePersist
    protected void onCreate() {
        this.dateGeneration = LocalDateTime.now();
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

    public String getMotif() {
        return motif;
    }

    public void setMotif(String motif) {
        this.motif = motif;
    }

    public BigDecimal getMontant() {
        return montant;
    }

    public void setMontant(BigDecimal montant) {
        this.montant = montant;
    }

    public LocalDateTime getDateGeneration() {
        return dateGeneration;
    }

    public void setDateGeneration(LocalDateTime dateGeneration) {
        this.dateGeneration = dateGeneration;
    }

    public LocalDateTime getDatePaiement() {
        return datePaiement;
    }

    public void setDatePaiement(LocalDateTime datePaiement) {
        this.datePaiement = datePaiement;
    }

    public StatutAmende getStatut() {
        return statut;
    }

    public void setStatut(StatutAmende statut) {
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
        Amende amende = (Amende) o;
        return Objects.equals(id, amende.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "Amende{" +
                "id=" + id +
                ", motif='" + motif + '\'' +
                ", montant=" + montant +
                ", dateGeneration=" + dateGeneration +
                ", statut=" + statut +
                '}';
    }
}
