
CREATE SCHEMA IF NOT EXISTS sprint4corregido;
USE sprint4corregido;

CREATE TABLE transacciones (
    id VARCHAR(50),
    card_id VARCHAR(50),
    business_id VARCHAR(50),
    timestamp VARCHAR(50),
    amount FLOAT,
    declined INT,
    product_ids VARCHAR(50),
    user_id INT,
    lat DECIMAL(9, 6), -- 9 digitos y 6 digitos después del punto decimal. Funciona VARCHAR pero DECIMAL es más adecuado
    longitude DECIMAL(9, 6)
);

SHOW VARIABLES LIKE 'secure_file_priv'

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transacciones
FIELDS TERMINATED BY ';'  -- o el delimitador
LINES TERMINATED BY '\n'  -- o el delimitador de línea
IGNORE 1 LINES; 

select*
from transacciones;

ALTER TABLE transacciones
MODIFY COLUMN timestamp DATETIME;

ALTER TABLE transacciones
ADD PRIMARY KEY (id);

-- Error Code: 1062. Duplicate entry '02C6201E-D90A-1859-B4EE-88D2986D3B02' for key 'transacciones.PRIMARY' debo revisar y eliminar el duplicado

SELECT *
from transacciones
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02'; -- está duplicado

SET SQL_SAFE_UPDATES = 0;

DELETE t1 FROM transacciones t1
INNER JOIN transacciones t2
WHERE t1.id = t2.id
  AND t1.id = '02C6201E-D90A-1859-B4EE-88D2986D3B02' -- Especifica el ID duplicado
  AND t1.timestamp > t2.timestamp; -- Elimina el registro más reciente de los duplicados

-- nuevamente, intento establecer la PK

ALTER TABLE transacciones
ADD PRIMARY KEY (id);

-- Error Code: 1062. Duplicate entry '0CE957A6-CCAA-2B7A-6839-8A4B1B324853' for key 'transacciones.PRIMARY'

-- Reviso todos los duplicados
SELECT id, COUNT(id) AS cantidad_duplicados
FROM transacciones
GROUP BY id
HAVING COUNT(id) > 1;

-- son varios duplicados y son copias identicas, no hay uno anterior al otro en el tiempo. no tengo forma de discernir con cuál quedarme y cuál deshechar
-- agrego nueva columna llamada temp_id a la tabla. número único y creciente a cada fila existente y a las nuevas. Al hacerla PRIMARY KEY (temporalmente),
--  nos aseguramos de que es única y podemos usarla como un identificador fiable

ALTER TABLE transacciones ADD COLUMN temp_id INT AUTO_INCREMENT PRIMARY KEY;

-- Eliminar los registros duplicados, conservando solo el que tiene el temp_id más bajo

DELETE t1 FROM transacciones t1
INNER JOIN transacciones t2 ON t1.id = t2.id
WHERE t1.temp_id > t2.temp_id;

-- La condición t1.temp_id > t2.temp_id garantiza que para cada grupo de ids duplicados, 
-- solo se borran las filas que tienen un temp_id mayor, 
-- conservando así la fila que tiene el temp_id más bajo (el primero que se insertó se supone)

-- Ahora puedo eliminar la columna temporal
ALTER TABLE transacciones DROP COLUMN temp_id;

-- Y agregar la PK
ALTER TABLE transacciones ADD PRIMARY KEY (id);