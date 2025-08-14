DROP TABLE IF EXISTS claims;

CREATE TABLE claims (
    `Month` varchar(255),
    `WeekOfMonth` int,
    `DayOfWeek` varchar(255),
    `Make` varchar(255),
    `AccidentArea` varchar(255),
    `DayOfWeekClaimed` varchar(255),
    `MonthClaimed` varchar(255),
    `WeekOfMonthClaimed` int,
    `Sex` varchar(255),
    `MaritalStatus` varchar(255),
    `Age` int,
    `Fault` varchar(255),
    `PolicyType` varchar(255),
    `VehicleCategory` varchar(255),
    `VehiclePrice` varchar(255),
    `VehiclePrice_min` int,
    `VehiclePrice_max` int,
    `FraudFound_P` int,
    `PolicyNumber` int,
    `RepNumber` int,
    `Deductible` int,
    `DriverRating` int,
    `Days_Policy_Accident` varchar(255),
    `Days_Policy_Accident_Min` int,
    `Days_Policy_Accident_Max` int,
    `Days_Policy_Claim` varchar(255), 
    `Days_Policy_Claim_Min` int,
    `Days_Policy_Claim_max` int,
    `PastNumberOfClaims` varchar(255),
    `AgeOfVehicle` varchar(255),
    `AgeOfPolicyHolder` varchar(255),
    `PoliceReportFiled` varchar(255),
    `WitnessPresent` varchar(255),
    `AgentType` varchar(255),
    `NumberOfSuppliments` varchar(255),
    `AddressChange_Claim` varchar(255),
    `NumberOfCars` varchar(255),
    `Year` int,
    `BasePolicy` varchar(255)
);

select * from claims;

-- Fraud Percentage Calculation 

SELECT
	(sum(case 
			when FraudFound_P = 1 Then 1
				else 0 
                end)*100)/count(*) AS fraud_percentage
from claims;

-- Top policy types in fraud cases

select 
	policytype,
    count(*) as Number_of_frauds
from claims
where FraudFound_P >= 1
group by PolicyType
order by 2 desc;

-- 	Average deductible per policy type

select
	PolicyType,
    round(avg(Deductible),2) as average_deductible
from claims
group by PolicyType;

-- 	Claim trends by month and vehicle category

select 
	Month,
    VehicleCategory,
    count(*) as total_claims
from claims
group by Month, VehicleCategory
order by Month, total_claims desc;

-- 	Average claim settlement time

select 
	round(avg((Days_Policy_Claim_max + Days_Policy_Claim_Min)/2),2) as average_claim_settlement_time
from claims;

--  Claims frequency per customer

with claims_mapped as (
select
	PolicyNumber,
    Case when PastNumberOfClaims = 'none' then 0
		when PastNumberOfClaims = '1' then 1
        when PastNumberOfClaims = '2 to 4' then 3
        when PastNumberOfClaims = 'more than 4' then 4
	end as claim_frequency
from claims
)
select 
	PolicyNumber,
	claim_frequency
from claims_mapped;

--  Top 5 most claimed policy types

with claims_mapped as (
select
	PolicyType,
    Case when PastNumberOfClaims = 'none' then 0
		when PastNumberOfClaims = '1' then 1
        when PastNumberOfClaims = '2 to 4' then 3
        when PastNumberOfClaims = 'more than 4' then 4
	end as claim_frequency
from claims
)
select
	PolicyType,
    sum(claim_frequency) as total_claims
from claims_mapped
group by PolicyType
order by 2 desc
limit 5;

-- 	High-value or suspicious claims (Fraud detection flags)

WITH claims_mapped AS (
    SELECT
        PolicyNumber,
        PolicyType,
        VehicleCategory,
        VehiclePrice_max,
        Deductible,
        fraudFound_P AS FraudFlag,
        CASE 
            WHEN PastNumberOfClaims = 'none' THEN 0
            WHEN PastNumberOfClaims = '1' THEN 1
            WHEN PastNumberOfClaims = '2 to 4' THEN 3
            WHEN PastNumberOfClaims = 'more than 4' THEN 5
        END AS past_claims_num
    FROM claims
)
SELECT
    PolicyNumber,
    PolicyType,
    VehicleCategory,
    VehiclePrice_max,
    Deductible,
    past_claims_num,
    FraudFlag
FROM claims_mapped
WHERE FraudFlag = 1
   OR VehiclePrice_max > 60000
   OR past_claims_num >= 3
ORDER BY FraudFlag DESC, VehiclePrice_max DESC;

