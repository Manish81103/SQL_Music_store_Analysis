/* ======================================Questions============================================  */
                     
/* Q1: Who is the senior most employee based on job title? */                

select Title,employee_id,first_name,last_name,levels
from Employee
order by levels desc
limit 1;

/* Q2: Which countries have the most Invoices? */

select billing_country,count(invoice_id)
from invoice
group by billing_country
limit 1 ;

/* Q3: What are top 3 values of total invoice? */

select invoice_id,sum(total) as total
from invoice
group by invoice_id
order by sum(total) desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city,sum(total) as total
from invoice
group by billing_city
order by sum(total) desc
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money. */

select cus.customer_id,cus.first_name,sum(inv.total) as spending
from customer cus
join 
invoice inv
on cus.customer_id = inv.customer_id
group by cus.customer_id,cus.first_name
order by spending desc
limit 1;


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct cus.email,cus.first_name,cus.last_name,ge.name
from customer cus
join invoice inv 
on cus.customer_id = inv.customer_id
join invoice_line inl
on inv.invoice_id = inl.invoice_id
join track tr
on tr.track_id = inl.track_id
join genre ge
on ge.genre_id = tr.genre_id
where ge.name like 'Rock' 
order by cus.email;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


select ar.name,count(track_id),ge.name as Genre
from track t 
join album al on al.album_id = t.album_id
join genre ge on ge.genre_id = t.genre_id
join artist ar on ar.artist_id = al.artist_id
where ge.name='ROCk'
group by ge.name,ar.name
order by count(track_id) desc
limit 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */

select name,milliseconds
from track
where milliseconds > (select avg(milliseconds)
from track)
order by milliseconds desc;


/* Q9: Make a stored procedure to display artist name and total amount of their album sales */  

delimiter $$
create procedure P_total()
begin
select art.name , round(sum(inv.total),1) as total
from artist art
join album alb
on art.artist_id = alb.artist_id 
join track tr
on alb.album_id = tr.album_id 
join invoice_line invl
on tr.track_id = invl.track_id
join invoice inv
on invl.invoice_id = inv.invoice_id
group by art.name
order by sum(inv.total) desc;

end $$
delimiter ;

call P_total();



/* Q10: Find how much amount spent by each customer on artists? Write a query to return 
 customer name, artist name and total spent */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;