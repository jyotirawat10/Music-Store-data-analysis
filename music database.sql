use music_database

--ques1 who is the senior most employee based on job title

select top 1 first_name , last_name from employee
order by levels desc

--ques2 which country have the most invoices

select top 1 billing_country , count(*)  as cnt from invoice
group by billing_country
order by cnt desc

--ques3 what are the top 3 value of total invoice

select top 3 total from invoice
order by total desc

--ques4 which city has the best customers.we would like to throw a promotional music festival in the city we made the most money.
--write a query that returns the one city that has the highest sum of invoice totals.
---return both the city name and sum of all invoice totals

select top 1 billing_city , sum(total) as invoice_total from invoice
group by billing_city
order by invoice_total desc

--ques5 who is the best customer? the customer who has spend the most money will be declared the best customer
--write a query that returns the person  who has spent the most money

select top 1 t1.customer_id ,t1.first_name , t1.last_name ,sum(t2.total) as total_spend from customer as t1 
join invoice as t2 on t1.customer_id = t2.customer_id
group by  t1.customer_id ,t1.first_name , t1.last_name
order by total_spend desc

--ques6 write query to return the email,first name, last name,& genre of all  rock music listeners.
--return your list ordered alphabetically by email starting with A

select distinct t1.email , t1.first_name , t1.last_name  from customer as t1
join invoice as t2 on t1.customer_id = t2.customer_id
join invoice_line as t3 on t3.invoice_id = t2.invoice_id
where track_id in (select t4.track_id from track as t4
                   join genre as t5 on t4.genre_id = t5.genre_id
                    where t5.name like 'rock')

order by t1.email asc

--ques7 lets invite the artists who have written the most rock music in our dataset.
--write a query that return the artist name and total track count of the top 1o rock bands


select top 10 t1.artist_id , t1.name , count(t1.artist_id) as total_songs from artist as t1
join album as t2 on t1.artist_id = t2.artist_id
join track as t3 on t3.album_id = t2.album_id
join genre as t4 on t4.genre_id = t3.genre_id
where t4.name like 'rock'
group by t1.artist_id , t1.name
order by count(t1.artist_id) desc

--ques8 return  all the track name  that have the song lemgth longer than the average length.
--return the name and millisecongs for each track.order by the song lemgth with the longest songs listed first.

select name , milliseconds from track 
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc

--ques9 find how much amount spent by each customer on  top artists?
--write a query to return customer name,artist name,total spent

alter table invoice_line
alter column unit_price float

alter table invoice_line
alter column quantity int

select t1.customer_id ,t1.first_name , t1.last_name, t6.name , sum ( t3.unit_price * t3.quantity) as total_spend from customer as t1 
join invoice as t2 on t1.customer_id = t2.customer_id 
join invoice_line as t3 on t3.invoice_id = t2.invoice_id
join track as t4 on t4.track_id = t3.track_id
join album as t5 on t5.album_id = t4.album_id
join artist as t6 on t6.artist_id = t5.artist_id
group by  t1.customer_id ,t1.first_name , t1.last_name, t6.name



with top_artist as 
(select top 1 t4.artist_id , t4.name , sum(t1.unit_price* t1.quantity) as cnt from invoice_line as t1
join track as t2 on t1.track_id = t2.track_id
join album as t3 on t3.album_id = t2.album_id
join artist as t4 on t4.artist_id = t3.artist_id
group by t4.artist_id , t4.name
order by sum(t1.unit_price* t1.quantity) desc
)
select t1.customer_id ,t1.first_name , t1.last_name, t6.name ,sum ( t3.unit_price * t3.quantity) as total_spend from customer as t1 
join invoice as t2 on t1.customer_id = t2.customer_id 
join invoice_line as t3 on t3.invoice_id = t2.invoice_id
join track as t4 on t4.track_id = t3.track_id
join album as t5 on t5.album_id = t4.album_id
join top_artist as t6 on t6.artist_id = t5.artist_id
group by  t1.customer_id ,t1.first_name , t1.last_name , t6.name
order by total_spend desc

--ques 10 we want to find out the most popular music genre for each country
--we deteremine the most popular genre as the genre with the highest amount of purchases.
-- write a query that return each country along with the top genre. for countries where 
-- maximum no of purchases is shared return all genres

invoice ,invoiceline,track,genre

with popular_genre as 
(select t1.billing_country ,t4.name, count(t4.genre_id) as no_of_purchases,
ROW_NUMBER() over (partition by t1.billing_country order by count(t4.genre_id) desc) as row_no
from invoice as t1 
join invoice_line as t2 on t1.invoice_id = t2.invoice_id
join track as t3 on t3.track_id = t2.track_id
join genre as t4 on t4.genre_id = t3.genre_id
group by t1.billing_country ,t4.name

)
select * from popular_genre where row_no <= 1


order by  t1.billing_country asc , no_of_purchases desc

--ques 11 write a query that detemines the customer that has spent the most on music for each country.
--write a query that returns the country along with the top customer and how much they spent.
--for countries where the top amount  spent is shared,provide all customers who spent this amount

with top_customer as
(select t1.customer_id , t1.first_name , t1.last_name , t2.billing_country, sum(t3.unit_price* t3.quantity) as total_spend ,
ROW_NUMBER() over (partition by t2.billing_country order by sum(t3.unit_price* t3.quantity) desc) as row_no
from customer as t1
join invoice as t2 on t1.customer_id =t2.customer_id
join invoice_line as t3 on t3.invoice_id = t2.invoice_id
group by t1.customer_id , t1.first_name , t1.last_name , t2.billing_country
)
select * from top_customer where row_no <=1
