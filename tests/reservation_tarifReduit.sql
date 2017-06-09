\echo ********** RESERVATION **********

SELECT * FROM spectacle ;

\prompt 'Tapez le numero du spectacle auquel vous souhaitez assister : ' num_spectacle

SELECT * FROM representation
WHERE id_spectacle = :num_spectacle AND (SELECT(f_getCurrentDate()) < date_representation);

\prompt 'Tapez le numero de la representation a laquelle vous souhaitez assister : ' num_representation


INSERT INTO
  billet(date_billet, tarif_effectif, id_representation, statut_billet)
VALUES
  ((SELECT f_getCurrentDate()),
    (SELECT f_getMontantEffectif(:num_representation, 0)),
    :num_representation, 'RESERVE');
