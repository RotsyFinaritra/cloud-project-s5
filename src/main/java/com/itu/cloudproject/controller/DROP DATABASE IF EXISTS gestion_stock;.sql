DROP DATABASE IF EXISTS gestion_stock;

CREATE DATABASE gestion_stock;

\ c gestion_stock;

-- =========================
-- TABLES DE BASE (ENTITÉS)
-- =========================
-- CORRECTION 2: Table PRODUIT ajoutée (référencée dans tous les détails mais n'existait pas)
CREATE TABLE produit (
    id BIGSERIAL PRIMARY KEY,
    nom VARCHAR(200) NOT NULL,
    reference VARCHAR(50) UNIQUE,
    description TEXT,
    date_expiration DATE,
    date_creation DATE DEFAULT CURRENT_DATE
);

-- CORRECTION 3: Table UNITE ajoutée (référencée dans tous les détails mais n'existait pas)
CREATE TABLE unite (
    id BIGSERIAL PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL,
    -- Ex: Kilogramme, Litre, Pièce, Boîte
    abreviation VARCHAR(10) -- Ex: kg, L, pcs, box
);

-- CORRECTION 4: Table CLIENT ajoutée (référencée dans vente et facture_client)
CREATE TABLE client (
    id BIGSERIAL PRIMARY KEY,
    nom VARCHAR(200) NOT NULL,
    contact VARCHAR(100),
    email VARCHAR(100),
    telephone VARCHAR(50),
    adresse TEXT,
    date_creation DATE DEFAULT CURRENT_DATE
);

-- CORRECTION 5: Table FOURNISSEUR ajoutée (référencée dans achat, proforma_fournisseur, facture_fournisseur)
CREATE TABLE fournisseur (
    id BIGSERIAL PRIMARY KEY,
    nom VARCHAR(200) NOT NULL,
    contact VARCHAR(100),
    email VARCHAR(100),
    telephone VARCHAR(50),
    adresse TEXT,
    date_creation DATE DEFAULT CURRENT_DATE
);

-- =========================
-- TABLES DE RÉFÉRENCE
-- =========================
CREATE TABLE site (
    id BIGSERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL
);

CREATE TABLE depot (
    id BIGSERIAL PRIMARY KEY,
    site_id BIGINT NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    CONSTRAINT fk_depot_site FOREIGN KEY (site_id) REFERENCES site(id)
);

CREATE TABLE type_mouvement (
    id BIGSERIAL PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL -- Ex: ENTREE, SORTIE, TRANSFERT, AJUSTEMENT
);

CREATE TABLE status_achat_transfert (
    id BIGSERIAL PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL -- Ex: EN_ATTENTE, VALIDEE, LIVREE, ANNULEE
);

-- =========================
-- GESTION DU STOCK
-- =========================
-- CORRECTION 6: Table STOCK ajoutée pour suivre les quantités par produit et dépôt
CREATE TABLE stock (
    id BIGSERIAL PRIMARY KEY,
    produit_id BIGINT NOT NULL,
    depot_id BIGINT NOT NULL,
    quantite NUMERIC(10, 2) NOT NULL DEFAULT 0,
    date_derniere_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_stock_produit FOREIGN KEY (produit_id) REFERENCES produit(id),
    CONSTRAINT fk_stock_depot FOREIGN KEY (depot_id) REFERENCES depot(id),
    -- Un produit ne peut apparaître qu'une fois par dépôt
    CONSTRAINT uk_stock_produit_depot UNIQUE(produit_id, depot_id)
);

-- =========================
-- DEMANDES D'ACHAT
-- =========================
-- CORRECTION 8: Table DEMANDE_ACHAT ajoutée (visible image 6: "Liste demande d'achat")
-- Permet un workflow de validation avant transformation en achat
CREATE TABLE demande_achat (
    id BIGSERIAL PRIMARY KEY,
    reference_demande VARCHAR(50) UNIQUE,
    date_demande DATE NOT NULL,
    entreprise VARCHAR(200),
    -- Correspond au champ "Entreprise" visible dans l'écran
    statut VARCHAR(30) NOT NULL,
    -- EN_ATTENTE / VALIDEE / REJETEE / TRANSFORMEE_EN_ACHAT
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE demande_achat_detail (
    id BIGSERIAL PRIMARY KEY,
    demande_achat_id BIGINT NOT NULL,
    produit_id BIGINT NOT NULL,
    unite_id BIGINT NOT NULL,
    quantite NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_demande_detail_demande FOREIGN KEY (demande_achat_id) REFERENCES demande_achat(id),
    -- CORRECTION 10: Ajout contraintes FK vers produit et unite
    CONSTRAINT fk_demande_detail_produit FOREIGN KEY (produit_id) REFERENCES produit(id),
    CONSTRAINT fk_demande_detail_unite FOREIGN KEY (unite_id) REFERENCES unite(id)
);

-- =========================
-- PROFORMAS FOURNISSEURS
-- =========================
CREATE TABLE proforma_fournisseur (
    id BIGSERIAL PRIMARY KEY,
    reference_proforma VARCHAR(50) UNIQUE,
    date_proforma DATE NOT NULL,
    fournisseur_id BIGINT NOT NULL,
    statut VARCHAR(30) NOT NULL,
    total_ht NUMERIC(12, 2),
    devise VARCHAR(10),
    delai_livraison VARCHAR(50),
    conditions_paiement VARCHAR(100),
    est_retenue BOOLEAN DEFAULT FALSE,
    -- CORRECTION 10: Ajout contrainte FK vers fournisseur
    CONSTRAINT fk_proforma_fournisseur FOREIGN KEY (fournisseur_id) REFERENCES fournisseur(id)
);

CREATE TABLE proforma_detail (
    id BIGSERIAL PRIMARY KEY,
    proforma_id BIGINT NOT NULL,
    produit_id BIGINT NOT NULL,
    unite_id BIGINT NOT NULL,
    quantite NUMERIC(10, 2) NOT NULL,
    prix_unitaire NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_proforma_detail_proforma FOREIGN KEY (proforma_id) REFERENCES proforma_fournisseur(id),
    -- CORRECTION 10: Ajout contraintes FK vers produit et unite
    CONSTRAINT fk_proforma_detail_produit FOREIGN KEY (produit_id) REFERENCES produit(id),
    CONSTRAINT fk_proforma_detail_unite FOREIGN KEY (unite_id) REFERENCES unite(id)
);

-- =========================
-- ACHATS (BON DE COMMANDE)
-- =========================
CREATE TABLE achat (
    id BIGSERIAL PRIMARY KEY,
    reference_achat VARCHAR(50) UNIQUE,
    date_achat DATE NOT NULL,
    fournisseur_id BIGINT NOT NULL,
    statut_id BIGINT NOT NULL,
    proforma_id BIGINT,
    demande_achat_id BIGINT,
    -- CORRECTION: Lien avec demande d'achat
    CONSTRAINT fk_achat_statut FOREIGN KEY (statut_id) REFERENCES status_achat_transfert(id),
    CONSTRAINT fk_achat_proforma FOREIGN KEY (proforma_id) REFERENCES proforma_fournisseur(id),
    -- CORRECTION 10: Ajout contrainte FK vers fournisseur
    CONSTRAINT fk_achat_fournisseur FOREIGN KEY (fournisseur_id) REFERENCES fournisseur(id),
    CONSTRAINT fk_achat_demande FOREIGN KEY (demande_achat_id) REFERENCES demande_achat(id)
);

CREATE TABLE achat_detail (
    id BIGSERIAL PRIMARY KEY,
    achat_id BIGINT NOT NULL,
    produit_id BIGINT NOT NULL,
    unite_id BIGINT NOT NULL,
    quantite NUMERIC(10, 2) NOT NULL,
    prix_unitaire NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_achat_detail_achat FOREIGN KEY (achat_id) REFERENCES achat(id),
    -- CORRECTION 10: Ajout contraintes FK vers produit et unite
    CONSTRAINT fk_achat_detail_produit FOREIGN KEY (produit_id) REFERENCES produit(id),
    CONSTRAINT fk_achat_detail_unite FOREIGN KEY (unite_id) REFERENCES unite(id)
);

-- =========================
-- VENTES
-- =========================
CREATE TABLE vente (
    id BIGSERIAL PRIMARY KEY,
    reference_vente VARCHAR(50) UNIQUE,
    date_vente DATE NOT NULL,
    client_id BIGINT NOT NULL,
    -- CORRECTION 10: Ajout contrainte FK vers client
    CONSTRAINT fk_vente_client FOREIGN KEY (client_id) REFERENCES client(id)
);

CREATE TABLE vente_detail (
    id BIGSERIAL PRIMARY KEY,
    vente_id BIGINT NOT NULL,
    produit_id BIGINT NOT NULL,
    unite_id BIGINT NOT NULL,
    quantite NUMERIC(10, 2) NOT NULL,
    prix_unitaire NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_vente_detail_vente FOREIGN KEY (vente_id) REFERENCES vente(id),
    -- CORRECTION 10: Ajout contraintes FK vers produit et unite
    CONSTRAINT fk_vente_detail_produit FOREIGN KEY (produit_id) REFERENCES produit(id),
    CONSTRAINT fk_vente_detail_unite FOREIGN KEY (unite_id) REFERENCES unite(id)
);

-- =========================
-- TRANSFERTS ENTRE DÉPÔTS
-- =========================
CREATE TABLE transfert (
    id BIGSERIAL PRIMARY KEY,
    reference_transfert VARCHAR(50) UNIQUE,
    date_transfert DATE NOT NULL,
    depot_origine_id BIGINT NOT NULL,
    depot_cible_id BIGINT NOT NULL,
    statut_id BIGINT NOT NULL,
    CONSTRAINT fk_transfert_depot_origine FOREIGN KEY (depot_origine_id) REFERENCES depot(id),
    CONSTRAINT fk_transfert_depot_cible FOREIGN KEY (depot_cible_id) REFERENCES depot(id),
    CONSTRAINT fk_transfert_statut FOREIGN KEY (statut_id) REFERENCES status_achat_transfert(id)
);

CREATE TABLE transfert_detail (
    id BIGSERIAL PRIMARY KEY,
    transfert_id BIGINT NOT NULL,
    produit_id BIGINT NOT NULL,
    unite_id BIGINT NOT NULL,
    quantite NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_transfert_detail_transfert FOREIGN KEY (transfert_id) REFERENCES transfert(id),
    -- CORRECTION 10: Ajout contraintes FK vers produit et unite
    CONSTRAINT fk_transfert_detail_produit FOREIGN KEY (produit_id) REFERENCES produit(id),
    CONSTRAINT fk_transfert_detail_unite FOREIGN KEY (unite_id) REFERENCES unite(id)
);

-- =========================
-- MOUVEMENTS DE STOCK
-- =========================
CREATE TABLE mouvement_stock (
    id BIGSERIAL PRIMARY KEY,
    type_mouvement_id BIGINT NOT NULL,
    origine_id BIGINT NOT NULL,
    -- ID de l'achat, vente, ou transfert selon le type
    depot_id BIGINT NOT NULL,
    date_mouvement TIMESTAMP NOT NULL,
    CONSTRAINT fk_mouvement_type FOREIGN KEY (type_mouvement_id) REFERENCES type_mouvement(id),
    CONSTRAINT fk_mouvement_depot FOREIGN KEY (depot_id) REFERENCES depot(id)
);

-- CORRECTION 7: Table MOUVEMENT_STOCK_DETAIL ajoutée pour détailler les produits concernés
-- Le mouvement_stock seul ne suffit pas, il faut savoir QUELS produits et QUELLES quantités
CREATE TABLE mouvement_stock_detail (
    id BIGSERIAL PRIMARY KEY,
    mouvement_stock_id BIGINT NOT NULL,
    produit_id BIGINT NOT NULL,
    unite_id BIGINT NOT NULL,
    quantite NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_mouvement_detail_mouvement FOREIGN KEY (mouvement_stock_id) REFERENCES mouvement_stock(id),
    CONSTRAINT fk_mouvement_detail_produit FOREIGN KEY (produit_id) REFERENCES produit(id),
    CONSTRAINT fk_mouvement_detail_unite FOREIGN KEY (unite_id) REFERENCES unite(id)
);

-- =========================
-- FACTURES FOURNISSEURS
-- =========================
CREATE TABLE facture_fournisseur (
    id BIGSERIAL PRIMARY KEY,
    reference_facture VARCHAR(50) UNIQUE NOT NULL,
    fournisseur_id BIGINT NOT NULL,
    achat_id BIGINT NOT NULL,
    date_facture DATE NOT NULL,
    montant_total NUMERIC(14, 2) NOT NULL,
    statut VARCHAR(30) NOT NULL,
    -- BROUILLON / VALIDEE / PAYEE
    CONSTRAINT fk_facture_fournisseur_achat FOREIGN KEY (achat_id) REFERENCES achat(id),
    -- CORRECTION 10: Ajout contrainte FK vers fournisseur
    CONSTRAINT fk_facture_fournisseur_fournisseur FOREIGN KEY (fournisseur_id) REFERENCES fournisseur(id)
);

-- =========================
-- FACTURES CLIENTS
-- =========================
CREATE TABLE facture_client (
    id BIGSERIAL PRIMARY KEY,
    reference_facture VARCHAR(50) UNIQUE NOT NULL,
    client_id BIGINT NOT NULL,
    vente_id BIGINT NOT NULL,
    date_facture DATE NOT NULL,
    montant_total NUMERIC(14, 2) NOT NULL,
    statut VARCHAR(30) NOT NULL,
    -- BROUILLON / VALIDEE / PAYEE
    CONSTRAINT fk_facture_client_vente FOREIGN KEY (vente_id) REFERENCES vente(id),
    -- CORRECTION 10: Ajout contrainte FK vers client
    CONSTRAINT fk_facture_client_client FOREIGN KEY (client_id) REFERENCES client(id)
);

-- =========================
-- MODES DE PAIEMENT
-- =========================
CREATE TABLE mode_paiement (
    id BIGSERIAL PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL -- ESPECES / VIREMENT / CHEQUE / MOBILE MONEY
);

-- =========================
-- PAIEMENTS
-- =========================
CREATE TABLE paiement (
    id BIGSERIAL PRIMARY KEY,
    date_paiement DATE NOT NULL,
    montant NUMERIC(14, 2) NOT NULL,
    mode_paiement_id BIGINT NOT NULL,
    reference_paiement VARCHAR(100),
    type_paiement VARCHAR(20) NOT NULL,
    -- CLIENT / FOURNISSEUR
    CONSTRAINT fk_paiement_mode FOREIGN KEY (mode_paiement_id) REFERENCES mode_paiement(id)
);

-- =========================
-- LIAISON PAIEMENT → FACTURE CLIENT
-- =========================
CREATE TABLE paiement_facture_client (
    id BIGSERIAL PRIMARY KEY,
    paiement_id BIGINT NOT NULL,
    facture_client_id BIGINT NOT NULL,
    montant_affecte NUMERIC(14, 2) NOT NULL,
    CONSTRAINT fk_paiement_facture_client_paiement FOREIGN KEY (paiement_id) REFERENCES paiement(id),
    CONSTRAINT fk_paiement_facture_client_facture FOREIGN KEY (facture_client_id) REFERENCES facture_client(id)
);

-- =========================
-- LIAISON PAIEMENT → FACTURE FOURNISSEUR
-- =========================
CREATE TABLE paiement_facture_fournisseur (
    id BIGSERIAL PRIMARY KEY,
    paiement_id BIGINT NOT NULL,
    facture_fournisseur_id BIGINT NOT NULL,
    montant_affecte NUMERIC(14, 2) NOT NULL,
    CONSTRAINT fk_paiement_facture_fournisseur_paiement FOREIGN KEY (paiement_id) REFERENCES paiement(id),
    CONSTRAINT fk_paiement_facture_fournisseur_facture FOREIGN KEY (facture_fournisseur_id) REFERENCES facture_fournisseur(id)
);

-- =========================
-- CAISSE / TRÉSORERIE
-- =========================
CREATE TABLE mouvement_caisse (
    id BIGSERIAL PRIMARY KEY,
    date_mouvement TIMESTAMP NOT NULL,
    type_mouvement VARCHAR(10) NOT NULL,
    -- ENTREE / SORTIE
    montant NUMERIC(14, 2) NOT NULL,
    paiement_id BIGINT,
    CONSTRAINT fk_mouvement_caisse_paiement FOREIGN KEY (paiement_id) REFERENCES paiement(id)
);

-- =========================
-- HISTORIQUE & TRAÇABILITÉ
-- =========================
-- CORRECTION 9: Table HISTORIQUE_STATUT ajoutée pour tracer les changements de statut
-- Visible dans les écrans (images 7, 10) qui montrent "Statut" et dates de modification
CREATE TABLE historique_statut (
    id BIGSERIAL PRIMARY KEY,
    entite VARCHAR(50) NOT NULL,
    -- ACHAT / TRANSFERT / VENTE / DEMANDE_ACHAT / FACTURE
    entite_id BIGINT NOT NULL,
    -- ID de l'entité concernée
    ancien_statut VARCHAR(50),
    nouveau_statut VARCHAR(50) NOT NULL,
    date_changement TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    utilisateur VARCHAR(100),
    -- Qui a fait le changement
    commentaire TEXT
);

-- Table d'audit déjà présente (conservée)
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    date_action TIMESTAMP NOT NULL,
    utilisateur VARCHAR(100),
    action VARCHAR(100),
    entite VARCHAR(50),
    entite_id BIGINT
);