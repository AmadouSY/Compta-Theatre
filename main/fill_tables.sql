
INSERT INTO date_courante (date_today) VALUES ('2017-05-01') ;


INSERT INTO spectacle (nom_spectacle, nom_compagnie,capacite_spectacle, depenses_spectacle, prix_spectacle)
VALUES
('Le testament de marie', 'Theatre du Chrysanteme', 2000, 2000, 9000),
('Madea', 'Theatre du Chrysanteme', 2200, 2123, 2500),
('Richard III', 'Theatre du Chrysanteme', 2000, 1800, 4000),
('Songes et Metamorphoses', 'Theatre du Chrysanteme', 1800, 7000, 3000),
(E'Soudaun l\'ete dernier', 'Theatre du Chrysanteme', 1500, 2000, 1000),
('Un amour impossible', 'Theatre du Chrysanteme', 2200, 1200, 2000),
('Hotel Feydeau', 'Theatre du Chrysanteme', 1800, 200, 3000),
('Vu du pont', 'Theatre du Chrysanteme', 2000, 4000, 9000);

INSERT INTO spectacle(nom_spectacle, nom_compagnie,capacite_spectacle, depenses_spectacle)
VALUES
('Le Radeau de la meduse', 'Theatre du Chatelet', 1800, 8000),
('Il cielo non e un fondale', E'Theatre de l\'odeon', 2000, 9000);


INSERT INTO representation (date_representation, tarif_normal, tarif_reduit, id_spectacle)
VALUES
('2017-05-20', 35, 15, 1),
('2017-05-19', 35, 15, 1),
('2017-05-12', 35, 15, 3),
('2017-05-13', 35, 15, 3),
('2017-05-10', 35, 15, 2),
('2017-06-20', 35, 15, 2),
('2017-06-21', 35, 15, 8),
('2017-05-22', 35, 15, 3),
('2017-06-29', 35, 15, 3),
('2017-07-20', 35, 15, 8),
('2017-07-24', 35, 15, 1),
('2017-07-27', 35, 15, 10),
('2017-07-28', 35, 15, 3),
('2017-08-02', 35, 15, 5),
('2017-08-03', 35, 15, 4),
('2017-08-03', 35, 15, 1);


INSERT INTO billet(date_billet, tarif_effectif, id_representation)
VALUES
('2017-06-21', 35, 8),
('2017-05-22', 35, 3),
('2017-06-29', 35, 3),
('2017-07-20', 15, 8),
('2017-07-24', 35, 1),
('2017-07-27', 15, 10),
('2017-07-28', 15, 3),
('2017-08-02', 12, 5),
('2017-08-03 20:00:00', 35, 4),
('2017-08-03 22:30:00', 50, 4);

INSERT INTO billet(date_billet, tarif_effectif, id_representation, statut_billet)
VALUES
('2017-07-20 20:30:00', 15, 8, 'RESERVE'),
('2017-07-24 22:30:00', 35, 1, 'RESERVE');

INSERT INTO subvention(nom_organisme, montant_subvention, id_spectacle, date_subvention)
VALUES
('Marie de Paris', 5000, 1, '2017-04-21'),
('LVMH', 1000, 1, '2017-04-21'),
('Marie de Paris', 3000, 2, '2017-04-21'),
('Marie de Paris', 5000, 3, '2017-04-21'),
('Etat Francais', 5000, 4, '2017-04-21'),
('Fondation theatre', 5000, 7, '2017-04-21'),
('LVMH', 1000, 8, '2017-04-21'),
('Marie de Paris', 5000, 5, '2017-04-21'),
('Marie de Paris', 4000, 6, '2017-04-21'),
('Marie de Paris', 300, 6, '2017-04-21');


INSERT INTO archive(date_archive, montant_archive, id_spectacle, type_archive)
VALUES
('2017-08-03', 100, 3, 'cout_prod')
