--ACT Pre-Id
--Evan Kramer
--1/8/2018

--How many students are actively enrolled in grade 11?
SELECT isp.isp_id, isp.student_key, isp.first_name, isp.middle_name, isp.last_name, isp.date_of_birth, isp.primary_district_id, isp.primary_school_id, ig.assignment, isp.begin_date, isp.end_date
--SELECT COUNT(DISTINCT isp.student_key) 
    FROM instructional_grade ig
    INNER JOIN instructional_service_period isp ON ig.isp_id = isp.isp_id
    WHERE ig.assignment = '11' AND 
        TO_DATE(ig.ig_begin_date, 'DD-MON-YY') BETWEEN TO_DATE('01-JUL-17', 'DD-MON-YY') AND TO_DATE('08-JAN-18', 'DD-MON-YY') AND 
        (ig.ig_end_date IS NULL OR TO_DATE(ig_end_date, 'DD-MON-YY') >= TO_DATE('08-JAN-18', 'DD-MON-YY')) AND 
        isp.withdrawal_reason IS NULL AND 
        isp.school_year = 2017 AND 
        TO_DATE(isp.begin_date, 'DD-MON-YY') < TO_DATE('08-JAN-18', 'DD-MON-YY') AND 
        (isp.end_date IS NULL OR TO_DATE(isp.end_date, 'DD-MON-YY') >= TO_DATE('08-JAN-18', 'DD-MON-YY'));
        
--How many students are in the 2015 cohort?
SELECT scd.isp_id, scd.student_key, scd.first_name, scd.middle_name, isp.last_name, scd.date_of_birth, isp.primary_district_id, isp.primary_school_id, scd.assignment
--SELECT COUNT(DISTINCT scd.student_key)
    FROM studentcohortdata scd
    INNER JOIN instructional_service_period isp ON scd.isp_id = isp.isp_id
    WHERE cohortyear = 2015 AND 
        (scd.withdrawal_reason IS NULL OR scd.withdrawal_reason = 12);