\echo ********** BILLETS PAR SPECTACLE **********

SELECT * FROM spectacle ;

\prompt 'Tapez le numero du spectacle : ' num_spectacle


SELECT nom_spectacle, archive.date_archive AS date, archive.montant_archive AS tarif
FROM spectacle, archive
WHERE archive.id_spectacle = spectacle.id_spectacle
  AND spectacle.id_spectacle = :num_spectacle
  AND archive.type_archive='vente'
GROUP BY nom_spectacle, date_archive, montant_archive;
