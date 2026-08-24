package sn.ucad.cotisations.service;

import sn.ucad.cotisations.config.AppConfig;
import sn.ucad.cotisations.dao.AmendeDao;
import sn.ucad.cotisations.dao.MembreDao;
import sn.ucad.cotisations.model.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;

/**
 * Service métier pour la gestion des amendes.
 */
public class AmendeService {

    private static final Logger LOGGER = Logger.getLogger(AmendeService.class.getName());
    private final AmendeDao amendeDao = new AmendeDao();
    private final MembreDao membreDao = new MembreDao();

    public List<Amende> getAllAmendes() {
        return amendeDao.findAll();
    }

    public List<Amende> getAmendesByMembre(Long membreId) {
        return amendeDao.findByMembre(membreId);
    }

    public List<Amende> getAmendesImpayees() {
        return amendeDao.findAllUnpaid();
    }

    public Optional<Amende> getAmendeById(Long id) {
        return amendeDao.findById(id);
    }

    public BigDecimal getTotalAmendesImpayees() {
        return amendeDao.sumTotalUnpaid();
    }

    public long countAmendesImpayees() {
        return amendeDao.countByStatut(StatutAmende.IMPAYEE);
    }

    /**
     * Crée manuellement une amende pour un membre.
     */
    public Amende createAmende(Long membreId, String motif, BigDecimal montant) {
        Membre membre = membreDao.findById(membreId)
                .orElseThrow(() -> new IllegalArgumentException("Membre introuvable : " + membreId));
        if (motif == null || motif.isBlank()) {
            throw new IllegalArgumentException("Le motif de l'amende est obligatoire.");
        }
        if (montant == null || montant.compareTo(BigDecimal.ZERO) <= 0) {
            BigDecimal defaut = AppConfig.getInstance().getAmendeMontantDefaut();
            montant = defaut;
        }
        Amende amende = new Amende(membre, motif.trim(), montant);
        return amendeDao.save(amende);
    }

    /**
     * Enregistre le paiement d'une amende.
     */
    public Amende payerAmende(Long amendeId, MoyenPaiement moyen, String reference) {
        Amende a = amendeDao.findById(amendeId)
                .orElseThrow(() -> new IllegalArgumentException("Amende introuvable : " + amendeId));

        if (StatutAmende.PAYEE.equals(a.getStatut())) {
            throw new IllegalStateException("Cette amende est déjà réglée.");
        }

        a.setStatut(StatutAmende.PAYEE);
        a.setDatePaiement(LocalDateTime.now());
        a.setMoyenPaiement(moyen);
        a.setReferencePaiement(reference != null ? reference.trim() : null);
        return amendeDao.update(a);
    }
}
