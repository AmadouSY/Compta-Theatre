\echo ********** PAIEMENT RESERVATION **********

SELECT * FROM BILLET WHERE statut_billet='RESERVE' ;

\prompt 'Tapez le numero du billet a payer : ' num_billet

\echo 'REGLEMENT DU BILLET ':num_billet

UPDATE billet
SET statut_billet = 'VENDU'
WHERE id_billet = :num_billet ;
