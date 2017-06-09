\echo ********** PAIEMENT RESERVATION **********

SELECT * FROM BILLET WHERE statut_billet='RESERVE' ;

\prompt 'Tapez le numero de la RESERVATION a annuler : ' num_billet

\echo 'BILLER SUPPRIMER ':num_billet

DELETE FROM billet WHERE id_billet=billets.id_billet;
SELECT(f_ajouter_place(:num_billet));
