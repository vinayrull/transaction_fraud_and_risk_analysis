
----------------------------------------------------------------------------------------------------------
-- Cleaning user_info
----------------------------------------------------------------------------------------------------------


select * 
from user_info_raw;

create table user_info_staging1
(like user_info_raw);

insert into user_info_staging1 
select*
from user_info_raw;


----------------------------------------------------------------------------------------------------------
-- Check for duplicates 
----------------------------------------------------------------------------------------------------------


select *
from user_info_staging1;


select user_name, address,
count(*)
from user_info_staging1
group by user_name, address
having count(*) > 1;
-- no duplicates


----------------------------------------------------------------------------------------------------------
-- Create index
----------------------------------------------------------------------------------------------------------


ALTER TABLE user_info_staging1
ADD COLUMN user_index BIGINT;

WITH numbered AS (
  SELECT
    ctid,
    ROW_NUMBER() OVER () - 1 AS rn
  FROM user_info_staging1
)
UPDATE user_info_staging1
SET user_index = numbered.rn
FROM numbered
WHERE user_info_staging1.ctid = numbered.ctid; -- Chatgpt help


----------------------------------------------------------------------------------------------------------
-- Standardise data
----------------------------------------------------------------------------------------------------------


select *
from user_info_staging1;

select user_name
from user_info_staging1
where user_name !~  '^[A-Za-z\s]+$';

select user_name, trim(user_name)
from user_info_staging1
where user_name <> trim(user_name);

select user_name, initcap(user_name)
from user_info_staging1
where user_name <> initcap(user_name);

select distinct user_age
from user_info_staging1;

alter table user_info_staging1
alter column user_age type integer
using user_age::integer;

select distinct retirement_age
from user_info_staging1;

select retirement_age, trim(retirement_age)
from user_info_staging1
where retirement_age <> trim(retirement_age);

alter table user_info_staging1
alter column retirement_age type integer
using retirement_age::integer;

select distinct birth_year
from user_info_staging1;

select birth_year, trim(birth_year)
from user_info_staging1
where birth_year <> trim(birth_year);

alter table user_info_staging1
alter column birth_year type integer
using birth_year::integer;

select distinct birth_month
from user_info_staging1;

select birth_month, trim(birth_month)
from user_info_staging1
where birth_month <> trim(birth_month);

select birth_month, trim(birth_month)
from user_info_staging1
where birth_month = '12';

alter table user_info_staging1
alter column birth_month type integer
using birth_month::integer;

select distinct gender
from user_info_staging1;

select address
from user_info_staging1;

select address, trim(address)
from user_info_staging1
where address <> trim(address);

select address
from user_info_staging1
where address !~ '^[A-Za-z0-9\s]+$';

select distinct apartment
from user_info_staging1;

select apartment
from user_info_staging1
where (apartment !~ '^[0-9]+$') 
and apartment <> '';

UPDATE user_info_staging1
SET apartment = NULL
WHERE TRIM(apartment) = '';

alter  table user_info_staging1
alter column apartment type integer
using apartment::integer;

select distinct city
from user_info_staging1;

select city, trim(city)
from user_info_staging1
where city <> trim(city);

select city
from user_info_staging1
where (city !~ '^[A-Za-z\s]+$');

select distinct state
from user_info_staging1;

select state, trim(state)
from user_info_staging1
where state <> trim(state);

select distinct zipcode
from user_info_staging1;

select zipcode, trim(zipcode)
from user_info_staging1
where zipcode <> trim(zipcode);

select zipcode
from user_info_staging1
where (zipcode !~ '^[0-9]+$');

alter  table user_info_staging1
alter column zipcode type integer
using zipcode::integer;

select distinct latitude
from user_info_staging1;

select latitude, trim(latitude)
from user_info_staging1
where latitude <> trim(latitude);

select latitude
from user_info_staging1
where (latitude !~ '^[0-9]+$') and latitude = '.';

alter  table user_info_staging1
alter column latitude type numeric
using latitude::numeric;

select distinct latitude
from user_info_staging1;

select latitude, trim(latitude)
from user_info_staging1
where latitude <> trim(latitude);

select latitude
from user_info_staging1
where (latitude !~ '^[0-9]+$') and latitude <> '.';

alter  table user_info_staging1
alter column latitude type numeric
using latitude::numeric;

select distinct longitude
from user_info_staging1;

select longitude, trim(longitude)
from user_info_staging1
where longitude <> trim(longitude);

select longitude
from user_info_staging1
where (longitude !~ '^-?\d+(\.\d+)?$');

alter  table user_info_staging1
alter column longitude type numeric
using longitude::numeric;

select per_capita_income_zipcode
from user_info_staging1;

update user_info_staging1 
set per_capita_income_zipcode = regexp_replace(per_capita_income_zipcode, '[^0-9]', '', 'g');

update user_info_staging1 
set yearly_income_person = regexp_replace(yearly_income_person, '[^0-9]', '', 'g');

update user_info_staging1 
set total_debt = regexp_replace(total_debt, '[^0-9]', '', 'g');

alter table user_info_staging1
alter column per_capita_income_zipcode type integer
using per_capita_income_zipcode::integer;

alter table user_info_staging1
alter column yearly_income_person type integer
using yearly_income_person::integer;

alter table user_info_staging1
alter column total_debt type integer
using total_debt::integer;

select fico_score, trim(fico_score)
from user_info_staging1
where fico_score <> trim(fico_score);

select fico_score
from user_info_staging1
where (fico_score !~ '^[0-9]+$');

alter table user_info_staging1
alter column fico_score type integer
using fico_score::integer;

select distinct "Num Credit Cards"
from user_info_staging1;

alter table user_info_staging1
alter column "Num Credit Cards" type integer
using "Num Credit Cards"::integer;


----------------------------------------------------------------------------------------------------------
-- Look at blanks and nulls
----------------------------------------------------------------------------------------------------------


select zipcode
from user_info_staging1
where zipcode is null 
or state = '';

select "Num Credit Cards"
from user_info_staging1
where "Num Credit Cards" is null;
-- non found


----------------------------------------------------------------------------------------------------------
-- Remove rows & columns & rename
----------------------------------------------------------------------------------------------------------


alter table user_info_staging1 
rename "Num Credit Cards" to num_credit_cards;

alter table user_info_staging1
rename to user_info_clean;

