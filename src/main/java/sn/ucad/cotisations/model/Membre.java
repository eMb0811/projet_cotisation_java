package sn.ucad.cotisations.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Entité JPA représentant un membre adhérent de l'UCAD.
 */
@Entity
@Table(name = "membres", indexes = {
    @Index(name = "idx_membre_telephone", columnList = "telephone"),
    @Index(name = "idx_membre_statut", columnList = "statut")
})
@NamedQueries({
    @NamedQuery(name = "Membre.findAllActive", query = "SELECT m FROM Membre m JOIN FETCH m.utilisateur u WHERE m.statut = sn.ucad.cotisations.model.StatutMembre.ACTIF"),
    @NamedQuery(name = "Membre.findByTelephone", query = "SELECT m FROM Membre m WHERE m.telephone = :telephone"),
    @NamedQuery(name = "Membre.countActive", query = "SELECT COUNT(m) FROM Membre m WHERE m.statut = sn.ucad.cotisations.model.StatutMembre.ACTIF")
})
public class Membre implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "utilisateur_id", referencedColumnName = "id", nullable = false, unique = true)
    private Utilisateur utilisateur;

    @Column(name = "nom", nullable = false, length = 100)
    private String nom;

    @Column(name = "prenom", nullable = false, length = 100)
    private String prenom;

    @Column(name = "telephone", nullable = false, unique = true, length = 20)
    private String telephone;

    @Column(name = "date_adhesion", nullable = false)
    private LocalDate dateAdhesion;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false, length = 20)
    private StatutMembre statut = StatutMembre.ACTIF;

    @OneToMany(mappedBy = "membre", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<Cotisation> cotisations = new ArrayList<>();

    @OneToMany(mappedBy = "membre", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<Amende> amendes = new ArrayList<>();

    @OneToMany(mappedBy = "membre", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<EmailLog> emailLogs = new ArrayList<>();

    public Membre() {
    }

    public Membre(Utilisateur utilisateur, String nom, String prenom, String telephone, LocalDate dateAdhesion) {
        this.utilisateur = utilisateur;
        this.nom = nom;
        this.prenom = prenom;
        this.telephone = telephone;
        this.dateAdhesion = dateAdhesion;
        this.statut = StatutMembre.ACTIF;
    }

    @PrePersist
    protected void onCreate() {
        if (this.dateAdhesion == null) {
            this.dateAdhesion = LocalDate.now();
        }
    }

    public String getNomComplet() {
        return prenom + " " + nom;
    }

    // Getters et Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Utilisateur getUtilisateur() {
        return utilisateur;
    }

    public void setUtilisateur(Utilisateur utilisateur) {
        this.utilisateur = utilisateur;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public LocalDate getDateAdhesion() {
        return dateAdhesion;
    }

    public void setDateAdhesion(LocalDate dateAdhesion) {
        this.dateAdhesion = dateAdhesion;
    }

    public StatutMembre getStatut() {
        return statut;
    }

    public void setStatut(StatutMembre statut) {
        this.statut = statut;
    }

    public List<Cotisation> getCotisations() {
        return cotisations;
    }

    public void setCotisations(List<Cotisation> cotisations) {
        this.cotisations = cotisations;
    }

    public List<Amende> getAmendes() {
        return amendes;
    }

    public void setAmendes(List<Amende> amendes) {
        this.amendes = amendes;
    }

    public List<EmailLog> getEmailLogs() {
        return emailLogs;
    }

    public void setEmailLogs(List<EmailLog> emailLogs) {
        this.emailLogs = emailLogs;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Membre membre = (Membre) o;
        return Objects.equals(id, membre.id) || Objects.equals(telephone, membre.telephone);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, telephone);
    }

    @Override
    public String toString() {
        return "Membre{" +
                "id=" + id +
                ", nom='" + nom + '\'' +
                ", prenom='" + prenom + '\'' +
                ", telephone='" + telephone + '\'' +
                ", dateAdhesion=" + dateAdhesion +
                ", statut=" + statut +
                '}';
    }
}
