-- ============================================================
-- Exportaciones de café colombiano — consultas del análisis
-- Fuente: Federación Nacional de Cafeteros (FNC), datos a jul-2026
-- Base de datos: data/cafe_exportaciones.db
-- ============================================================

-- 1) ¿Qué porcentaje del café lo exporta la Federación directamente
--    vs. exportadores particulares? Últimos 6 años.
SELECT anio,
       fnc_miles_sacos,
       particulares_miles_sacos,
       total_miles_sacos,
       ROUND(100.0 * fnc_miles_sacos / total_miles_sacos, 1) AS pct_fnc
FROM exportaciones_exportador_anual
ORDER BY anio DESC
LIMIT 6;

-- 2) Top 10 países destino en 2025
SELECT pais, volumen_miles_sacos
FROM exportaciones_destino_pais_anual
WHERE anio = 2025
ORDER BY volumen_miles_sacos DESC
LIMIT 10;

-- 3) Precio implícito por saco exportado (valor / volumen), 2016-2026
--    Se unen las tablas de volumen y valor mensual por fecha, se agrupa por año.
SELECT v.anio,
       ROUND(SUM(v.volumen_miles_sacos), 0)                             AS volumen_miles_sacos,
       ROUND(SUM(val.valor_millones_usd), 1)                            AS valor_millones_usd,
       ROUND(SUM(val.valor_millones_usd) * 1000 / SUM(v.volumen_miles_sacos), 2) AS usd_por_saco
FROM exportaciones_volumen_mensual v
JOIN exportaciones_valor_mensual val ON v.fecha = val.fecha
WHERE v.anio BETWEEN 2016 AND 2025
GROUP BY v.anio
ORDER BY v.anio;

-- 4) Composición del café exportado en 2025: ¿cuánto es grano crudo (verde)
--    vs. producto con algún nivel de transformación (tostado, molido, soluble, etc.)?
SELECT anio,
       verde,
       (total - verde) AS con_algun_grado_de_transformacion,
       total,
       ROUND(100.0 * verde / total, 1) AS pct_verde_sin_transformar
FROM exportaciones_tipo_anual
WHERE anio = 2025;

-- 5) Puertos de embarque por volumen en 2025 (excluye filas de subtotal)
SELECT puerto, volumen_sacos
FROM exportaciones_puerto_anual
WHERE anio = 2025
  AND puerto NOT LIKE 'Total%'
ORDER BY volumen_sacos DESC;
