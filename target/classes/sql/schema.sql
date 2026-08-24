-- =====================================================================
-- SCRIPT DE CRÉATION DDL - BASE DE DONNÉES MYSQL 8
-- Système de Gestion des Cotisations UCAD
-- =====================================================================

CREATE DATABASE IF NOT EXISTS cotisations_db 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE cotisations_db;

-- ---------------------------------------------------------------------
-- 1. Table: utilisateurs
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS utilisateurs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    mot_de_passe_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    actif BOOLEAN NOT NULL DEFAULT TRUE,
    date_creation DATETIME NOT NULL,
    INDEX idx_utilisateur_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. Table: membres
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS membres (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id BIGINT NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20) NOT NULL UNIQUE,
    date_adhesion DATE NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'ACTIF',
    INDEX idx_membre_telephone (telephone),
    INDEX idx_membre_statut (statut),
    CONSTRAINT fk_membre_utilisateur FOREIGN KEY (utilisateur_id) 
        REFERENCES utilisateurs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. Table: cotisations
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cotisations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    membre_id BIGINT NOT NULL,
    montant DECIMAL(12, 2) NOT NULL,
    mois INT NOT NULL,
    annee INT NOT NULL,
    date_paiement DATETIME NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'EN_ATTENTE',
    moyen_paiement VARCHAR(30) NULL,
    reference_paiement VARCHAR(100) NULL,
    INDEX idx_cotisation_periode (annee, mois),
    INDEX idx_cotisation_statut (statut),
    INDEX idx_cotisation_membre (membre_id),
    CONSTRAINT fk_cotisation_membre FOREIGN KEY (membre_id) 
        REFERENCES membres(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. Table: amendes
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS amendes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    membre_id BIGINT NOT NULL,
    motif VARCHAR(255) NOT NULL,
    montant DECIMAL(12, 2) NOT NULL,
    date_generation DATETIME NOT NULL,
    date_paiement DATETIME NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'IMPAYEE',
    moyen_paiement VARCHAR(30) NULL,
    reference_paiement VARCHAR(100) NULL,
    INDEX idx_amende_membre (membre_id),
    INDEX idx_amende_statut (statut),
    CONSTRAINT fk_amende_membre FOREIGN KEY (membre_id) 
        REFERENCES membres(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. Table: email_logs
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS email_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    membre_id BIGINT NULL,
    destinataire VARCHAR(150) NOT NULL,
    sujet VARCHAR(200) NOT NULL,
    contenu TEXT NULL,
    date_envoi DATETIME NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'ENVOYE',
    erreur_message VARCHAR(500) NULL,
    INDEX idx_emaillog_destinataire (destinataire),
    INDEX idx_emaillog_statut (statut),
    CONSTRAINT fk_emaillog_membre FOREIGN KEY (membre_id) 
        REFERENCES membres(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
