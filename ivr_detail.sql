--PRÁCTICA ADVANCED SQL
--Juan David Pardo
--1. CREAR TABLA DE ivr_detail
CREATE OR REPLACE TABLE keepcoding.ivr_detail AS
SELECT
   calls.ivr_id AS calls_ivr_id
  ,calls.phone_number AS calls_phone_number
  ,calls.ivr_result AS calls_ivr_result
  ,calls.vdn_label AS calls_vdn_label
  ,calls.start_date AS calls_start_date
  ,FORMAT_DATE('%Y%m%d', TIMESTAMP(calls.start_date)) AS calls_start_date_id
  ,calls.end_date AS calls_end_date
  ,FORMAT_DATE('%Y%m%d', TIMESTAMP(calls.end_date)) AS calls_end_date_id
  ,calls.total_duration AS calls_total_duration
  ,calls.customer_segment AS calls_customer_segment
  ,calls.ivr_language AS calls_ivr_language
  ,calls.steps_module AS calls_steps_module
  ,calls.module_aggregation AS calls_module_aggregation
  ,module.module_sequece AS module_sequece
  ,module.module_name AS module_name
  ,module.module_duration AS module_duration
  ,module.module_result AS module_result
  ,step.step_sequence AS step_sequence
  ,step.step_name AS step_name
  ,step.step_result AS step_result
  ,step.step_description_error AS step_description_error
  ,step.document_type AS step_document_type
  ,step.document_identification AS step_document_identification
  ,step.customer_phone AS step_customer_phone
  ,step.billing_account_id AS step_billing_account_id 
FROM keepcoding.ivr_calls calls
LEFT JOIN keepcoding.ivr_modules module 
  ON module.ivr_id = calls.ivr_id
LEFT JOIN keepcoding.ivr_steps step
  ON step.ivr_id = module.ivr_id AND step.module_sequece = module.module_sequece
; 