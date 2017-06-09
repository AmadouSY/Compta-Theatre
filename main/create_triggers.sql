CREATE OR REPLACE FUNCTION f_getCurrentDate() RETURNS date AS $$
DECLARE
	current RECORD ;
BEGIN
	SELECT * INTO current FROM date_courante LIMIT 1 ;

	RETURN current.date_today ;
END ;
$$ LANGUAGE plpgsql ;

DROP FUNCTION IF EXISTS f_getMontantEffectif(int,int);
CREATE OR REPLACE FUNCTION f_getMontantEffectif(id_rep int, tarif_reduc INT) RETURNS INT AS $$
DECLARE
	rep RECORD;
	spec RECORD;
	tarif INT ;
	current DATE;
	tarifA INT;
	tarifB INT;
	tarifC INT;
	tarif_base INT;

BEGIN

	SELECT * INTO rep FROM representation WHERE id_representation = id_rep ;
	SELECT * INTO spec FROM spectacle WHERE id_spectacle = rep.id_spectacle ;

	IF (tarif_reduc = 1) THEN
		tarif_base = rep.tarif_normal;
	ELSE
		tarif_base = rep.tarif_reduit;

	END IF;
	tarifA = tarif_base;
	tarifB = tarif_base;
	tarifC = tarif_base;

	/* 30% pour les 30% premiers */
	current = f_getCurrentDate();
	IF(rep.places_restantes < (spec.capacite_spectacle*0.7)) THEN
		tarifA = tarif_base * 0.7;
	/* 20% les 5 derniers jours */
	ELSEIF (rep.date_vente + interval '5 days' > current) THEN
		tarifB = 0.8 * tarif_base;
  /* Les 15 derniers jours */
	ELSEIF (current > rep.date_representation - interval '15 days') THEN
		/* 30% s'il reste plus de 50% de places */
		IF (rep.places_restantes > (spec.capacite_spectacle/2)) THEN
			tarifC = 0.7 * tarif_base;
		/* 50% s'il reste plus de 70% de places */
		ELSEIF (rep.places_restantes > (spec.capacite_spectacle*0.7)) THEN
			tarifC = 0.5 * tarif_base;
		END IF;
	END IF;

	/* Le client profite de la reduction la plus importante */
	IF(tarifA <= tarifB and tarifA <= tarifC)
		THEN tarif = tarifA;
	ELSEIF(tarifB <= tarifA and tarifB <= tarifC)
		THEN tarif = tarifB;
	ELSE tarif = tarifC;
	END IF;
	return tarif;
END ;
$$ LANGUAGE plpgsql ;


CREATE OR REPLACE FUNCTION f_subvention() RETURNS trigger AS $$
DECLARE
  subs RECORD;
BEGIN
  SELECT * INTO subs FROM subvention
  WHERE subvention.nom_organisme = NEW.nom_organisme
    AND subvention.id_spectacle = NEW.id_spectacle;
  IF FOUND THEN
    RAISE NOTICE 'Cet organisme a deja subventionné ce spectacle';
    RETURN NULL;
  END IF ;
  RAISE NOTICE 'Nouvelle subvention' ;
	INSERT INTO archive(date_archive, montant_archive, id_spectacle, type_archive)
		VALUES (NEW.date_subvention, NEW.montant_subvention, New.id_spectacle, 'subvention');

  RETURN NEW;
END ;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_subvention
BEFORE INSERT ON subvention
FOR EACH ROW
  EXECUTE PROCEDURE f_subvention();


CREATE OR REPLACE FUNCTION f_representation() RETURNS trigger AS $$
DECLARE
  spec RECORD;
	rep RECORD;
	current DATE;
BEGIN
	SELECT * INTO rep FROM representation WHERE date_representation = New.date_representation;
	IF FOUND THEN
		RAISE NOTICE 'Une representation est deja prevu a cette date';
		RETURN NULL;
	END IF;
	current = f_getCurrentDate();
	SELECT * INTO spec FROM spectacle WHERE id_spectacle = New.id_spectacle;
	NEW.places_restantes = spec.capacite_spectacle;
	New.date_vente = current;
	return New;
END ;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_representation
BEFORE INSERT ON representation
FOR EACH ROW
  EXECUTE PROCEDURE f_representation();

CREATE OR REPLACE FUNCTION f_spectacle() RETURNS trigger AS $$
DECLARE
	billets RECORD ;
	depenses int;
BEGIN

	CASE
		WHEN TG_OP = 'INSERT' THEN
		IF(New.nom_compagnie != 'Theatre du Chrysanteme') THEN
			depenses = NEW.depenses_spectacle;
			INSERT INTO archive(date_archive, montant_archive, id_spectacle, type_archive)
				VALUES (f_getCurrentDate(), depenses, NEW.id_spectacle, 'achat_spe');
		ELSE
			IF (new.depenses_spectacle > 0) THEN
				depenses = NEW.depenses_spectacle;
				INSERT INTO archive(date_archive, montant_archive, id_spectacle, type_archive)
					VALUES (f_getCurrentDate(), depenses, NEW.id_spectacle, 'cout_prod');
			END IF ;
		END IF ;
		WHEN TG_OP = 'UPDATE' THEN
			IF ((new.depenses_spectacle != OLD.depenses_spectacle) AND NEW.depenses_spectacle>0) THEN
					depenses = new.depenses_spectacle - OLD.depenses_spectacle;
					INSERT INTO archive(date_archive, montant_archive, id_spectacle, type_archive)
						VALUES (f_getCurrentDate(), depenses, NEW.id_spectacle, 'cout_prod');

			END IF ;
	END CASE ;
	RETURN NEW ;
END ;
$$ LANGUAGE plpgsql ;

CREATE TRIGGER t_spectacle
AFTER INSERT OR UPDATE ON spectacle
FOR EACH ROW
	EXECUTE PROCEDURE f_spectacle() ;


CREATE OR REPLACE FUNCTION f_billet() RETURNS trigger AS $$
DECLARE
	rep RECORD;
	places INT;
	tarif INT;
	current DATE ;
	date_paiement DATE ;
	date_billet DATE ;
	date_representation DATE;
BEGIN
	SELECT * INTO rep FROM representation WHERE id_representation=NEW.id_representation;

	current = f_getCurrentDate() ;
	date_billet = current ;
	NEW.date_billet = date_billet ;

	IF rep.id_representation IS NULL THEN
		RAISE NOTICE 'Cette representation n existe pas';
		RETURN NULL;
	END IF;

	/*** Tarif effectif du billet ****/
	/*tarif = getMontantEffectif(rep.id_representation, )*/

	/* NULL si le spectacle a deja eu lieu */
	IF(current > rep.date_representation) THEN
		RAISE NOTICE 'Cette representation est deja passé%', rep.date_representation - interval '2 days';
		RETURN NULL;
	END IF;

	/* On met a jour le nombre de places*/
	IF(rep.places_restantes < 1) THEN
		RAISE NOTICE E'Il n\'y a plus de place pour cette representation';
		RETURN NULL;
	ELSE
		places = rep.places_restantes-1;
		UPDATE representation
		SET places_restantes = places
		WHERE id_representation = NEW.id_representation;
	END IF;

	/* On enregistre la vente */
	IF (new.statut_billet = 'VENDU') THEN
		INSERT INTO archive(date_archive, montant_archive, id_spectacle, type_archive)
			VALUES (NEW.date_billet, NEW.tarif_effectif, rep.id_spectacle, 'vente');
	END IF ;

	RETURN NEW ;
END ;
$$ LANGUAGE plpgsql ;

CREATE TRIGGER t_billet
AFTER INSERT OR UPDATE ON billet
FOR EACH ROW
	EXECUTE PROCEDURE f_billet() ;


CREATE OR REPLACE FUNCTION f_reservation() RETURNS trigger AS $$
DECLARE
	rep RECORD;
  doc RECORD;
	current DATE ;
	date_paiement DATE ;
BEGIN
	current = f_getCurrentDate() ;
	SELECT * INTO rep FROM representation WHERE id_representation=New.id_representation;

	/**** DATE LIMITE DE PAIEMENT *****/
	IF(NEW.statut_billet = 'RESERVE') THEN

		IF(current > rep.date_representation - interval '2 days') THEN
			RAISE NOTICE 'RESERVATION IMPOSSIBLE VOUS DEVEZ ACHETER ';
			RETURN NULL;
		ELSEIF( (current + interval '10 days') < (rep.date_representation - interval '2 days') ) THEN
			date_paiement = current + interval '10 days' ;
			NEW.date_limite_paiement = date_paiement ;
			RAISE NOTICE 'Cette place vous a été reservé pour 10 jours';
		ELSE
			date_paiement = rep.date_representation - interval '2 days' ;
			NEW.date_limite_paiement = date_paiement ;
			RAISE NOTICE 'Vous devez payer avant le % !', date_paiement ;
		END IF ;
	END IF ;

	RETURN NEW ;
END ;
$$ LANGUAGE plpgsql ;

CREATE TRIGGER t_reservation
BEFORE INSERT ON billet
FOR EACH ROW
	EXECUTE PROCEDURE f_reservation() ;

CREATE OR REPLACE FUNCTION f_ajouter_place(id_rep INT) RETURNS void AS $$
DECLARE
	rep RECORD ;
	places INT;
BEGIN
	SELECT * into rep FROM representation WHERE id_representation=id_rep;
	places = rep.places_restantes+1;
	UPDATE representation
	SET places_restantes = places
	WHERE id_representation = id_rep;
	RAISE NOTICE 'Une place a été rajoutée';
END ;
$$ LANGUAGE plpgsql ;

CREATE OR REPLACE FUNCTION f_alerte_paiement(nouvelle date) RETURNS void AS $$
DECLARE
	billets RECORD ;
BEGIN
	FOR billets IN SELECT * FROM billet WHERE statut_billet='RESERVE'
	LOOP
		IF (nouvelle + interval '1 days' = billets.date_limite_paiement) THEN
			RAISE NOTICE E'Le billet % doit etre paye demain au plus tard.', billets.id_billet ;
		ELSEIF (nouvelle = billets.date_limite_paiement) THEN
			RAISE NOTICE E'Le billet % doit etre paye aujourd\'hui.', billets.id_billet ;
		ELSIF (nouvelle > billets.date_limite_paiement) THEN
			RAISE NOTICE E'La reservation % a expirée.', billets.id_billet ;
			DELETE FROM billet WHERE id_billet=billets.id_billet;
			EXECUTE f_ajouter_place(billets.id_representation);
		END IF ;
	END LOOP ;
END ;
$$ LANGUAGE plpgsql ;

CREATE OR REPLACE FUNCTION f_update_date() RETURNS TRIGGER AS $$
BEGIN
	EXECUTE f_alerte_paiement(NEW.date_today) ;
	/*EXECUTE f_alerte_promo(NEW.date_today) ;*/
	RETURN NEW ;
END ;
$$ LANGUAGE plpgsql ;

CREATE TRIGGER t_update_date
BEFORE UPDATE ON date_courante
FOR EACH ROW
	EXECUTE PROCEDURE f_update_date() ;

CREATE OR REPLACE FUNCTION f_get_prix_spectacle(id_spec INT) RETURNS INT AS $$
DECLARE
	spec RECORD ;
BEGIN
	SELECT * INTO spec FROM spectacle WHERE id_spectacle=id_spec;
	RETURN spec.prix_spectacle;
END ;
$$ LANGUAGE plpgsql ;
