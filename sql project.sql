CREATE DATABASE music_database;
-- Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC limit 1;

-- Which countries have the most Invoices?


SELECT COUNT(total), billing_country FROM invoice
GROUP BY billing_country
ORDER BY COUNT(total) DESC
LIMIT 1;

-- What are top 3 values of total invoice?

SELECT * FROM invoice
order by total desc limit 3;

-- Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals

select sum(total), billing_city FROM invoice
GROUP BY billing_city
ORDER BY sum(total) DESC limit 1;

-- Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY total DESC limit 1;

-- Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT
    email, first_name, last_name
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE
    track_id IN (SELECT 
            track_id
        FROM
            track
                JOIN
            genre ON track.genre_id = genre.genre_id
        WHERE
            genre.name = 'ROCK')
ORDER BY email;


-- Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands

SELECT artist.artist_id, artist.name, count(artist.artist_id) as number_of_song FROM track
JOIN album2 ON album2.album_id = track.album_id
JOIN artist ON artist.artist_id = album2.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name like 'ROCK'
group by artist.artist_id, artist.name 
ORDER BY number_of_song DESC limit 10;

-- Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first

SELECT name, milliseconds FROM track
WHERE milliseconds > (
 SELECT AVG(milliseconds) as avg_track_length from track)
ORDER BY milliseconds DESC;

-- Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent


WITH best_selling_artist as
(select artist.artist_id,artist.name AS artist_name, sum(invoice_line.quantity*invoice_line.unit_price) as total_spent from invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album2 ON album2.album_id = track.album_id
JOIN artist ON artist.artist_id = album2.artist_id
GROUP BY  artist.artist_id,artist.name 
ORDER BY total_spent DESC 
limit 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY SUM(il.unit_price*il.quantity) DESC;