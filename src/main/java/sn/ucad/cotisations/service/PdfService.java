package sn.ucad.cotisations.service;

import com.lowagie.text.*;
import com.lowagie.text.Font;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.*;
import sn.ucad.cotisations.config.AppConfig;
import sn.ucad.cotisations.model.Amende;
import sn.ucad.cotisations.model.Cotisation;
import sn.ucad.cotisations.model.Membre;

import java.awt.*;
import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.logging.Logger;

/**
 * Service de génération de documents PDF via OpenPDF.
 */
public class PdfService {

    private static final Logger LOGGER = Logger.getLogger(PdfService.class.getName());
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final Color COLOR_PRIMARY  = new Color(26, 35, 126);   // Bleu UCAD
    private static final Color COLOR_ACCENT   = new Color(245, 127, 23);  // Orange
    private static final Color COLOR_HEADER   = new Color(232, 234, 246); // Bleu clair
    private static final Color COLOR_TEXT     = new Color(33, 33, 33);

    /** Génère un reçu de paiement de cotisation. */
    public byte[] generateRecuCotisation(Cotisation cotisation) {
        Membre membre = cotisation.getMembre();
        String devise = AppConfig.getInstance().getDevise();
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        Document doc = new Document(PageSize.A5, 36, 36, 36, 36);
        try {
            PdfWriter writer = PdfWriter.getInstance(doc, baos);
            doc.open();

            // En-tête
            Font fontTitre  = new Font(Font.HELVETICA, 16, Font.BOLD, COLOR_PRIMARY);
            Font fontSous   = new Font(Font.HELVETICA, 10, Font.NORMAL, Color.GRAY);
            Font fontLabel  = new Font(Font.HELVETICA, 9, Font.BOLD, COLOR_TEXT);
            Font fontValeur = new Font(Font.HELVETICA, 9, Font.NORMAL, COLOR_TEXT);
            Font fontMontant = new Font(Font.HELVETICA, 18, Font.BOLD, COLOR_PRIMARY);

            Paragraph titre = new Paragraph("REÇU DE COTISATION", fontTitre);
            titre.setAlignment(Element.ALIGN_CENTER);
            doc.add(titre);

            Paragraph ucad = new Paragraph("Université Cheikh Anta Diop — UCAD", fontSous);
            ucad.setAlignment(Element.ALIGN_CENTER);
            doc.add(ucad);

            doc.add(new Paragraph(" "));

            // Tableau infos
            PdfPTable table = new PdfPTable(2);
            table.setWidthPercentage(100);
            table.setSpacingBefore(10);

            addRow(table, "Membre :", membre.getNomComplet(), fontLabel, fontValeur);
            addRow(table, "Email :", membre.getUtilisateur().getEmail(), fontLabel, fontValeur);
            addRow(table, "Téléphone :", membre.getTelephone(), fontLabel, fontValeur);
            addRow(table, "Période :", getNomMois(cotisation.getMois()) + " " + cotisation.getAnnee(), fontLabel, fontValeur);
            addRow(table, "Date de paiement :", cotisation.getDatePaiement() != null ?
                    cotisation.getDatePaiement().format(DATE_FMT) : "N/A", fontLabel, fontValeur);
            addRow(table, "Moyen de paiement :", cotisation.getMoyenPaiement() != null ?
                    cotisation.getMoyenPaiement().name() : "N/A", fontLabel, fontValeur);
            addRow(table, "Référence :", cotisation.getReferencePaiement() != null ?
                    cotisation.getReferencePaiement() : "—", fontLabel, fontValeur);
            doc.add(table);

            doc.add(new Paragraph(" "));

            // Montant en grand
            Paragraph montantPara = new Paragraph("Montant : " + cotisation.getMontant() + " " + devise, fontMontant);
            montantPara.setAlignment(Element.ALIGN_CENTER);
            doc.add(montantPara);

            doc.add(new Paragraph(" "));
            Font fontStatut = new Font(Font.HELVETICA, 10, Font.BOLD, new Color(46, 125, 50));
            Paragraph statut = new Paragraph("✔ COTISATION RÉGLÉE", fontStatut);
            statut.setAlignment(Element.ALIGN_CENTER);
            doc.add(statut);

        } catch (Exception e) {
            LOGGER.severe("Erreur génération PDF reçu cotisation : " + e.getMessage());
            throw new RuntimeException("Impossible de générer le PDF", e);
        } finally {
            doc.close();
        }
        return baos.toByteArray();
    }

    /** Génère un bilan mensuel des cotisations en PDF. */
    public byte[] generateBilanMensuel(int annee, int mois, List<Cotisation> cotisations) {
        String devise = AppConfig.getInstance().getDevise();
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document doc = new Document(PageSize.A4, 36, 36, 36, 36);

        try {
            PdfWriter.getInstance(doc, baos);
            doc.open();

            Font fontTitre  = new Font(Font.HELVETICA, 18, Font.BOLD, COLOR_PRIMARY);
            Font fontSous   = new Font(Font.HELVETICA, 11, Font.NORMAL, Color.GRAY);
            Font fontHeader = new Font(Font.HELVETICA, 9, Font.BOLD, COLOR_PRIMARY);
            Font fontCell   = new Font(Font.HELVETICA, 9, Font.NORMAL, COLOR_TEXT);

            Paragraph titre = new Paragraph("Bilan Mensuel — " + getNomMois(mois) + " " + annee, fontTitre);
            titre.setAlignment(Element.ALIGN_CENTER);
            doc.add(titre);

            Paragraph ucad = new Paragraph("Système de Gestion des Cotisations UCAD", fontSous);
            ucad.setAlignment(Element.ALIGN_CENTER);
            doc.add(ucad);
            doc.add(new Paragraph(" "));

            PdfPTable table = new PdfPTable(5);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{3f, 2f, 2f, 2f, 2.5f});

            // En-tête tableau
            String[] headers = {"Membre", "Montant", "Statut", "Date Paiement", "Moyen"};
            for (String h : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(h, fontHeader));
                cell.setBackgroundColor(COLOR_HEADER);
                cell.setPadding(6);
                table.addCell(cell);
            }

            java.math.BigDecimal total = java.math.BigDecimal.ZERO;
            int payees = 0;
            for (Cotisation c : cotisations) {
                table.addCell(new PdfPCell(new Phrase(c.getMembre().getNomComplet(), fontCell)));
                table.addCell(new PdfPCell(new Phrase(c.getMontant() + " " + devise, fontCell)));
                PdfPCell statutCell = new PdfPCell(new Phrase(c.getStatut().name(), fontCell));
                if ("PAYEE".equals(c.getStatut().name())) {
                    statutCell.setBackgroundColor(new Color(200, 230, 201));
                    total = total.add(c.getMontant());
                    payees++;
                } else if ("EN_RETARD".equals(c.getStatut().name())) {
                    statutCell.setBackgroundColor(new Color(255, 205, 210));
                }
                table.addCell(statutCell);
                table.addCell(new PdfPCell(new Phrase(c.getDatePaiement() != null ?
                        c.getDatePaiement().format(DATE_FMT) : "—", fontCell)));
                table.addCell(new PdfPCell(new Phrase(c.getMoyenPaiement() != null ?
                        c.getMoyenPaiement().name() : "—", fontCell)));
            }
            doc.add(table);
            doc.add(new Paragraph(" "));

            Font fontResume = new Font(Font.HELVETICA, 10, Font.BOLD, COLOR_PRIMARY);
            doc.add(new Paragraph("Total encaissé : " + total + " " + devise +
                    " (" + payees + " / " + cotisations.size() + " cotisations payées)", fontResume));

        } catch (Exception e) {
            LOGGER.severe("Erreur génération bilan PDF : " + e.getMessage());
            throw new RuntimeException("Impossible de générer le bilan PDF", e);
        } finally {
            doc.close();
        }
        return baos.toByteArray();
    }

    private void addRow(PdfPTable table, String label, String valeur, Font fl, Font fv) {
        PdfPCell c1 = new PdfPCell(new Phrase(label, fl));
        c1.setBorder(Rectangle.BOTTOM);
        c1.setPadding(6);
        PdfPCell c2 = new PdfPCell(new Phrase(valeur, fv));
        c2.setBorder(Rectangle.BOTTOM);
        c2.setPadding(6);
        table.addCell(c1);
        table.addCell(c2);
    }

    private String getNomMois(int mois) {
        String[] noms = {"","Janvier","Février","Mars","Avril","Mai","Juin",
                "Juillet","Août","Septembre","Octobre","Novembre","Décembre"};
        return (mois >= 1 && mois <= 12) ? noms[mois] : String.valueOf(mois);
    }
}
