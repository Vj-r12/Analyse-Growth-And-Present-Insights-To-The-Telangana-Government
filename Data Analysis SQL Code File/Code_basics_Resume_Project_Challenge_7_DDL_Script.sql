/*****     Code Basics Challenge 7     *****/ 


/*****     Analyse Growth and Present Insights to the Telangana Government     *****/


/*****     Table Creating Script    *****/


-- Creating Table Dim_date.

CREATE TABLE DIM_DATE (MONTH date,
					   MONTH_CHAR varchar,
					   QUARTER varchar,
					   FISCAL_YEAR int
					  ); 

-- Creating Table Dim_Districts.

CREATE TABLE DIM_DISTRICTS (DIST_CODE varchar,
							DISTRICT varchar
						   );

-- Creating Table Fact_Stamps.

CREATE TABLE FACT_STAMPS (DIST_CODE varchar,
						  MONTH date,
						  DOCUMENTS_REGISTERED_CNT bigint,
						  DOCUMENTS_REGISTERED_REV bigint,
						  ESTAMPS_CHALLANS_CNT bigint,
						  ESTAMPS_CHALLANS_REV bigint
						 );
						 
-- Creating Table Fact_Transport.
						 
CREATE TABLE FACT_TRANSPORT (DIST_CODE varchar,
							 MONTH date,
							 FUEL_TYPE_PETROL int,
							 FUEL_TYPE_DIESEL int,
							 FUEL_TYPE_ELECTRIC int,
							 FUEL_TYPE_OTHERS int
							 VEHICLECLASS_MOTORCYCLE int,
							 VEHICLECLASS_MOTORCAR int,
							 VEHICLECLASS_AUTORICKSHAW int,
							 VEHICLECLASS_AGRICULTURE int,
							 VEHICLECLASS_OTHERS int,
							 SEATCAPACITY_1_TO_3 int,
							 SEATCAPACITY_4_TO_6 int,
							 SEATCAPACITY_ABOVE_6 int,
							 BRAND_NEW_VEHICLES int,
							 PRE_OWNED_VEHICLES int,
							 CATEGORY_NON_TRANSPORT int,
							 CATEGORY_TRANSPORT int
							);
							
-- Creating Table Fact_Ipass.
							
CREATE TABLE FACT_IPASS (DIST_CODE varchar,
						 MONTH date,
						 SECTOR varchar,
						 INVESTMENTS_IN_CR float,
						 NUMBER_OF_EMPLOYEES int
						);