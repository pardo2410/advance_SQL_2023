--3.Funcion de limpieza de enteros

CREATE OR REPLACE FUNCTION keepcoding.clean_integer(input INT64)
RETURNS INT64
AS (
    IF(input IS NULL, -999999, input)
);

--Prueba
SELECT keepcoding.clean_integer(CAST(summary.billing_account_id AS INT64)) AS cleaned_billing_account_id
FROM keepcoding.ivr_summary summary;