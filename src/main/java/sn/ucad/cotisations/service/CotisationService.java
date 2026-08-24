package sn.ucad.cotisations.service;

import sn.ucad.cotisations.config.AppConfig;
import sn.ucad.cotisations.dao.AmendeDao;
import sn.ucad.cotisations.dao.CotisationDao;
import sn.ucad.cotisations.dao.MembreDao;
import sn.ucad.cotisations.model.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;

/**
 * Service métier pour la gestion des cotisations.
 */
public class CotisationService {

    private static final Logger LOGGER = Logger.getLogger(CotisationService.class.getName());
    private final CotisationDao cotisationDao = new CotisationDao();
    private final MembreDao membreDao = new MembreDao();
    private final AmendeDao amendeDao = new AmendeDao();

    public List<Cotisation> getAllCotisations() {
        return cotisationDao.findAll();
    }

    public List<Cotisation> getCotisationsByMembre(Long membreId) {
        return cotisationDao.findByMembre(membreId);
    }

    public List<Cotisation> getCotisationsByPeriode(int annee, int mois) {
        return cotisationDao.findByPeriode(annee, mois);
    }

    public Optional<Cotisation> getCotisationById(Long id) {
        return cotisationDao.findById(id);
    }

    public BigDecimal getTotalCotisationsPayees() {
        return cotisationDao.sumTotalPaid();
    }

    public long countEnAttente() {
        return cotisationDao.countByStatut(StatutCotisation.EN_ATTENTE);
    }

    public long countEnRetard() {
        return cotisationDao.countByStatut(StatutCotisation.EN_RETARD);
    }

    /**
     * Génère les cotisations mensuelles pour tous les membres actifs avec un montant optionnel personnalisé.
     * Ignore les membres ayant déjà une cotisation pour cette période.
     * @return nombre de cotisations créées.
     */
    public int genererCotisationsMensuelles(int annee, int mois, BigDecimal montantOptionnel) {
        BigDecimal montant = (montantOptionnel != null && montantOptionnel.compareTo(BigDecimal.ZERO) > 0)
                ? montantOptionnel
                : AppConfig.getInstance().getCotisationMontantDefaut();
        List<Membre> membres = membreDao.findAllActive();
        List<Cotisation> nouvelles = new ArrayList<>();

        for (Membre m : membres) {
            if (!cotisationDao.existsByMembreAndPeriode(m.getId(), annee, mois)) {
                nouvelles.add(new Cotisation(m, montant, mois, annee));
            }
        }
        if (!nouvelles.isEmpty()) {
            cotisationDao.saveAll(nouvelles);
        }
        LOGGER.info("Génération cotisations " + mois + "/" + annee + " (montant: " + montant + ") : " + nouvelles.size() + " créée(s).");
        return nouvelles.size();
    }

    public int genererCotisationsMensuelles(int annee, int mois) {
        return genererCotisationsMensuelles(annee, mois, null);
    }

    /**
     * Enregistre le paiement d'une cotisation.
     */
    public Cotisation payerCotisation(Long cotisationId, MoyenPaiement moyen, String reference) {
        Cotisation c = cotisationDao.findById(cotisationId)
                .orElseThrow(() -> new IllegalArgumentException("Cotisation introuvable : " + cotisationId));

        if (StatutCotisation.PAYEE.equals(c.getStatut())) {
            throw new IllegalStateException("Cette cotisation est déjà payée.");
        }

        c.setStatut(StatutCotisation.PAYEE);
        c.setDatePaiement(LocalDateTime.now());
        c.setMoyenPaiement(moyen);
        c.setReferencePaiement(reference != null ? reference.trim() : null);
        return cotisationDao.update(c);
    }

    /**
     * Détecte les cotisations EN_ATTENTE de la période et les passe EN_RETARD.
     * Génère automatiquement une amende pour chaque retard.
     * @return nombre de retards traités.
     */
    public int detecterEtTraiterRetards(int annee, int mois) {
        BigDecimal montantAmende = AppConfig.getInstance().getAmendeMontantDefaut();
        List<Cotisation> enAttente = cotisationDao.findByPeriode(annee, mois);
        int count = 0;

        for (Cotisation c : enAttente) {
            if (StatutCotisation.EN_ATTENTE.equals(c.getStatut())) {
                c.setStatut(StatutCotisation.EN_RETARD);
                cotisationDao.update(c);

                // Générer amende si pas encore d'amende pour cette cotisation
                String motif = "Retard de paiement de la cotisation de " +
                        getNomMois(mois) + " " + annee;
                Amende amende = new Amende(c.getMembre(), motif, montantAmende);
                amendeDao.save(amende);
                count++;
            }
        }
        LOGGER.info("Retards traités pour " + mois + "/" + annee + " : " + count);
        return count;
    }

    private String getNomMois(int mois) {
        String[] mois_noms = {"", "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
                "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"};
        return (mois >= 1 && mois <= 12) ? mois_noms[mois] : String.valueOf(mois);
    }
}
