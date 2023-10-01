--2. CREAR TABLA DE ivr_summary
CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
WITH document AS (
        SELECT
            detail.calls_ivr_id AS document_ivr_id
            ,NULLIF(detail.step_document_type, 'NULL') AS document_type
            ,NULLIF(detail.step_document_identification, 'NULL') AS document_identification
            ,NULLIF(detail.step_customer_phone, 'NULL') AS customer_phone
            ,NULLIF(detail.step_billing_account_id, 'NULL') AS billing_account_id
            , IF(CONTAINS_SUBSTR(detail.calls_module_aggregation, 'AVERIA_MASIVA'), 1, 0) AS masiva_lg
        FROM keepcoding.ivr_detail detail
        GROUP BY calls_ivr_id
                ,document_type
                ,document_identification
                ,customer_phone
                ,billing_account_id
                ,masiva_lg
                QUALIFY ROW_NUMBER()OVER(
                    PARTITION BY CAST(detail.calls_ivr_id AS STRING)
                    ORDER BY detail.calls_ivr_id
                        ,document_type DESC
                        ,document_identification DESC
                        ,customer_phone DESC
                        ,billing_account_id DESC
                ) = 1
        )
        ,info_counts AS (
            SELECT
                detail.calls_ivr_id,
                 SUM(CASE WHEN detail.step_name = 'CUSTOMERINFOBYPHONE.TX' AND detail.step_description_error = 'NULL' THEN 1 ELSE 0 END) AS info_by_phone_lg
                ,SUM(CASE WHEN detail.step_name = 'CUSTOMERINFOBYDNI.TX' AND detail.step_description_error = 'NULL' THEN 1 ELSE 0 END) AS info_by_dni_lg
            FROM
                keepcoding.ivr_detail detail
            GROUP BY
                detail.calls_ivr_id
        )
        ,calls_with_timestamp AS (
            SELECT
                 detail.calls_ivr_id
                ,LAG(detail.calls_start_date) OVER (PARTITION BY detail.calls_phone_number ORDER BY detail.calls_start_date) AS previous_call
                ,LEAD(detail.calls_start_date) OVER (PARTITION BY detail.calls_phone_number ORDER BY detail.calls_start_date) AS next_call
            FROM keepcoding.ivr_detail detail
        )
SELECT
    detail.calls_ivr_id
   ,detail.calls_phone_number
   ,detail.calls_ivr_result
   ,CASE
        WHEN calls_vdn_label LIKE 'ATC%' THEN 'FRONT'
        WHEN calls_vdn_label LIKE 'TECH%' THEN 'TECH'
        WHEN calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
        ELSE 'RESTO'
    END AS calls_vdn_aggregation
    ,detail.calls_start_date
    ,detail.calls_end_date
    ,detail.calls_total_duration
    ,detail.calls_customer_segment
    ,detail.calls_ivr_language
    ,detail.calls_steps_module
    ,detail.calls_module_aggregation
    ,document.document_type
    ,document.document_identification
    ,document.customer_phone
    ,document.billing_account_id
    ,document.masiva_lg
    ,info_counts.info_by_phone_lg
    ,info_counts.info_by_dni_lg
    ,IF(DATETIME_DIFF(detail.calls_start_date, calls_with_timestamp.previous_call,HOUR) < 24, 1, 0) AS repeated_phone_24H
    ,IF(DATETIME_DIFF(detail.calls_start_date, calls_with_timestamp.next_call, HOUR) < 24, 1, 0) AS cause_recall_phone_24H  
FROM keepcoding.ivr_detail detail
LEFT JOIN document
    ON detail.calls_ivr_id = document.document_ivr_id
LEFT JOIN info_counts
    ON info_counts.calls_ivr_id = detail.calls_ivr_id
LEFT JOIN calls_with_timestamp
    ON detail.calls_ivr_id = calls_with_timestamp.calls_ivr_id
QUALIFY ROW_NUMBER() 
  OVER(
    PARTITION BY CAST(detail.calls_ivr_id AS STRING) 
    ORDER BY detail.calls_ivr_id,detail.calls_start_date DESC
  ) = 1
;