\echo ********** RESERVATION **********

SELECT * FROM spectacle ;

\prompt 'Tapez le numero du spectacle a vendre : ' num_spectacle

INSERT INTO archive(date_archive, montant_archive, id_spectacle, type_archive)
  VALUES (f_getCurrentDate(), (SELECT (f_get_prix_spectacle(:num_spectacle))),
    :num_spectacle, 'vente_rep');
