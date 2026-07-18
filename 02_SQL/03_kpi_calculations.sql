/*====================================================
EcoTrips Business Intelligence Project
Dashboard KPI Calculations
====================================================*/

------------------------------------------------------
-- Average Spend per Reservation
------------------------------------------------------

SELECT

ROUND(

SUM(o.preco*r.qtd_pessoas)

/SUM(r.qtd_pessoas),

2

) AS average_spend

FROM `aulas-eba-494203.EcoTrips.reservation` r

INNER JOIN `aulas-eba-494203.EcoTrips.offer` o

ON r.id_oferta=o.id_oferta

WHERE UPPER(r.status)='CONCLUÍDA';


------------------------------------------------------
-- Median Offer Price
------------------------------------------------------

SELECT

PERCENTILE_CONT(o.preco,0.5) OVER() AS median_price

FROM `aulas-eba-494203.EcoTrips.offer` o

LIMIT 1;


------------------------------------------------------
-- Customer Loyalty Rate
------------------------------------------------------

SELECT

ROUND(

COUNT(*)/

(

SELECT

COUNT(DISTINCT id_cliente)

FROM `aulas-eba-494203.EcoTrips.reservation`

WHERE UPPER(status)='CONCLUÍDA'

),

2

)*100 AS loyalty_rate

FROM(

SELECT

id_cliente

FROM `aulas-eba-494203.EcoTrips.reservation`

WHERE UPPER(status)='CONCLUÍDA'

GROUP BY id_cliente

HAVING COUNT(id_reserva)>1

) loyal_customers;


------------------------------------------------------
-- Sustainability Index
------------------------------------------------------

SELECT

ROUND(

COUNT(DISTINCT op.id_oferta)

/(

SELECT

COUNT(DISTINCT id_oferta)

FROM `aulas-eba-494203.EcoTrips.offer`

),

2

)*100 AS sustainability_index

FROM `aulas-eba-494203.EcoTrips.offer_practice` op;