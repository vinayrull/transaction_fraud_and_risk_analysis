

----------------------------------------------------------------------------------------------------------
-- How does fraud risk vary when users’ daily spending exceeds their own 30-day rolling average?
----------------------------------------------------------------------------------------------------------


with user_daily as ( 
	select trans_user, trans_year, trans_month, trans_day, sum(amount) as total_for_day
	from transactions_clean
	where amount > 0		
	group by trans_user, trans_year, trans_month, trans_day),
user_month as (
	with user_avg_for_month as ( 
		select trans_user, trans_year, trans_month, trans_day, sum(amount) as total_for_day1
		from transactions_clean
		where amount > 0	
		group by trans_user, trans_year, trans_month, trans_day)
	select trans_user, trans_year, trans_month, avg(total_for_day1) as average_for_month
	from user_avg_for_month
	group by trans_user, trans_year, trans_month),
user_fraud as (
	select trans_user, trans_year, trans_month, trans_day, count(is_fruad) as fraud_count
	from transactions_clean
	where amount > 0 and is_fruad = 'Yes'
	group by trans_user, trans_year, trans_month, trans_day)
select 
	case 
		when t1.total_for_day > t2.average_for_month * 12 then '12x'
		when t1.total_for_day > t2.average_for_month * 10 then '10x'
		when t1.total_for_day > t2.average_for_month * 7 then '7x'
		when t1.total_for_day > t2.average_for_month * 5 then '5x'
		when t1.total_for_day > t2.average_for_month * 3 then '3x'
		else '0-3x'
	end as bracket,
	count(*)
from user_daily t1
left join user_month t2
on t1.trans_user = t2.trans_user
and t1.trans_year = t2.trans_year
and t1.trans_month = t2.trans_month
left join user_fraud t3
on t1.trans_user = t3.trans_user
and t1.trans_year = t3.trans_year
and t1.trans_month = t3.trans_month
and t1.trans_day = t3.trans_day
where fraud_count is not null
group by bracket;


----------------------------------------------------------------------------------------------------------
-- Which merchants have the highest fraud rate?
----------------------------------------------------------------------------------------------------------


with fraud_rates2 as (
	with fraud_rates1 as (
		select t1.merchant_name, t1.total_fraud_transactions, t2.total_transactions
		from (
			select merchant_name, count(*) as "total_fraud_transactions" 
			from transactions_clean 
			where is_fruad = 'Yes' 
			group by merchant_name) t1
		join (
			select merchant_name, count(*) as "total_transactions" 
			from transactions_clean 
			group by merchant_name) t2
		on t1.merchant_name = t2.merchant_name)
	select *, round((total_fraud_transactions::numeric / total_transactions) * 100, 2) as fraud_rate
	from fraud_rates1)
select *
from fraud_rates2
where fraud_rate = 100
order by total_transactions desc limit 10;


----------------------------------------------------------------------------------------------------------
 -- Which merchant cities have the highest fraud?
----------------------------------------------------------------------------------------------------------


with fraud_rates2 as (
	with fraud_rates1 as (
		select t1.merchant_city, t1.total_fraud_transactions, t2.total_transactions
		from (
			select merchant_city, count(*) as total_fraud_transactions
			from transactions_clean
			where is_fruad = 'Yes'
			group by merchant_city) t1
		join (
			select merchant_city, count(*) as total_transactions
			from transactions_clean
			group by merchant_city) t2
		on t1.merchant_city = t2.merchant_city)
	select *, round((total_fraud_transactions::numeric / total_transactions), 4) * 100 as fraud_rate
	from fraud_rates1)
select *
from fraud_rates2
where fraud_rate > 20 and total_transactions > 20
order by fraud_rate desc;


select merchant_name , count(*)
from transactions_clean
where merchant_city = 'Funafuti'
group by merchant_name ;


----------------------------------------------------------------------------------------------------------
-- How does fraud differ based on transaction type?
----------------------------------------------------------------------------------------------------------


with fraud_transactions as (
	select t1.use_chip, t1.total_fraud_transactions, t2.total_transactions
	from (
		select use_chip, count(*) as "total_fraud_transactions"
		from transactions_clean
		where is_fruad = 'Yes'
		group by use_chip) t1
	join (
		select use_chip, count(*) as "total_transactions"
		from transactions_clean
		group by use_chip) t2
	on t1.use_chip = t2.use_chip)
select *, round((total_fraud_transactions::numeric / total_transactions) * 100, 2) as "fraud_per_transaction_type"
from fraud_transactions
order by "fraud_per_transaction_type" desc;


select 
use_chip, 
round(count(*) / (
	select count(*)::numeric 
	from transactions_clean 
	where is_fruad = 'Yes')*100, 2) as total_fraud_per_transaction_type
from transactions_clean
where is_fruad = 'Yes'
group by use_chip
order by total_fraud_per_transaction_type desc;


----------------------------------------------------------------------------------------------------------
-- How many credit cards fall into utilisation bands based on average monthly spend versus credit limit?
----------------------------------------------------------------------------------------------------------


with monthly_total as (
	select t1.trans_user, t1.trans_card, t1.trans_year, t1.trans_month, sum(t1.amount) as total_in_month, max(t2.credit_limit) as credit_limit
	from transactions_clean t1
	join user_cards_clean t2
	on t2.card_user = t1.trans_user
	and t2.card_index = t1.trans_card
	where t2.card_type = 'Credit' and credit_limit <> 0 and (t1.trans_year * 12) + t1.trans_month >= 24230
	group by t1.trans_user, t1.trans_card, t1.trans_year, t1.trans_month),
monthly_average as (
	select trans_user, trans_card, avg(total_in_month) as average_monthly_past_year, max(credit_limit) as credit_limit
	from monthly_total
	group by trans_user, trans_card),
spending_brackets as (
	select *, 	
		case 
			when average_monthly_past_year / credit_limit > 0.9 then '90+'
			when average_monthly_past_year / credit_limit > 0.6 then '60-90'
			when average_monthly_past_year / credit_limit > 0.3 then '30-60'
			else '0-30'
		end as spending_bracket
	from monthly_average)
select spending_bracket, count(*)
from spending_brackets
group by spending_bracket;


----------------------------------------------------------------------------------------------------------
-- For each user, what percentage of total spend goes to their top merchant?
----------------------------------------------------------------------------------------------------------


with merchant_spending as (
	select trans_user, merchant_name, mcc, sum(amount) as amount_spent_at_top_merchant
	from transactions_clean
	where amount > 0
	group by trans_user, merchant_name, mcc),
ranked as (
	select *,rank() over(partition by trans_user order by amount_spent_at_top_merchant desc) as rank
	from merchant_spending),
ranked_1 as (
	select *
	from ranked
	where rank = 1),
total_spent as (
	select trans_user, sum(amount) as total_spent
	from transactions_clean
	where amount > 0
	group by trans_user)
select t1.trans_user, t1.merchant_name, t1.mcc, t1.amount_spent_at_top_merchant, t2.total_spent,
round((t1.amount_spent_at_top_merchant / t2.total_spent) * 100, 2) as percentage_amount_spent_at_top_merchant
from ranked_1 t1
join total_spent t2
on t1.trans_user = t2.trans_user
where amount_spent_at_top_merchant > 1000000
order by percentage_amount_spent_at_top_merchant desc;


with merchant_spending as (
	select trans_user, merchant_name, mcc, sum(amount) as amount_spent_at_top_merchant
	from transactions_clean
	where amount > 0
	group by trans_user, merchant_name, mcc),
ranked as (
	select *,rank() over(partition by trans_user order by amount_spent_at_top_merchant desc) as rank_num
	from merchant_spending)
select mcc, count(*) as mcc_count_by_user_top_merchant
from ranked
where rank_num = 1
group by mcc
order by mcc_count_by_user_top_merchant desc limit 10;	

