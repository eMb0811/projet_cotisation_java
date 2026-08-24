package sn.ucad.cotisations.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Entité JPA pour le journal de traçabilité des e-mails envoyés.
 */
@Entity
@Table(name = "email_logs", indexes = {
    @Index(name = "idx_emaillog_destinataire", columnList = "destinataire"),
    @Index(name = "idx_emaillog_statut", columnList = "statut")
})
@NamedQueries({
    @NamedQuery(name = "EmailLog.findByMembre", query = "SELECT e FROM EmailLog e LEFT JOIN FETCH e.membre m LEFT JOIN FETCH m.utilisateur u WHERE e.membre.id = :membreId ORDER BY e.dateEnvoi DESC"),
    @NamedQuery(name = "EmailLog.findAllRecent", query = "SELECT e FROM EmailLog e LEFT JOIN FETCH e.membre m LEFT JOIN FETCH m.utilisateur u ORDER BY e.dateEnvoi DESC")
})
public class EmailLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "membre_id", referencedColumnName = "id")
    private Membre membre;

    @Column(name = "destinataire", nullable = false, length = 150)
    private String destinataire;

    @Column(name = "sujet", nullable = false, length = 200)
    private String sujet;

    @Lob
    @Column(name = "contenu", columnDefinition = "TEXT")
    private String contenu;

    @Column(name = "date_envoi", nullable = false, updatable = false)
    private LocalDateTime dateEnvoi;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false, length = 20)
    private StatutNotification statut = StatutNotification.ENVOYE;

    @Column(name = "erreur_message", length = 500)
    private String erreurMessage;

    public EmailLog() {
    }

    public EmailLog(Membre membre, String destinataire, String sujet, String contenu, StatutNotification statut) {
        this.membre = membre;
        this.destinataire = destinataire;
        this.sujet = sujet;
        this.contenu = contenu;
        this.statut = statut;
    }

    @PrePersist
    protected void onCreate() {
        this.dateEnvoi = LocalDateTime.now();
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

    public String getDestinataire() {
        return destinataire;
    }

    public void setDestinataire(String destinataire) {
        this.destinataire = destinataire;
    }

    public String getSujet() {
        return sujet;
    }

    public void setSujet(String sujet) {
        this.sujet = sujet;
    }

    public String getContenu() {
        return contenu;
    }

    public void setContenu(String contenu) {
        this.contenu = contenu;
    }

    public LocalDateTime getDateEnvoi() {
        return dateEnvoi;
    }

    public void setDateEnvoi(LocalDateTime dateEnvoi) {
        this.dateEnvoi = dateEnvoi;
    }

    public StatutNotification getStatut() {
        return statut;
    }

    public void setStatut(StatutNotification statut) {
        this.statut = statut;
    }

    public String getErreurMessage() {
        return erreurMessage;
    }

    public void setErreurMessage(String erreurMessage) {
        this.erreurMessage = erreurMessage;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        EmailLog emailLog = (EmailLog) o;
        return Objects.equals(id, emailLog.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "EmailLog{" +
                "id=" + id +
                ", destinataire='" + destinataire + '\'' +
                ", sujet='" + sujet + '\'' +
                ", dateEnvoi=" + dateEnvoi +
                ", statut=" + statut +
                '}';
    }
}
