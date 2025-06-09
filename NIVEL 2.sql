-- Nivell 2
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:
-- Exercici 1
-- Quantes targetes estan actives?

-- Insertar datos en la tabla 'tarjeta_estado'
INSERT INTO tarjeta_estado (card_id, estado)
SELECT
    tarjeta_transaccion.card_id,
    CASE
        -- Contar el número de transacciones declinadas entre las últimas tres
        WHEN SUM(CASE WHEN tarjeta_transaccion.declined = 1 THEN 1 ELSE 0 END) >= 3 THEN 'Inactiva'
        ELSE 'Activa'
    END AS estado_actual_de_tarjeta
FROM (
    SELECT
        transacciones.card_id,
        transacciones.declined,
        -- Asignar un número de fila a cada transacción por tarjeta, ordenado por la marca de tiempo de forma descendente
        ROW_NUMBER() OVER (PARTITION BY transacciones.card_id ORDER BY transacciones.timestamp DESC) AS numero_de_fila
    FROM
        transacciones
) AS tarjeta_transaccion
WHERE tarjeta_transaccion.numero_de_fila <= 3 -- Considerar solo las últimas tres transacciones
GROUP BY tarjeta_transaccion.card_id;

-- Tarjetas que están activas
SELECT COUNT(*) AS numero_de_tarjetas_activas
FROM tarjeta_estado
WHERE estado = 'Activa';