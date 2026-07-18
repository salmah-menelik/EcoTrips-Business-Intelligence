/*====================================================
EcoTrips Business Intelligence Project
Business Analysis Queries
====================================================*/

------------------------------------------------------
-- Monthly Revenue
------------------------------------------------------

SELECT

    EXTRACT(YEAR FROM r.data_reserva) AS year,
    EXTRACT(MONTH FROM r.data_reserva) AS month,

    ROUND(
        SUM(o.preco*r.qtd_pessoas),
        2
    ) AS revenue

FROM `aulas-eba-494203.EcoTrips.reservation` r

JOIN `aulas-eba-494203.EcoTrips.offer` o
ON r.id_oferta=o.id_oferta

WHERE r.status='concluída'

GROUP BY
year,
month

ORDER BY
year DESC,
month DESC;


------------------------------------------------------
-- Monthly Revenue Growth
------------------------------------------------------

WITH monthly_revenue AS (

SELECT

    DATE_TRUNC(r.data_reserva,MONTH) AS month,

    SUM(o.preco*r.qtd_pessoas) AS total_revenue

FROM `aulas-eba-494203.EcoTrips.reservation` r

JOIN `aulas-eba-494203.EcoTrips.offer` o
ON r.id_oferta=o.id_oferta

WHERE r.status='concluída'

GROUP BY month

)

SELECT

month,

total_revenue,

LAG(total_revenue)
OVER(ORDER BY month)
AS previous_month_revenue,

ROUND(

SAFE_DIVIDE(

total_revenue-

LAG(total_revenue)
OVER(ORDER BY month),

LAG(total_revenue)
OVER(ORDER BY month)

)*100,

2

) AS percentage_change

FROM monthly_revenue

ORDER BY month;


------------------------------------------------------
-- Average Offer Rating
------------------------------------------------------

SELECT

o.id_oferta,

o.titulo,

ROUND(AVG(rev.nota),2) AS average_rate

FROM `aulas-eba-494203.EcoTrips.offer` o

LEFT JOIN `aulas-eba-494203.EcoTrips.reservation` r

ON o.id_oferta=r.id_oferta

AND UPPER(r.status)='CONCLUÍDA'

LEFT JOIN `aulas-eba-494203.EcoTrips.review` rev

ON rev.id_oferta=o.id_oferta

GROUP BY 1,2

ORDER BY average_rate DESC;


------------------------------------------------------
-- Average Time Between Repurchases
------------------------------------------------------

WITH filtered_reservations AS (

SELECT

id_cliente,

data_reserva

FROM `aulas-eba-494203.EcoTrips.reservation`

WHERE UPPER(status)='CONFIRMADA'

AND id_cliente IN (

SELECT id_cliente

FROM `aulas-eba-494203.EcoTrips.reservation`

WHERE UPPER(status)='CONFIRMADA'

GROUP BY id_cliente

HAVING COUNT(id_reserva)>1

)

),

reservation_gaps AS (

SELECT

id_cliente,

DATE_DIFF(

data_reserva,

LAG(data_reserva)

OVER(

PARTITION BY id_cliente

ORDER BY data_reserva

),

DAY

) AS diff_days

FROM filtered_reservations

)

SELECT

id_cliente,

AVG(diff_days) AS average_time_between_reservations

FROM reservation_gaps

WHERE diff_days IS NOT NULL

GROUP BY id_cliente

ORDER BY average_time_between_reservations DESC;