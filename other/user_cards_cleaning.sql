

----------------------------------------------------------------------------------------------------------
-- Cleaning User_cards
----------------------------------------------------------------------------------------------------------


select *
from user_cards_raw;

create table user_cards_staging1
(LIKE user_cards_raw);

select * 
from user_cards_staging1;

insert into user_cards_staging1
select *
from user_cards_raw;


----------------------------------------------------------------------------------------------------------
-- Duplicates
----------------------------------------------------------------------------------------------------------


select *, 
row_number() OVER(partition by card_user, card_index) as row_numb
from user_cards_staging1;

with duplicate_user_cards as (
select *, 
row_number() OVER(partition by card_user, card_index) as row_numb
from user_cards_staging1
)
select * 
from duplicate_user_cards
where row_numb > 1; -- no duplicates found


----------------------------------------------------------------------------------------------------------
-- Standardise data
----------------------------------------------------------------------------------------------------------


select card_user, trim(card_user)
from user_cards_staging1
where card_user <> trim(card_user);


select card_index, trim(card_index)
from user_cards_staging1
WHERE card_index !~ '^\d+$';

alter table user_cards_staging1 
alter column card_user type integer
using card_user::integer;

select card_index, trim(card_index)
from user_cards_staging1
where card_index <> trim(card_index);

select card_index, trim(card_index)
from user_cards_staging1
WHERE card_index !~ '^\d+$';

alter table user_cards_staging1 
alter column card_index type integer
using card_index::integer;

select distinct card_brand
from user_cards_staging1;

select distinct card_type
from user_cards_staging1;

select card_number
from user_cards_staging1;

select card_number, trim(card_number)
from user_cards_staging1
where card_number <> trim(card_number);

select card_expires
from user_cards_staging1;

alter table user_cards_staging1
add column card_expiry_month integer,
add column card_expiry_year integer;

update user_cards_staging1 ucs 
set card_expiry_month = left(card_expires,2)::integer, card_expiry_year = right(card_expires,4)::integer;

select card_cvv, trim(card_cvv)
from user_cards_staging1
where card_cvv <> trim(card_cvv);

select card_cvv, trim(card_cvv)
from user_cards_staging1
WHERE card_cvv !~ '^\d+$';

select distinct card_has_chip
from user_cards_staging1;

alter table user_cards_staging1 
add column card_has_chip_bool boolean;

update user_cards_staging1
set card_has_chip_bool = case
	when card_has_chip = 'YES' then true
	when card_has_chip = 'NO' then False
	else null 
end;

alter table user_cards_staging1 
alter column cards_issued type integer 
using cards_issued::integer;

select  credit_limit
from user_cards_staging1;

update user_cards_staging1
set credit_limit = trim(credit_limit);

update user_cards_staging1
set credit_limit = regexp_replace(credit_limit, '[^0-9]', '', 'g');

alter table user_cards_staging1
alter column credit_limit type bigint
using credit_limit::bigint;

select acct_open_date
from user_cards_staging1;

alter table user_cards_staging1
add column acc_open_month integer,
add column acc_open_year integer;

update user_cards_staging1
set acc_open_month = left(acct_open_date,2)::integer, acc_open_year = right(acct_open_date,4)::integer;

select year_pin_last_changed
from user_cards_staging1
where length(year_pin_last_changed) <> 4;

alter table user_cards_staging1
alter column year_pin_last_changed type integer
using year_pin_last_changed::integer;

select distinct card_on_dark_web
from user_cards_staging1

alter table user_cards_staging1 
add column card_on_dark_web_bool boolean;

update user_cards_staging1
set card_on_dark_web_bool = case
	when card_on_dark_web = 'Yes' then true
	when card_on_dark_web = 'No' then False
	else null 
end;


----------------------------------------------------------------------------------------------------------
-- look at nulls and blanks
----------------------------------------------------------------------------------------------------------


select * 
from user_cards_staging1
where (card_on_dark_web_bool is null);

select * 
from user_cards_staging1
where (card_cvv is null or card_cvv = '');


----------------------------------------------------------------------------------------------------------
-- Remove columns & rows & rename
----------------------------------------------------------------------------------------------------------


alter table user_cards_staging1
drop column card_expires,
drop column card_has_chip,
drop column acct_open_date,
drop column card_on_dark_web;

alter table user_cards_staging1
rename card_has_chip_bool to card_has_chip;

alter table user_cards_staging1
rename card_on_dark_web_bool to card_on_dark_web;

alter table user_cards_staging1
rename to user_cards_clean;

