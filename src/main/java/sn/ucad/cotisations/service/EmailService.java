package sn.ucad.cotisations.service;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import sn.ucad.cotisations.config.AppConfig;
import sn.ucad.cotisations.dao.EmailLogDao;
import sn.ucad.cotisations.model.Cotisation;
import sn.ucad.cotisations.model.Membre;

import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service d'envoi d'e-mails via SMTP (Jakarta Mail).
 */
public class EmailService {

    private static final Logger LOGGER = Logger.getLogger(EmailService.class.getName());
    private final EmailLogDao emailLogDao = new EmailLogDao();

    /**
     * Envoie un e-mail brut et le trace dans email_logs.
     */
    public boolean sendEmail(Membre membre, String destinataire, String sujet, String contenu) {
        AppConfig cfg = AppConfig.getInstance();
        Properties props = new Properties();
        props.put("mail.smtp.host", cfg.getSmtpHost());
        props.put("mail.smtp.port", String.valueOf(cfg.getSmtpPort()));
        props.put("mail.smtp.auth", String.valueOf(cfg.isSmtpAuth()));
        props.put("mail.smtp.starttls.enable", String.valueOf(cfg.isSmtpStarttls()));

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(cfg.getSmtpUsername(), cfg.getSmtpPassword());
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(cfg.getMailFrom(), "UCAD Cotisations"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinataire));
            message.setSubject(sujet, "UTF-8");

            MimeBodyPart textPart = new MimeBodyPart();
            textPart.setContent(contenu, "text/html; charset=UTF-8");
            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(textPart);
            message.setContent(multipart);

            Transport.send(message);
            emailLogDao.logEmail(membre, destinataire, sujet, contenu, true, null);
            LOGGER.info("E-mail envoyé à : " + destinataire);
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Échec envoi e-mail à " + destinataire, e);
            emailLogDao.logEmail(membre, destinataire, sujet, contenu, false, e.getMessage());
            return false;
        }
    }

    /** Envoie un rappel de cotisation en retard. */
    public boolean sendRappelCotisation(Membre membre, Cotisation cotisation) {
        String devise = AppConfig.getInstance().getDevise();
        String sujet = "[UCAD] Rappel : Cotisation en retard - " + getNomMois(cotisation.getMois()) + " " + cotisation.getAnnee();
        String contenu = buildEmailHtml(
            "Rappel de Cotisation",
            "Bonjour " + membre.getPrenom() + " " + membre.getNom() + ",",
            "Votre cotisation du mois de <strong>" + getNomMois(cotisation.getMois()) + " " + cotisation.getAnnee() +
            "</strong> d'un montant de <strong>" + cotisation.getMontant() + " " + devise + "</strong> n'a pas encore été réglée." +
            "<br><br>Merci de régulariser votre situation dès que possible.",
            "⚠️ Cotisation en retard"
        );
        String email = membre.getUtilisateur().getEmail();
        return sendEmail(membre, email, sujet, contenu);
    }

    /** Envoie une confirmation de paiement de cotisation. */
    public boolean sendConfirmationPaiement(Membre membre, Cotisation cotisation) {
        String devise = AppConfig.getInstance().getDevise();
        String sujet = "[UCAD] Confirmation de paiement - " + getNomMois(cotisation.getMois()) + " " + cotisation.getAnnee();
        String contenu = buildEmailHtml(
            "Paiement Confirmé ✅",
            "Bonjour " + membre.getPrenom() + " " + membre.getNom() + ",",
            "Nous confirmons la réception de votre cotisation de <strong>" + getNomMois(cotisation.getMois()) +
            " " + cotisation.getAnnee() + "</strong> :<br><br>" +
            "Montant : <strong>" + cotisation.getMontant() + " " + devise + "</strong><br>" +
            "Moyen de paiement : <strong>" + (cotisation.getMoyenPaiement() != null ? cotisation.getMoyenPaiement() : "N/A") + "</strong><br>" +
            "Référence : <strong>" + (cotisation.getReferencePaiement() != null ? cotisation.getReferencePaiement() : "N/A") + "</strong>",
            "✅ Paiement reçu"
        );
        String email = membre.getUtilisateur().getEmail();
        return sendEmail(membre, email, sujet, contenu);
    }

    /**
     * Envoie l'e-mail de bienvenue à un nouveau membre avec son mot de passe initial en clair
     * et le lien pour le modifier.
     */
    public boolean sendBienvenueNouveauMembre(Membre membre, String motDePasseClair, String urlChangement) {
        String sujet = "[UCAD Cotisations] Bienvenue ! Vos accès à la plateforme";
        String corps = "Bienvenue au sein du système de gestion des cotisations de l'UCAD.<br><br>" +
                "Votre compte adhérent a été créé avec succès par l'administrateur. Voici vos identifiants de première connexion :<br><br>" +
                "<div style='background:#f1f5f9;border:1px solid #cbd5e1;padding:16px;border-radius:8px;margin:16px 0;'>" +
                "&bull; <strong>Identifiant (Email) :</strong> <code style='color:#0f766e;font-size:14px;font-weight:bold'>" + membre.getUtilisateur().getEmail() + "</code><br>" +
                "&bull; <strong>Mot de passe initial :</strong> <code style='color:#b45309;font-size:14px;font-weight:bold'>" + motDePasseClair + "</code>" +
                "</div>" +
                "Pour des raisons de sécurité, nous vous recommandons fortement de changer ce mot de passe dès votre première connexion en cliquant sur le bouton ci-dessous :<br><br>" +
                "<div style='text-align:center;margin:24px 0;'>" +
                "<a href='" + urlChangement + "' style='background:#0f766e;color:#ffffff;text-decoration:none;padding:12px 24px;border-radius:8px;font-weight:bold;display:inline-block;box-shadow:0 4px 12px rgba(15,118,110,0.25);'>" +
                "🔐 Changer mon mot de passe" +
                "</a>" +
                "</div>" +
                "<small style='color:#64748b;'>Si le bouton ne fonctionne pas, vous pouvez copier-coller ce lien dans votre navigateur :<br>" +
                "<a href='" + urlChangement + "' style='color:#0f766e;'>" + urlChangement + "</a></small>";

        String contenu = buildEmailHtml(
            "Bienvenue à l'UCAD Cotisations",
            "Bonjour " + membre.getPrenom() + " " + membre.getNom() + ",",
            corps,
            "🎉 Nouveau Compte"
        );
        String email = membre.getUtilisateur().getEmail();
        return sendEmail(membre, email, sujet, contenu);
    }

    private String buildEmailHtml(String titre, String salutation, String corps, String badge) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head><body style='font-family:Arial,sans-serif;background:#f5f5f5;padding:20px'>" +
               "<div style='max-width:600px;margin:0 auto;background:white;border-radius:8px;overflow:hidden;box-shadow:0 2px 10px rgba(0,0,0,0.1)'>" +
               "<div style='background:#1a237e;color:white;padding:24px;text-align:center'>" +
               "<h1 style='margin:0;font-size:20px'>UCAD — Gestion des Cotisations</h1>" +
               "<span style='background:rgba(255,255,255,0.2);padding:4px 12px;border-radius:20px;font-size:13px'>" + badge + "</span></div>" +
               "<div style='padding:32px'>" +
               "<h2 style='color:#1a237e'>" + titre + "</h2>" +
               "<p style='color:#555'>" + salutation + "</p>" +
               "<p style='color:#444;line-height:1.6'>" + corps + "</p>" +
               "</div>" +
               "<div style='background:#f5f5f5;padding:16px;text-align:center;color:#999;font-size:12px'>" +
               "Université Cheikh Anta Diop — Système de Gestion des Cotisations</div></div></body></html>";
    }

    private String getNomMois(int mois) {
        String[] noms = {"", "Janvier","Février","Mars","Avril","Mai","Juin",
                "Juillet","Août","Septembre","Octobre","Novembre","Décembre"};
        return (mois >= 1 && mois <= 12) ? noms[mois] : String.valueOf(mois);
    }
}
