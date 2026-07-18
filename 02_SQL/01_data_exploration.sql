/*====================================================
EcoTrips Business Intelligence Project
Data Exploration Queries
====================================================*/

------------------------------------------------------
-- Reservations by Offer Type
------------------------------------------------------

SELECT
    o.tipo_oferta AS offer_type,
    COUNT(r.id_reserva) AS total_reservations,
    SUM(r.qtd_pessoas) AS total_travelers
FROM `aulas-eba-494203.EcoTrips.reservation` r
INNER JOIN `aulas-eba-494203.EcoTrips.offer` o
    ON r.id_oferta = o.id_oferta
GROUP BY 1
ORDER BY total_reservations DESC;


------------------------------------------------------
-- Travelers by Offer Type
------------------------------------------------------

SELECT
    o.tipo_oferta AS offer_type,
    SUM(r.qtd_pessoas) AS total_travelers
FROM `aulas-eba-494203.EcoTrips.reservation` r
INNER JOIN `aulas-eba-494203.EcoTrips.offer` o
    ON r.id_oferta = o.id_oferta
GROUP BY 1
ORDER BY total_travelers DESC;


------------------------------------------------------
-- Offer Status Analysis
------------------------------------------------------

SELECT
    o.id_oferta,
    o.titulo,
    ROUND(AVG(rev.nota),2) AS average_rate,

    CASE
        WHEN COUNT(DISTINCT r.id_reserva)=0
            THEN 'No Reservation Concluded'

        WHEN COUNT(DISTINCT r.id_reserva)>0
         AND COUNT(DISTINCT rev.id_avaliacao)=0
            THEN 'Reservation Concluded, but No Review'

        ELSE 'Reservation Concluded and Reviewed'
    END AS offer_status

FROM `aulas-eba-494203.EcoTrips.offer` o

LEFT JOIN `aulas-eba-494203.EcoTrips.reservation` r
ON o.id_oferta=r.id_oferta
AND UPPER(r.status)='CONCLUÍDA'

LEFT JOIN `aulas-eba-494203.EcoTrips.review` rev
ON rev.id_oferta=o.id_oferta

GROUP BY 1,2
ORDER BY average_rate DESC;


------------------------------------------------------
-- Most Popular Sustainable Practices
------------------------------------------------------

SELECT
    sp.nome,
    COUNT(r.id_reserva) AS total_reservations

FROM `aulas-eba-494203.EcoTrips.sustainable_practice` sp

INNER JOIN `aulas-eba-494203.EcoTrips.offer_practice` op
ON sp.id_pratica=op.id_pratica

INNER JOIN `aulas-eba-494203.EcoTrips.reservation` r
ON op.id_oferta=r.id_oferta
AND UPPER(r.status)='CONFIRMADA'

GROUP BY sp.nome
ORDER BY total_reservations DESC;