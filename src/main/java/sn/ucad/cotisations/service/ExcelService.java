package sn.ucad.cotisations.service;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.*;
import sn.ucad.cotisations.config.AppConfig;
import sn.ucad.cotisations.model.Amende;
import sn.ucad.cotisations.model.Cotisation;
import sn.ucad.cotisations.model.Membre;

import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.logging.Logger;

/**
 * Service d'export Excel via Apache POI (.xlsx).
 */
public class ExcelService {

    private static final Logger LOGGER = Logger.getLogger(ExcelService.class.getName());
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    /** Exporte la liste des cotisations vers un fichier .xlsx. */
    public byte[] exportCotisations(List<Cotisation> cotisations) {
        String devise = AppConfig.getInstance().getDevise();
        try (XSSFWorkbook wb = new XSSFWorkbook()) {
            XSSFSheet sheet = wb.createSheet("Cotisations");

            // Styles
            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle dataStyle   = createDataStyle(wb);
            CellStyle paidStyle   = createColorStyle(wb, new XSSFColor(new byte[]{(byte)200, (byte)230, (byte)201}, null));
            CellStyle lateStyle   = createColorStyle(wb, new XSSFColor(new byte[]{(byte)255, (byte)205, (byte)210}, null));

            // Titre
            Row titleRow = sheet.createRow(0);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("Rapport des Cotisations — UCAD");
            CellStyle titleStyle = wb.createCellStyle();
            XSSFFont titleFont = wb.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 14);
            titleFont.setColor(new XSSFColor(new byte[]{(byte)26, (byte)35, (byte)126}, null));
            titleStyle.setFont(titleFont);
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));

            // En-têtes
            String[] headers = {"#", "Membre", "Email", "Période", "Montant (" + devise + ")", "Statut", "Date Paiement", "Moyen", "Référence"};
            Row headerRow = sheet.createRow(2);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Données
            int rowNum = 3;
            int num = 1;
            for (Cotisation c : cotisations) {
                Row row = sheet.createRow(rowNum++);
                CellStyle rowStyle = "PAYEE".equals(c.getStatut().name()) ? paidStyle :
                                     "EN_RETARD".equals(c.getStatut().name()) ? lateStyle : dataStyle;

                createCell(row, 0, String.valueOf(num++), rowStyle);
                createCell(row, 1, c.getMembre().getNomComplet(), rowStyle);
                createCell(row, 2, c.getMembre().getUtilisateur().getEmail(), rowStyle);
                createCell(row, 3, getNomMois(c.getMois()) + " " + c.getAnnee(), rowStyle);
                createCell(row, 4, c.getMontant().toPlainString(), rowStyle);
                createCell(row, 5, c.getStatut().name(), rowStyle);
                createCell(row, 6, c.getDatePaiement() != null ? c.getDatePaiement().format(DATE_FMT) : "—", rowStyle);
                createCell(row, 7, c.getMoyenPaiement() != null ? c.getMoyenPaiement().name() : "—", rowStyle);
                createCell(row, 8, c.getReferencePaiement() != null ? c.getReferencePaiement() : "—", rowStyle);
            }

            // Auto-largeur
            for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            wb.write(baos);
            return baos.toByteArray();
        } catch (Exception e) {
            LOGGER.severe("Erreur export Excel cotisations : " + e.getMessage());
            throw new RuntimeException("Impossible de générer le fichier Excel", e);
        }
    }

    /** Exporte l'annuaire des membres vers un fichier .xlsx. */
    public byte[] exportMembres(List<Membre> membres) {
        try (XSSFWorkbook wb = new XSSFWorkbook()) {
            XSSFSheet sheet = wb.createSheet("Membres");
            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle dataStyle   = createDataStyle(wb);

            Row titleRow = sheet.createRow(0);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("Annuaire des Membres UCAD");
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 5));

            String[] headers = {"#", "Nom", "Prénom", "Email", "Téléphone", "Date Adhésion", "Statut"};
            Row headerRow = sheet.createRow(2);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            int rowNum = 3;
            int num = 1;
            for (Membre m : membres) {
                Row row = sheet.createRow(rowNum++);
                createCell(row, 0, String.valueOf(num++), dataStyle);
                createCell(row, 1, m.getNom(), dataStyle);
                createCell(row, 2, m.getPrenom(), dataStyle);
                createCell(row, 3, m.getUtilisateur().getEmail(), dataStyle);
                createCell(row, 4, m.getTelephone(), dataStyle);
                createCell(row, 5, m.getDateAdhesion() != null ? m.getDateAdhesion().toString() : "—", dataStyle);
                createCell(row, 6, m.getStatut().name(), dataStyle);
            }

            for (int i = 0; i < headers.length; i++) sheet.autoSizeColumn(i);

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            wb.write(baos);
            return baos.toByteArray();
        } catch (Exception e) {
            LOGGER.severe("Erreur export Excel membres : " + e.getMessage());
            throw new RuntimeException("Impossible de générer le fichier Excel membres", e);
        }
    }

    private CellStyle createHeaderStyle(XSSFWorkbook wb) {
        CellStyle style = wb.createCellStyle();
        XSSFFont font = wb.createFont();
        font.setBold(true);
        font.setColor(new XSSFColor(new byte[]{(byte)255,(byte)255,(byte)255}, null));
        style.setFont(font);
        style.setFillForegroundColor(new XSSFColor(new byte[]{(byte)26,(byte)35,(byte)126}, null));
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderBottom(BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }

    private CellStyle createDataStyle(XSSFWorkbook wb) {
        CellStyle style = wb.createCellStyle();
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private CellStyle createColorStyle(XSSFWorkbook wb, XSSFColor color) {
        CellStyle style = wb.createCellStyle();
        style.setFillForegroundColor(color);
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderBottom(BorderStyle.THIN);
        return style;
    }

    private void createCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value);
        cell.setCellStyle(style);
    }

    private String getNomMois(int mois) {
        String[] noms = {"","Janvier","Février","Mars","Avril","Mai","Juin",
                "Juillet","Août","Septembre","Octobre","Novembre","Décembre"};
        return (mois >= 1 && mois <= 12) ? noms[mois] : String.valueOf(mois);
    }
}
