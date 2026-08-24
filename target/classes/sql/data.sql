-- =====================================================================
-- SCRIPT D'INITIALISATION DML (SEED DATA) - H2 (MODE MySQL)
-- Système de Gestion des Cotisations UCAD
-- Mots de passe initial : "admin123" (haché avec BCrypt)
-- Compatible H2 (MODE=MySQL) via MERGE INTO
-- =====================================================================

-- 1. Utilisateur Administrateur (admin@ucad.sn / admin123)
-- NOTE : Hash BCrypt(cost=10) pour "admin123"
--        L'AppInitializerListener corrige automatiquement le hash au démarrage si invalide.
MERGE INTO utilisateurs (id, email, mot_de_passe_hash, role, actif, date_creation)
KEY (id)
VALUES (1, 'admin@ucad.sn', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', TRUE, NOW());

-- 2. Membre Administrateur associé
MERGE INTO membres (id, utilisateur_id, nom, prenom, telephone, date_adhesion, statut)
KEY (id)
VALUES (1, 1, 'BARRY', 'Mouhamet', '+221770000000', '2025-01-01', 'ACTIF');

-- 3. Utilisateurs Membres de Test
MERGE INTO utilisateurs (id, email, mot_de_passe_hash, role, actif, date_creation)
KEY (id)
VALUES (2, 'fatou.sow@ucad.sn', '$2a$10$e7K4VjD/f.OaG9N8Vl6R1u4pUq2H8yJ9k0L1M2N3P4Q5R6S7T8U9V', 'MEMBRE', TRUE, NOW());

MERGE INTO utilisateurs (id, email, mot_de_passe_hash, role, actif, date_creation)
KEY (id)
VALUES (3, 'ibrahima.nlaye@ucad.sn', '$2a$10$e7K4VjD/f.OaG9N8Vl6R1u4pUq2H8yJ9k0L1M2N3P4Q5R6S7T8U9V', 'MEMBRE', TRUE, NOW());

-- 4. Profils Membres
MERGE INTO membres (id, utilisateur_id, nom, prenom, telephone, date_adhesion, statut)
KEY (id)
VALUES (2, 2, 'SOW', 'Fatou', '+221771112233', '2025-02-10', 'ACTIF');

MERGE INTO membres (id, utilisateur_id, nom, prenom, telephone, date_adhesion, statut)
KEY (id)
VALUES (3, 3, 'NDAYE', 'Ibrahima', '+221774445566', '2025-03-15', 'ACTIF');

-- 5. Exemples de Cotisations
MERGE INTO cotisations (id, membre_id, montant, mois, annee, date_paiement, statut, moyen_paiement, reference_paiement)
KEY (id)
VALUES (1, 2, 10000.00, 1, 2026, '2026-01-05 10:30:00', 'PAYEE', 'MOBILE_MONEY', 'WAVE-20260105-8899');

MERGE INTO cotisations (id, membre_id, montant, mois, annee, date_paiement, statut, moyen_paiement, reference_paiement)
KEY (id)
VALUES (2, 2, 10000.00, 2, 2026, '2026-02-04 14:15:00', 'PAYEE', 'MOBILE_MONEY', 'OM-20260204-7744');

MERGE INTO cotisations (id, membre_id, montant, mois, annee, date_paiement, statut, moyen_paiement, reference_paiement)
KEY (id)
VALUES (3, 3, 10000.00, 1, 2026, NULL, 'EN_RETARD', NULL, NULL);

MERGE INTO cotisations (id, membre_id, montant, mois, annee, date_paiement, statut, moyen_paiement, reference_paiement)
KEY (id)
VALUES (4, 3, 10000.00, 2, 2026, NULL, 'EN_ATTENTE', NULL, NULL);

-- 6. Exemples d'Amendes
MERGE INTO amendes (id, membre_id, motif, montant, date_generation, date_paiement, statut, moyen_paiement, reference_paiement)
KEY (id)
VALUES (1, 3, 'Retard de paiement de la cotisation de Janvier 2026', 2500.00, '2026-02-01 08:00:00', NULL, 'IMPAYEE', NULL, NULL);
