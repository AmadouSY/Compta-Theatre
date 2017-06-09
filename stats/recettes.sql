\echo ********** RECETTES PAR SPECTACLE **********

SELECT nom_spectacle, sum(montant_archive) AS RECETTES
FROM spectacle, archive
WHERE archive.id_spectacle = spectacle.id_spectacle
  AND (type_archive='vente' or type_archive='subvention')
GROUP BY nom_spectacle;
