/*****     Code Basics Challenge 7     *****/ 

/*****     Analyse Growth and Present Insights to the Telangana Government     *****/


SELECT * FROM DIM_DATE;
SELECT * FROM DIM_DISTRICTS;
SELECT * FROM FACT_STAMPS;
SELECT * FROM FACT_TRANSPORT;
SELECT * FROM FACT_IPASS;  


/*****     STAMP REGISTRATION ANALYSIS     *****/ 


/* Q1. How does the revenue generated from document registration vary across districts in Telangana?
List down the top 5 districts that showed the highest document registration revenue growth between FY 2019 and 2022. */

SELECT FACT_STAMPS.DIST_CODE,DISTRICT,
	SUM(DOCUMENTS_REGISTERED_REV) AS TOTAL_DOCUMENTS_REGISTERED_REVENUE
FROM FACT_STAMPS
JOIN DIM_DISTRICTS ON FACT_STAMPS.DIST_CODE = DIM_DISTRICTS.DIST_CODE
WHERE  MONTH BETWEEN '2019-04-01' and '2023-03-31'
GROUP BY FACT_STAMPS.DIST_CODE,DISTRICT
ORDER BY TOTAL_DOCUMENTS_REGISTERED_REVENUE DESC
LIMIT 5; 

/* Q2. How does the revenue generated from document registration compare to the revenue generated from e-stamp challans across districts?
List down the top 5 districts where e-stamps revenue contributes significantly more to the revenue than the documents in FY 2022? */

SELECT FACT_STAMPS.DIST_CODE,DISTRICT,
	SUM(DOCUMENTS_REGISTERED_REV) AS DOCUMENTS_REGISTERED_REVENUE,
	SUM(ESTAMPS_CHALLANS_REV) AS E_STAMPS_CHALLANS_REVENUE
FROM FACT_STAMPS
JOIN DIM_DISTRICTS ON FACT_STAMPS.DIST_CODE = DIM_DISTRICTS.DIST_CODE
WHERE MONTH between '2022-04-01' and '2023-03-31'
GROUP BY FACT_STAMPS.DIST_CODE,DISTRICT
ORDER BY DOCUMENTS_REGISTERED_REVENUE DESC
LIMIT 5; 

-- Q4. Categorize districts into three segments based on their stamp registration revenue generation during the fiscal year 2021 to 2022.

SELECT FACT_STAMPS.DIST_CODE,DISTRICT,
	SUM(ESTAMPS_CHALLANS_REV) AS E_STAMPS_CHALLANS_REVENUE,
	CASE
		WHEN SUM(ESTAMPS_CHALLANS_REV) >= 3000000000 THEN 'High Revenue'
		WHEN SUM(ESTAMPS_CHALLANS_REV) BETWEEN 1000000000 AND 3000000000 THEN 'Medium Revenue'
		ELSE 'Low Revenue'
	END AS STAMP_REGISTRATION_REVENUE_SEGMENTS
FROM FACT_STAMPS
JOIN DIM_DISTRICTS ON FACT_STAMPS.DIST_CODE = DIM_DISTRICTS.DIST_CODE
WHERE MONTH BETWEEN '2021-04-01' and '2022-03-31'
GROUP BY FACT_STAMPS.DIST_CODE,DISTRICT
ORDER BY E_STAMPS_CHALLANS_REVENUE DESC;


/*****     TRANSPORTATION ANALYSIS     *****/


/* Q5. Investigate whether there is any correlation between vehicle sales and specific months or seasons in different districts. Are there any months 
or seasons that consistently show higher or lower sales rate, and if yes, what could be the driving factors? (Consider Fuel-Type category only) */

-- Note :- The sales column is calculated for four segments of fuel_type, considering all four financial years (2019,2020,2021,2022)

-- Determine the highest and lowest sales-performing months across different districts under fuel type category.

SELECT X.DIST_CODE,DISTRICT,MONTH_CHAR,SUM_OF_SALES_BY_FUEL_SEGMENTS,
	TOP_SALES_MONTH,LOW_SALES_MONTH FROM
	(
		WITH CTE AS
			(
				SELECT FACT_TRANSPORT.DIST_CODE,DIM_DISTRICTS.DISTRICT,TO_CHAR(MONTH,'month') AS MONTH_CHAR,
					   SUM(FUEL_TYPE_PETROL + FUEL_TYPE_OTHERS + FUEL_TYPE_ELECTRIC + FUEL_TYPE_DIESEL) AS SUM_OF_SALES_BY_FUEL_SEGMENTS
				FROM FACT_TRANSPORT JOIN DIM_DISTRICTS ON FACT_TRANSPORT.DIST_CODE = DIM_DISTRICTS.DIST_CODE
				WHERE MONTH BETWEEN '2019-04-01' AND '2023-03-31'
				GROUP BY FACT_TRANSPORT.DIST_CODE,MONTH_CHAR,DISTRICT
				ORDER BY DIST_CODE
			)
		SELECT DIST_CODE,DISTRICT,MONTH_CHAR,SUM_OF_SALES_BY_FUEL_SEGMENTS,
			FIRST_VALUE(MONTH_CHAR) OVER (PARTITION BY DIST_CODE ORDER BY SUM_OF_SALES_BY_FUEL_SEGMENTS DESC) AS TOP_SALES_MONTH,
			LAST_VALUE(MONTH_CHAR) OVER (PARTITION BY DIST_CODE ORDER BY SUM_OF_SALES_BY_FUEL_SEGMENTS DESC
										 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LOW_SALES_MONTH,
			RANK() OVER (PARTITION BY DIST_CODE ORDER BY SUM_OF_SALES_BY_FUEL_SEGMENTS DESC) AS RANK_BY_TOTAL_SALES_OF_FUEL_SEGMENTS
		FROM CTE
	) X
WHERE X.RANK_BY_TOTAL_SALES_OF_FUEL_SEGMENTS IN (1,12);

/* Q6. How does the distribution of vehicles vary by vehicle class (MotorCycle, MotorCar, AutoRickshaw, Agriculture) across different 
districts? Are there any districts with a predominant preference for a specific vehicle class? Consider FY 2022 for analysis. */

SELECT FACT_TRANSPORT.DIST_CODE,DISTRICT,
    SUM(VEHICLECLASS_MOTORCYCLE) AS TOTAL_VEHICLECLASS_MOTORCYCLE ,
	SUM(VEHICLECLASS_MOTORCAR) AS TOTAL_VEHICLECLASS_MOTORCAR,
	SUM(VEHICLECLASS_AUTORICKSHAW) AS TOTAL_VEHICLECLASS_AUTORICKSHAW,
	SUM(VEHICLECLASS_AGRICULTURE) AS TOTAL_VEHICLECLASS_AGRICULTURE
FROM FACT_TRANSPORT
JOIN DIM_DISTRICTS ON FACT_TRANSPORT.DIST_CODE = DIM_DISTRICTS.DIST_CODE
WHERE MONTH BETWEEN '2022-04-01' AND '2023-03-31' 
GROUP BY FACT_TRANSPORT.DIST_CODE,DISTRICT
ORDER BY TOTAL_VEHICLECLASS_MOTORCYCLE desc;

/* Q7. List down the top 3 and bottom 3 districts that have shown the highest and lowest vehicle sales growth during FY 2022 compared to FY 2021? 
(Consider and compare categories: Petrol, Diesel and Electric) */
	
WITH FY_21 AS
	          (
		        SELECT FACT_TRANSPORT.DIST_CODE,DISTRICT,SUM(FUEL_TYPE_PETROL) AS TOTAL_PETROL_SALES_FY_21,
			    SUM(FUEL_TYPE_DIESEL) AS TOTAL_DIESEL_SALES_FY_21,
			    SUM(FUEL_TYPE_ELECTRIC) AS TOTAL_ELECTRIC_SALES_FY_21
		        FROM FACT_TRANSPORT JOIN DIM_DISTRICTS ON FACT_TRANSPORT.DIST_CODE = DIM_DISTRICTS.DIST_CODE
		        WHERE MONTH BETWEEN '2021-04-01' AND '2022-03-31'
		        GROUP BY FACT_TRANSPORT.DIST_CODE,DISTRICT
			  ),
	FY_22 AS
	          (
				SELECT DIST_CODE,SUM(FUEL_TYPE_PETROL) AS TOTAL_PETROL_SALES_FY_22,
			    SUM(FUEL_TYPE_DIESEL) AS TOTAL_DIESEL_SALES_FY_22,
			    SUM(FUEL_TYPE_ELECTRIC) AS TOTAL_ELECTRIC_SALES_FY_22
		        FROM FACT_TRANSPORT
		        WHERE MONTH BETWEEN '2022-04-01' AND '2023-03-31'
		        GROUP BY DIST_CODE
		      )
SELECT FY_21.DIST_CODE,DISTRICT,TOTAL_PETROL_SALES_FY_21,TOTAL_PETROL_SALES_FY_22,(TOTAL_PETROL_SALES_FY_22 - TOTAL_PETROL_SALES_FY_21) AS PETROL_SALES_GROWTH_HIGH_LOW,
TOTAL_DIESEL_SALES_FY_21,TOTAL_DIESEL_SALES_FY_22,(TOTAL_DIESEL_SALES_FY_22 - TOTAL_DIESEL_SALES_FY_21) AS DIESEL_SALES_GROWTH_HIGH_LOW,
TOTAL_ELECTRIC_SALES_FY_21,TOTAL_ELECTRIC_SALES_FY_22,(TOTAL_ELECTRIC_SALES_FY_22 - TOTAL_ELECTRIC_SALES_FY_21) AS ELECTRIC_SALES_GROWTH_HIGH_LOW
FROM FY_21 JOIN FY_22 ON FY_21.DIST_CODE = FY_22.DIST_CODE
ORDER BY FY_21.DIST_CODE;


/*****     TS-IPASS ANALYSIS (TELANGANA STATE INDUSTRIAL PROJECT APPROVAL & SELF CERTIFICATION SYSTEM)     *****/


-- Q8. List down the top 5 sectors that have witnessed the most significant investments in FY 2022.

SELECT SECTOR,
	SUM(INVESTMENTS_IN_CR) AS TOTAL_INESTMENTS_IN_CR
FROM FACT_IPASS
WHERE MONTH BETWEEN '2022-04-01' AND '2023-03-31'
GROUP BY SECTOR
ORDER BY TOTAL_INESTMENTS_IN_CR DESC
LIMIT 5;

/* Q9. List down the top 3 districts, that have attracted the most significant sector investments during FY 2019 to 2022? ,
What factors could have led to the substantial investments in these particular districts? */ 

SELECT X.*
FROM 
   (
	    WITH CTE AS
			(
				SELECT FACT_IPASS.DIST_CODE,DISTRICT,SECTOR,
					SUM(INVESTMENTS_IN_CR) AS TOTAL_INVESTMENTS_IN_CR
				FROM FACT_IPASS
				full JOIN DIM_DISTRICTS ON FACT_IPASS.DIST_CODE = DIM_DISTRICTS.DIST_CODE 
				where month between '2019-04-01' and '2023-03-31'
				GROUP BY FACT_IPASS.DIST_CODE,SECTOR,DISTRICT
			)  
		SELECT *,RANK() OVER (PARTITION BY DIST_CODE
							  ORDER BY TOTAL_INVESTMENTS_IN_CR DESC) AS RANK_BY_TOTAL_INVESTMENTS_IN_CR
		FROM CTE
   ) X
WHERE X.RANK_BY_TOTAL_INVESTMENTS_IN_CR = 1
ORDER BY TOTAL_INVESTMENTS_IN_CR DESC
LIMIT 3; 

/* Q11. Are there any particular sectors that have shown substantial investment in multiple districts between FY 2021 and 2022? */
  
SELECT X.*
FROM
	(
		WITH CTE AS
			(
				SELECT FACT_IPASS.DIST_CODE,DISTRICT,SECTOR,
					SUM(INVESTMENTS_IN_CR) AS TOTAL_INVESTMENTS_IN_CR
				FROM FACT_IPASS
				JOIN DIM_DISTRICTS ON FACT_IPASS.DIST_CODE = DIM_DISTRICTS.DIST_CODE
				WHERE MONTH BETWEEN '2021-04-01' AND '2023-03-31'
				GROUP BY FACT_IPASS.DIST_CODE,SECTOR,DISTRICT
			)
		SELECT DIST_CODE,DISTRICT,SECTOR,TOTAL_INVESTMENTS_IN_CR,
			RANK() OVER (PARTITION BY DIST_CODE ORDER BY TOTAL_INVESTMENTS_IN_CR DESC) AS RANK_BY_TOTAL_INVESTMENTS_IN_CR
		FROM CTE
	) X
WHERE X.RANK_BY_TOTAL_INVESTMENTS_IN_CR = 1
ORDER BY TOTAL_INVESTMENTS_IN_CR DESC;

/* Q12. Can we identify any seasonal patterns or cyclicality in the investment trends for specific sectors? Do certain sectors 
experience higher investments during particular months? */ 

WITH CTE AS
	(
		SELECT SECTOR,
			TO_CHAR(MONTH,'month') AS MONTH_CHAR,
			SUM(INVESTMENTS_IN_CR) AS TOTAL_INVESTMENTS_IN_CR
		FROM FACT_IPASS
		GROUP BY SECTOR,MONTH_CHAR
		ORDER BY SECTOR
	)
SELECT SECTOR,MONTH_CHAR,TOTAL_INVESTMENTS_IN_CR,
	RANK() OVER (PARTITION BY SECTOR ORDER BY TOTAL_INVESTMENTS_IN_CR DESC) AS RANK_BY_TOTAL_INVESTMENTS_IN_CR
FROM CTE;