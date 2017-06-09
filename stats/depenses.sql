\echo ********** DEPENSES PAR SPECTACLE **********

SELECT nom_spectacle, sum(montant_archive) AS DEPENSES
FROM spectacle, archive
WHERE archive.id_spectacle = spectacle.id_spectacle
  AND (type_archive='cout_prod' or type_archive='achat_spe')
GROUP BY nom_spectacle;
