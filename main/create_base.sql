/*\set VERBOSITY terse*/
DROP TABLE IF EXISTS spectacle CASCADE;
DROP TABLE IF EXISTS representation CASCADE;
DROP TABLE IF EXISTS billet CASCADE;
DROP TABLE IF EXISTS subvention CASCADE;
DROP TABLE IF EXISTS archive CASCADE;
DROP TABLE IF EXISTS date_courante CASCADE ;

CREATE TABLE IF NOT EXISTS 	date_courante (
	date_today DATE NOT NULL
) ;

CREATE TABLE IF NOT EXISTS spectacle (
	id_spectacle SERIAL PRIMARY KEY,
	nom_spectacle VARCHAR(100) NOT NULL,
  nom_compagnie VARCHAR(100) NOT NULL,
	capacite_spectacle INT NOT NULL,
	depenses_spectacle INT DEFAULT 0,
	prix_spectacle INT
);

CREATE TABLE IF NOT EXISTS representation (
  id_representation SERIAL PRIMARY KEY,
	date_vente DATE NOT NULL,
  date_representation DATE NOT NULL,
	tarif_normal INT NOT NULL,
	tarif_reduit INT NOT NULL,
	places_restantes INT,
	id_spectacle INT REFERENCES spectacle(id_spectacle)
);

CREATE TABLE IF NOT EXISTS billet (
  id_billet SERIAL PRIMARY KEY,
  date_billet DATE,
	tarif_effectif INT NOT NULL,
	id_representation INT REFERENCES representation(id_representation),
	date_limite_paiement DATE,
	statut_billet VARCHAR(20)
		DEFAULT 'VENDU'
		CHECK (statut_billet IN ('RESERVE', 'VENDU'))

);

CREATE TABLE IF NOT EXISTS subvention (
	id_subvention SERIAL PRIMARY KEY,
	date_subvention DATE,
  nom_organisme VARCHAR(100),
	montant_subvention INT NOT NULL,
	id_spectacle INT REFERENCES spectacle(id_spectacle)
);

CREATE TABLE IF NOT EXISTS archive(
	id_archive SERIAL PRIMARY KEY,
	date_archive DATE,
	montant_archive INT,
	id_spectacle INT REFERENCES spectacle(id_spectacle),
	type_archive VARCHAR(20) NOT NULL
		CHECK (type_archive IN ('vente', 'cout_prod', 'achat_spe', 'subvention', 'vente_rep'))
);
