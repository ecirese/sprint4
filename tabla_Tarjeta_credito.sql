-- crear tabla con info de tarjetas de credito

CREATE TABLE tarjeta_credito (
id VARCHAR (50),
user_id INT NOT NULL,
iban VARCHAR (50),
pan VARCHAR (50),
pin INT,
cvv INT,
track1 VARCHAR (100),
track2 VARCHAR (100),
expiring_date VARCHAR (50),
PRIMARY KEY (id));

SHOW VARIABLES LIKE 'secure_file_priv'

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE tarjeta_credito
FIELDS TERMINATED BY ','  -- o el delimitador
LINES TERMINATED BY '\n'  -- o el delimitador de línea
IGNORE 1 LINES; 

-- cambiar expiring_date de VARCHAR a DATE:

SET SQL_SAFE_UPDATES = 0; -- deshabilito actualizacion segura para poder hacer modificaciones

-- creo columna temporal para poder hacer el cambio de data type
ALTER TABLE tarjeta_credito
ADD COLUMN expiring_date_temp DATE;


-- copio y convierto los datos a la nueva columna

UPDATE tarjeta_credito
SET expiring_date_temp = STR_TO_DATE(expiring_date, '%m/%d/%y');

-- una vez tengo los datos en la nueva columna elimino la original.

ALTER TABLE tarjeta_credito
DROP COLUMN expiring_date;

-- Renombro la nueva como la anterior

ALTER TABLE tarjeta_credito
RENAME COLUMN expiring_date_temp TO expiring_date;