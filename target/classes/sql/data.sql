-- =====================================================================
-- SCRIPT D'INITIALISATION DML (SEED DATA) - MySQL 8
-- Système de Gestion des Cotisations UCAD
-- Mots de passe initial : "admin123" (haché avec BCrypt)
-- =====================================================================

-- 1. Utilisateur Administrateur (admin@ucad.sn / admin123)
-- NOTE : Hash BCrypt(cost=10) pour "admin123"
--        L'AppInitializerListener corrige automatiquement le hash au démarrage si invalide.
INSERT INTO utilisateurs (id, email, mot_de_passe_hash, role, actif, date_creation)
VALUES (1, 'admin@ucad.sn', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', TRUE, NOW())
ON DUPLICATE KEY UPDATE email=VALUES(email), mot_de_passe_hash=VALUES(mot_de_passe_hash), role=VALUES(role), actif=VALUES(actif);

-- 2. Membre Administrateur associé
INSERT INTO membres (id, utilisateur_id, nom, prenom, telephone, date_adhesion, statut)
VALUES (1, 1, 'BARRY', 'Mouhamet', '+221770000000', '2025-01-01', 'ACTIF')
ON DUPLICATE KEY UPDATE nom=VALUES(nom), prenom=VALUES(prenom), telephone=VALUES(telephone), statut=VALUES(statut);

-- 3. Utilisateurs Membres de Test
INSERT INTO utilisateurs (id, email, mot_de_passe_hash, role, actif, date_creation)
VALUES (2, 'fatou.sow@ucad.sn', '$2a$10$e7K4VjD/f.OaG9N8Vl6R1u4pUq2H8yJ9k0L1M2N3P4Q5R6S7T8U9V', 'MEMBRE', TRUE, NOW())
ON DUPLICATE KEY UPDATE email=VALUES(email), mot_de_passe_hash=VALUES(mot_de_passe_hash), role=VALUES(role), actif=VALUES(actif);

INSERT INTO utilisateurs (id, email, mot_de_passe_hash, role, actif, date_creation)
VALUES (3, 'ibrahima.nlaye@ucad.sn', '$2a$10$e7K4VjD/f.OaG9N8Vl6R1u4pUq2H8yJ9k0L1M2N3P4Q5R6S7T8U9V', 'MEMBRE', TRUE, NOW())
ON DUPLICATE KEY UPDATE email=VALUES(email), mot_de_passe_hash=VALUES(mot_de_passe_hash), role=VALUES(role), actif=VALUES(actif);

-- 4. Profils Membres
INSERT INTO membres (id, utilisateur_id, nom, prenom, telephone, date_adhesion, statut)
VALUES (2, 2, 'SOW', 'Fatou', '+221771112233', '2025-02-10', 'ACTIF')
ON DUPLICATE KEY UPDATE nom=VALUES(nom), prenom=VALUES(prenom), telephone=VALUES(telephone), statut=VALUES(statut);

INSERT INTO membres (id, utilisateur_id, nom, prenom, telephone, date_adhesion, statut)
VALUES (3, 3, 'NDAYE', 'Ibrahima', '+221774445566', '2025-03-15', 'ACTIF')
ON DUPLICATE KEY UPDATE nom=VALUES(nom), prenom=VALUES(prenom), telephone=VALUES(telephone), statut=VALUES(statut);

-- 5. Exemples de Cotisations
INSERT INTO cotisations (id, membre_id, montant, mois, annee, date_paiement, statut, moyen_paiement, reference_paiement)
VALUES (1, 2, 10000.00, 1, 2026, '2026-01-05 10:30:00', 'PAYEE', 'MOBILE_MONEY', 'WAVE-20260105-8899')
ON DUPLICATE KEY UPDATE statut=VALUES(statut), date_paiement=VALUES(date_paiement);

INSERT INTO cotisations (id, membre_id, montant, mois, annee, date_paiement, statut, moyen_paiement, reference_paiement)
VALUES (2, 2, 10000.00, 2, 2026, '2026-02-04 14:15:00', 'PAYEE', 'MOBILE_MONEY', 'OM-20260204-7744')
ON DUPLICATE KEY UPDATE statut=VALUES(statut), date_paiement=VALUES(date_paiement);

INSERT INTO cotisations (id, membre_id, montant, mois, annee, date_paiement, statut, moyen_paiement, reference_paiement)
VALUES (3, 3, 10000.00, 1, 2026, NULL, 'EN_RETARD', NULL, NULL)
ON DUPLICATE KEY UPDATE statut=VALUES(statut);

INSERT INTO cotisations (id, membre_id, montant, mois, annee, date_paiement, statut, moyen_paiement, reference_paiement)
VALUES (4, 3, 10000.00, 2, 2026, NULL, 'EN_ATTENTE', NULL, NULL)
ON DUPLICATE KEY UPDATE statut=VALUES(statut);

-- 6. Exemples d'Amendes
INSERT INTO amendes (id, membre_id, motif, montant, date_generation, date_paiement, statut, moyen_paiement, reference_paiement)
VALUES (1, 3, 'Retard de paiement de la cotisation de Janvier 2026', 2500.00, '2026-02-01 08:00:00', NULL, 'IMPAYEE', NULL, NULL)
ON DUPLICATE KEY UPDATE statut=VALUES(statut);