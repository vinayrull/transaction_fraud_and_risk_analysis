

----------------------------------------------------------------------------------------------------------
-- Cleaning transactions
----------------------------------------------------------------------------------------------------------


select * 
from credit_card_transactions_raw;

create table transactions_staging1
(like credit_card_transactions_raw);

select * from transactions_staging1;

insert into transactions_staging1 
select *
from credit_card_transactions_raw;


----------------------------------------------------------------------------------------------------------
-- Check for duplicates 
----------------------------------------------------------------------------------------------------------


with duplicate_transaction_staging1 as ( 
select *,
row_number() over(partition by trans_user, trans_card, trans_year,trans_month,trans_day,trans_time,amount) as row_numb
from transactions_staging1)
select *
from duplicate_transaction_staging1
where row_numb > 1; -- need to chnage types for some columns first, will come back for duplicates


----------------------------------------------------------------------------------------------------------
-- Standardising data
----------------------------------------------------------------------------------------------------------


select * 
from transactions_staging1;

select trans_user, trim(trans_user)
from transactions_staging1
where trans_user <> trim(trans_user);

select * 
from transactions_staging1
where trans_user !~ '^\d+$';

select *
from transactions_staging1
where trans_user = '';

alter table transactions_staging1
alter column trans_user type integer
using trans_user::integer;

select trans_card, trim(trans_card)
from transactions_staging1
where trans_card <> trim(trans_card);

select * 
from transactions_staging1
where trans_card !~ '^\d+$';

alter table transactions_staging1
alter column trans_card type integer
using trans_card::integer;

select trans_year, trim(trans_year)
from transactions_staging1
where trans_year <> trim(trans_year);

select * 
from transactions_staging1
where trans_year !~ '^\d+$';

alter table transactions_staging1
alter column trans_year type integer
using trans_year::integer;

select trans_month, trim(trans_month)
from transactions_staging1
where trans_month <> trim(trans_month);

select * 
from transactions_staging1
where trans_month !~ '^\d+$';

alter table transactions_staging1
alter column trans_month type integer
using trans_month::integer;

select trans_day, trim(trans_day)
from transactions_staging1
where trans_day <> trim(trans_day);

select * 
from transactions_staging1
where trans_day !~ '^\d+$';

alter table transactions_staging1
alter column trans_day type integer
using trans_day::integer;

select trans_time
from transactions_staging1;

select trans_time, trim(trans_time)
from transactions_staging1
where trans_time <> trim(trans_time);

select * 
from transactions_staging1
where (trans_time !~ '^\d+$' and trans_time !~ ':');

alter table transactions_staging1
alter column trans_time type time
using trans_time::time;

select amount, trim(amount)
from transactions_staging1
where amount <> trim(amount);

select amount
from transactions_staging1;

create table transactions_staging2
(like transactions_staging1);

insert into transactions_staging2
select *
from transactions_staging1;

update transactions_staging2
set amount = regexp_replace(amount, '[^0-9\.-]', '', 'g');

alter table transactions_staging2
alter column amount type numeric
using amount::numeric;

select distinct use_chip
from transactions_staging2;

select merchant_name
from transactions_staging2;

select merchant_name, trim(merchant_name)
from transactions_staging2
where merchant_name <> trim(merchant_name);

select * 
from transactions_staging2
where (merchant_name !~ '^\d+$' and merchant_name !~ '-');

alter table transactions_staging2
alter column merchant_name type bigint
using merchant_name::bigint;

select distinct merchant_city
from transactions_staging2;

select merchant_city, trim(merchant_city)
from transactions_staging2
where merchant_city <> trim(merchant_city);

select distinct merchant_city
from transactions_staging2
where merchant_city !~ '^[A-Za-z\s]+$';

select distinct merchant_state
from transactions_staging2;

select merchant_state, trim(merchant_state)
from transactions_staging2
where merchant_state <> trim(merchant_state);

select distinct merchant_state
from transactions_staging2
where merchant_state !~ '^[A-Za-z\s]+$';

select distinct zip
from transactions_staging2;

select zip, trim(zip)
from transactions_staging2
where zip <> trim(zip);

select distinct zip
from transactions_staging2
where zip !~ '^[0-9]+$' and zip !~ '.';

alter table transactions_staging2
alter column zip type numeric
using zip::numeric;

select distinct mcc
from transactions_staging2;

select mcc, trim(mcc)
from transactions_staging2
where mcc <> trim(mcc);

select distinct mcc
from transactions_staging2
where mcc !~ '^[0-9]+$';

alter table transactions_staging2
alter column mcc type integer
using mcc::integer;

select distinct errors
from transactions_staging2;

select distinct is_fruad
from transactions_staging2;


----------------------------------------------------------------------------------------------------------
-- check for duplicate rows
----------------------------------------------------------------------------------------------------------


select *
from transactions_staging2;

with duplicate as (
select *,
row_number() over(partition by trans_user, trans_card, trans_year,trans_month, 
trans_day, trans_time, amount,use_chip, merchant_name,merchant_city, merchant_state,zip,
mcc, errors, is_fruad) as row_numb
from transactions_staging2
)
select * 
from duplicate 
where row_numb > 1;

-- duplicates are found but there is possabilty that a transaction was made 
-- by same perosn within the same minute, since no seconds are shown cant confirm
-- so will keep all transactions


----------------------------------------------------------------------------------------------------------
-- look at blanks and nulls 
----------------------------------------------------------------------------------------------------------


select is_fruad
from transactions_staging2
where is_fruad = '';

select * 
from transactions_staging2;

select merchant_city, merchant_state
from transactions_staging2
where merchant_city <> 'ONLINE'
and merchant_state is null;

select distinct merchant_state, zip
from transactions_staging2
where merchant_state is not null
and zip is null;

----------------------------------------------------------------------------------------------------------
-- Rename
----------------------------------------------------------------------------------------------------------


alter table transactions_staging2
rename to transactions_clean;

