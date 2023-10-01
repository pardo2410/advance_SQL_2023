--3.Funcion de limpieza de enteros

CREATE OR REPLACE FUNCTION keepcoding.clean_integer(input INT64)
RETURNS INT64
AS (
    IF(input IS NULL, -999999, input)
);

--Pruebas
SELECT keepcoding.clean_integer(12);
SELECT keepcoding.clean_integer(null);
SELECT keepcoding.clean_integer(NULL);

