-- Healthcare Data Analysis Project
-- Author: Student Portfolio Project
-- SQL Dialect: MySQL 8+
--
-- Objective:
-- Analyze hospital admissions, patient demographics, treatment costs,
-- doctor activity, insurance patterns, and discharge trends using SQL.
--
-- Dataset note:
-- The original CSV columns contain spaces. To keep the analysis readable,
-- import the CSV into healthcare_raw first, then use the clean view below.

CREATE DATABASE IF NOT EXISTS healthcare_project;
USE healthcare_project;

-- -------------------------------------------------------------
-- 1. Raw table structure
-- -------------------------------------------------------------
-- Import data/healthcare_dataset.csv into this table using MySQL Workbench:
-- Server > Data Import, or Table Data Import Wizard.
-- Dates in the CSV are stored as DD-MM-YYYY text, so they are converted later.

DROP TABLE IF EXISTS healthcare_raw;

CREATE TABLE healthcare_raw (
    `Name` VARCHAR(100),
    `Age` INT,
    `Gender` VARCHAR(20),
    `Blood Type` VARCHAR(5),
    `Medical Condition` VARCHAR(50),
    `Date of Admission` VARCHAR(20),
    `Doctor` VARCHAR(100),
    `Hospital` VARCHAR(150),
    `Insurance Provider` VARCHAR(50),
    `Billing Amount` DECIMAL(12, 2),
    `Room Number` INT,
    `Admission Type` VARCHAR(30),
    `Discharge Date` VARCHAR(20),
    `Medication` VARCHAR(50),
    `Test Results` VARCHAR(30)
);

-- -------------------------------------------------------------
-- 2. Clean analysis view
-- -------------------------------------------------------------
-- A view works like a reusable saved query. Here it standardizes names,
-- converts date text into DATE values, and calculates length of stay once.

DROP VIEW IF EXISTS healthcare;

CREATE VIEW healthcare AS
SELECT
    `Name` AS patient_name,
    `Age` AS age,
    `Gender` AS gender,
    `Blood Type` AS blood_type,
    `Medical Condition` AS medical_condition,
    STR_TO_DATE(`Date of Admission`, '%d-%m-%Y') AS admission_date,
    `Doctor` AS doctor,
    `Hospital` AS hospital,
    `Insurance Provider` AS insurance_provider,
    ROUND(`Billing Amount`, 2) AS billing_amount,
    `Room Number` AS room_number,
    `Admission Type` AS admission_type,
    STR_TO_DATE(`Discharge Date`, '%d-%m-%Y') AS discharge_date,
    `Medication` AS medication,
    `Test Results` AS test_results,
    DATEDIFF(
        STR_TO_DATE(`Discharge Date`, '%d-%m-%Y'),
        STR_TO_DATE(`Date of Admission`, '%d-%m-%Y')
    ) AS length_of_stay
FROM healthcare_raw;

-- -------------------------------------------------------------
-- 3. Data quality checks
-- -------------------------------------------------------------
-- These checks help confirm that the import worked correctly before analysis.

SELECT COUNT(*) AS total_records
FROM healthcare;

SELECT
    SUM(CASE WHEN patient_name IS NULL OR patient_name = '' THEN 1 ELSE 0 END) AS missing_patient_names,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN admission_date IS NULL THEN 1 ELSE 0 END) AS invalid_admission_dates,
    SUM(CASE WHEN discharge_date IS NULL THEN 1 ELSE 0 END) AS invalid_discharge_dates,
    SUM(CASE WHEN billing_amount IS NULL THEN 1 ELSE 0 END) AS missing_billing_amount
FROM healthcare;

SELECT
    MIN(admission_date) AS first_admission_date,
    MAX(admission_date) AS last_admission_date,
    MIN(discharge_date) AS first_discharge_date,
    MAX(discharge_date) AS last_discharge_date
FROM healthcare;

-- -------------------------------------------------------------
-- 4. Patient overview
-- -------------------------------------------------------------
-- Basic KPIs give a quick understanding of the patient population.

SELECT
    COUNT(*) AS total_patients,
    ROUND(AVG(age), 1) AS average_age,
    MIN(age) AS youngest_patient,
    MAX(age) AS oldest_patient,
    ROUND(AVG(length_of_stay), 1) AS average_stay_days,
    ROUND(AVG(billing_amount), 2) AS average_bill
FROM healthcare;

SELECT
    gender,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM healthcare), 2) AS patient_percent
FROM healthcare
GROUP BY gender
ORDER BY patient_count DESC;

-- CASE WHEN is used here to create simple age groups for trend analysis.
SELECT
    CASE
        WHEN age < 30 THEN '18-29'
        WHEN age BETWEEN 30 AND 44 THEN '30-44'
        WHEN age BETWEEN 45 AND 59 THEN '45-59'
        WHEN age BETWEEN 60 AND 74 THEN '60-74'
        ELSE '75+'
    END AS age_group,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount
FROM healthcare
GROUP BY age_group
ORDER BY MIN(age);

-- -------------------------------------------------------------
-- 5. Disease frequency and treatment patterns
-- -------------------------------------------------------------
-- This section finds the most common conditions and medications.

SELECT
    medical_condition,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM healthcare), 2) AS patient_percent,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 1) AS avg_stay_days
FROM healthcare
GROUP BY medical_condition
ORDER BY patient_count DESC;

-- Window function ranks medications inside each medical condition.
WITH medication_counts AS (
    SELECT
        medical_condition,
        medication,
        COUNT(*) AS prescription_count
    FROM healthcare
    GROUP BY medical_condition, medication
),
ranked_medications AS (
    SELECT
        medical_condition,
        medication,
        prescription_count,
        DENSE_RANK() OVER (
            PARTITION BY medical_condition
            ORDER BY prescription_count DESC
        ) AS medication_rank
    FROM medication_counts
)
SELECT
    medical_condition,
    medication,
    prescription_count
FROM ranked_medications
WHERE medication_rank = 1
ORDER BY medical_condition;

-- -------------------------------------------------------------
-- 6. Hospital performance metrics
-- -------------------------------------------------------------
-- Since many hospitals have small record counts, this query focuses on
-- hospitals with at least 10 patients for a fairer comparison.

WITH hospital_metrics AS (
    SELECT
        hospital,
        COUNT(*) AS patient_count,
        ROUND(AVG(length_of_stay), 1) AS avg_stay_days,
        ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
        SUM(CASE WHEN test_results = 'Normal' THEN 1 ELSE 0 END) AS normal_results,
        SUM(CASE WHEN test_results = 'Abnormal' THEN 1 ELSE 0 END) AS abnormal_results
    FROM healthcare
    GROUP BY hospital
)
SELECT
    hospital,
    patient_count,
    avg_stay_days,
    avg_billing_amount,
    normal_results,
    abnormal_results,
    ROUND(normal_results * 100.0 / patient_count, 2) AS normal_result_percent,
    RANK() OVER (ORDER BY patient_count DESC) AS volume_rank
FROM hospital_metrics
WHERE patient_count >= 10
ORDER BY patient_count DESC, avg_stay_days ASC;

-- -------------------------------------------------------------
-- 7. Doctor performance analysis
-- -------------------------------------------------------------
-- Doctor performance is summarized using patient volume, average bill,
-- average stay, and the share of normal test results.

WITH doctor_metrics AS (
    SELECT
        doctor,
        COUNT(*) AS patient_count,
        COUNT(DISTINCT hospital) AS hospitals_worked,
        ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
        ROUND(AVG(length_of_stay), 1) AS avg_stay_days,
        ROUND(SUM(CASE WHEN test_results = 'Normal' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS normal_result_percent
    FROM healthcare
    GROUP BY doctor
)
SELECT
    doctor,
    patient_count,
    hospitals_worked,
    avg_billing_amount,
    avg_stay_days,
    normal_result_percent,
    DENSE_RANK() OVER (ORDER BY patient_count DESC) AS doctor_volume_rank
FROM doctor_metrics
WHERE patient_count >= 3
ORDER BY patient_count DESC, normal_result_percent DESC;

-- -------------------------------------------------------------
-- 8. Treatment cost analysis
-- -------------------------------------------------------------
-- Billing is compared by condition, admission type, and insurance provider.

SELECT
    medical_condition,
    admission_type,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(SUM(billing_amount), 2) AS total_billing_amount
FROM healthcare
GROUP BY medical_condition, admission_type
ORDER BY medical_condition, avg_billing_amount DESC;

SELECT
    insurance_provider,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(MIN(billing_amount), 2) AS min_billing_amount,
    ROUND(MAX(billing_amount), 2) AS max_billing_amount,
    ROUND(SUM(billing_amount), 2) AS total_billing_amount
FROM healthcare
GROUP BY insurance_provider
ORDER BY total_billing_amount DESC;

-- Subquery compares each patient's bill with the overall average bill.
SELECT
    patient_name,
    medical_condition,
    hospital,
    billing_amount,
    ROUND(billing_amount - (SELECT AVG(billing_amount) FROM healthcare), 2) AS difference_from_avg_bill
FROM healthcare
WHERE billing_amount > (SELECT AVG(billing_amount) FROM healthcare)
ORDER BY difference_from_avg_bill DESC
LIMIT 20;

-- -------------------------------------------------------------
-- 9. Admission and discharge trends
-- -------------------------------------------------------------
-- Date functions help show monthly, quarterly, and yearly patient movement.

SELECT
    YEAR(admission_date) AS admission_year,
    COUNT(*) AS admissions,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 1) AS avg_stay_days
FROM healthcare
GROUP BY YEAR(admission_date)
ORDER BY admission_year;

SELECT
    DATE_FORMAT(admission_date, '%Y-%m') AS admission_month,
    COUNT(*) AS admissions,
    ROUND(SUM(billing_amount), 2) AS total_billing_amount
FROM healthcare
GROUP BY DATE_FORMAT(admission_date, '%Y-%m')
ORDER BY admission_month;

SELECT
    YEAR(admission_date) AS admission_year,
    QUARTER(admission_date) AS admission_quarter,
    COUNT(*) AS admissions,
    ROUND(AVG(length_of_stay), 1) AS avg_stay_days
FROM healthcare
GROUP BY YEAR(admission_date), QUARTER(admission_date)
ORDER BY admission_year, admission_quarter;

SELECT
    admission_type,
    COUNT(*) AS admission_count,
    ROUND(AVG(length_of_stay), 1) AS avg_stay_days,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount
FROM healthcare
GROUP BY admission_type
ORDER BY admission_count DESC;

-- -------------------------------------------------------------
-- 10. Patient status and risk grouping
-- -------------------------------------------------------------
-- This is not a medical diagnosis. It is a simple portfolio analysis label
-- based on test result and length of stay.

SELECT
    patient_name,
    age,
    medical_condition,
    test_results,
    length_of_stay,
    billing_amount,
    CASE
        WHEN test_results = 'Abnormal' AND length_of_stay >= 15 THEN 'High Follow-up Priority'
        WHEN test_results = 'Inconclusive' THEN 'Needs More Tests'
        WHEN test_results = 'Normal' AND length_of_stay <= 10 THEN 'Likely Stable'
        ELSE 'Monitor'
    END AS patient_status
FROM healthcare
ORDER BY
    CASE
        WHEN test_results = 'Abnormal' THEN 1
        WHEN test_results = 'Inconclusive' THEN 2
        ELSE 3
    END,
    length_of_stay DESC;

-- -------------------------------------------------------------
-- 11. Blood type analysis
-- -------------------------------------------------------------
-- This section is useful for simple operational planning examples.

SELECT
    blood_type,
    COUNT(*) AS patient_count
FROM healthcare
GROUP BY blood_type
ORDER BY patient_count DESC;

SELECT
    SUM(CASE WHEN blood_type = 'O-' THEN 1 ELSE 0 END) AS universal_donor_count,
    SUM(CASE WHEN blood_type = 'AB+' THEN 1 ELSE 0 END) AS universal_receiver_count
FROM healthcare;

-- Simple donor-recipient list. Same-hospital matches are shown first.
SELECT
    donor.patient_name AS donor_name,
    donor.age AS donor_age,
    donor.blood_type AS donor_blood_type,
    donor.hospital AS donor_hospital,
    receiver.patient_name AS receiver_name,
    receiver.blood_type AS receiver_blood_type,
    receiver.hospital AS receiver_hospital,
    CASE
        WHEN donor.hospital = receiver.hospital THEN 'Same Hospital'
        ELSE 'Different Hospital'
    END AS match_location
FROM healthcare AS donor
JOIN healthcare AS receiver
    ON donor.blood_type = 'O-'
   AND receiver.blood_type = 'AB+'
WHERE donor.age BETWEEN 20 AND 40
ORDER BY
    CASE WHEN donor.hospital = receiver.hospital THEN 1 ELSE 2 END,
    donor_hospital,
    receiver_hospital
LIMIT 50;

-- -------------------------------------------------------------
-- 12. Views for Tableau dashboard
-- -------------------------------------------------------------
-- These reusable views can be connected directly to Tableau.

CREATE OR REPLACE VIEW vw_dashboard_kpis AS
SELECT
    COUNT(*) AS total_patients,
    ROUND(SUM(billing_amount), 2) AS total_billing_amount,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 1) AS avg_stay_days,
    SUM(CASE WHEN test_results = 'Abnormal' THEN 1 ELSE 0 END) AS abnormal_test_count
FROM healthcare;

CREATE OR REPLACE VIEW vw_monthly_admissions AS
SELECT
    DATE_FORMAT(admission_date, '%Y-%m') AS admission_month,
    COUNT(*) AS admissions,
    ROUND(SUM(billing_amount), 2) AS total_billing_amount
FROM healthcare
GROUP BY DATE_FORMAT(admission_date, '%Y-%m');

CREATE OR REPLACE VIEW vw_condition_summary AS
SELECT
    medical_condition,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 1) AS avg_stay_days
FROM healthcare
GROUP BY medical_condition;

CREATE OR REPLACE VIEW vw_hospital_summary AS
SELECT
    hospital,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay), 1) AS avg_stay_days,
    ROUND(SUM(CASE WHEN test_results = 'Normal' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS normal_result_percent
FROM healthcare
GROUP BY hospital;
