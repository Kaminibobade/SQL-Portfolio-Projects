1. Who is the senior most employee based on job title?
/* arranges data in descending order to get senior employee */
Select * from employee
order by levels DESC
Limit 1;

2.Which countries have the most Invoices?
/* arranged count of order in descending order */
Select billing_country, count(invoice_id) as Total_invoice from invoice
group by billing_country
order by Total_invoice desc;

3.What are top 3 values of total invoice?
/* need top 3 so ordered in descending */
Select total from invoice
Order by total DESC
Limit 3; /*limit record till 3 */

4.Which city has the best customers?
We would like to throw a promotional Music Festival in the city we made the most money.
Write a query that returns one city that has the 
highest sum of invoice totals. Return both the city name & 
sum of all invoice totals?
/* grouped data by city because */
Select billing_city, sum(total) as total_invoice_sum from invoice
Group by billing_city
Order by total_invoice_sum DESC;

5.Who is the best customer? The customer 
who has spent the most money will be declared the best customer.
Write a query that returns the person who has spent the most money?
/* joined two tables to get invoice amount and limit the record to 1 */
Select c.customer_id, c.first_name, c.last_name, sum(i.total) as invoice_amount
from customer as c
Join invoice as i
on c.customer_id = i.customer_id
Group by c.customer_id
order by invoice_amount DESC
limit 1;
--------------------------------------------------------------------
6.Write query to return the email, first name, last name, 
& Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A 
/* Joined three tables */ 
Select distinct email, first_name, last_name 
from customer as c
Join invoice as i
On c.customer_id = i.customer_id
Join invoice_line as il
On i.invoice_id = il.invoice_id
where track_id In(             
	select track_id from track as t
     Join genre as g 
     On t.genre_id = g.genre_id
     where g.name like 'Rock')   /* apply subquery by joining two table to match pattern */
Order by email;

7.Let's invite the artists who have written the most rock music in our
dataset. 
Write a query that returns the Artist name and total track count
of the top 10 rock bands?
/* Joined 4 tables to get artist name and his songs */

Select a.artist_id, a.name, count(a.artist_id) as total_songs
from track as t
Join album as a1
On a1.album_id = t.album_id
Join artist as a
On a.artist_id = a1.artist_id
Join genre as g 
On g.genre_id = t.genre_id
where g.name = 'Rock'
Group by a.artist_id
Order by Total_songs Desc
Limit 10; /* Limit the data top 10*/

8. Return all the track names that have a song length longer than 
the average song length.Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first
/* Used subquery to compare with avg song length */
Select name, Milliseconds
from track
where Milliseconds > (select Avg(Milliseconds) as ag_song_length from track)
Order by Milliseconds DESC;

--------------------------------------------------------------------------

9.Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent

/* find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the 
Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, 
and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id /* these joins will give us artist id and his name */
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id /* artist id should match with bsa table */
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

10. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest count of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres

/* There are two parts in question first most popular music genre and second need data at country level. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, 
	customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1; /* to get 1st record only because it will highest count */

Or

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


11. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount

/* first find the most spent on music for each country and second filter the data for respective customers. */

*/

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

Or 

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;