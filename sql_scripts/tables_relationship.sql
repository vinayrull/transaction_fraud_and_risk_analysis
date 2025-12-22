
----------------------------------------------------------------------------------------------------------
-- Data Validation
----------------------------------------------------------------------------------------------------------

select count(*)
from credit_card_transactions_raw; --24,386,900

select count(*)
from transactions_clean; --24,386,900

select count(*)
from user_cards_raw; --6146

select count(*)
from user_cards_clean; --6146

select count(*)
from user_info_raw; --2000

select count(*)
from user_info_clean; --2000

select min(trans_year), max(trans_year)
from transactions_clean;

select min(trans_month), max(trans_month)
from transactions_clean;

select min(trans_day), max(trans_day)
from transactions_clean;

select min(trans_time), max(trans_time)
from transactions_clean;

select count(amount)
from transactions_clean
where amount < 0;

select min(amount), max(amount)
from transactions_clean;

select min(year_pin_last_changed), max(year_pin_last_changed)
from user_cards_clean;

select credit_limit
from user_cards_clean
where credit_limit < 0;

select min(card_expiry_month), max(card_expiry_month)
from user_cards_clean;

select min(card_expiry_year), max(card_expiry_year)
from user_cards_clean;

select min(acc_open_month), max(acc_open_month)
from user_cards_clean;

select min(acc_open_year), max(acc_open_year)
from user_cards_clean;

select min(user_age), max(user_age)
from user_info_clean;

select min(retirement_age), max(retirement_age)
from user_info_clean;

select min(birth_month), max(birth_month)
from user_info_clean;

select min(birth_year), max(birth_year)
from user_info_clean;

select yearly_income_person 
from user_info_clean
where yearly_income_person < 0;

select total_debt 
from user_info_clean
where total_debt < 0;

select fico_score 
from user_info_clean
where fico_score < 0;


----------------------------------------------------------------------------------------------------------
-- Table Relationship
----------------------------------------------------------------------------------------------------------


-- in user_cards is the number of cards in card_index the same as the column in num_credit_cards in user_info
-- is max card_user in user_cards the same as number of columns in user_info
-- is max trans_user in transactions the same as number of columns in user_info

select max(card_user) + 1
from user_cards_clean; -- 2000

select count(*)
from user_info_clean; -- 2000

select max(trans_user) + 1
from transactions_clean; -- 2000

select t1.card_user, count(t1.card_index), t2.num_credit_cards
from user_cards_clean t1 join user_info_clean t2 on t1.card_user = t2.user_index
group by t1.card_user, t2.num_credit_cards
having count(t1.card_index) <> t2.num_credit_cards
order by t1.card_user asc; -- table is not empty

select t1.trans_user, max(t1.trans_card), max(t2.card_index)
from transactions_clean t1 join user_cards_clean t2 on t1.trans_user = t2.card_user
group by t1.trans_user
having max(t1.trans_card) <> max(t2.card_index)
order by t1.trans_user; -- table is empy trans_card < card_index

