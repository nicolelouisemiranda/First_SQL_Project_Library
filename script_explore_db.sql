-- See all books read in 2025 in chronological order 
SELECT title, reading_date
FROM books 
ORDER BY books.reading_date ASC;

-- Total number of pages read and total price if I bought the all the physical books 
SELECT 
	SUM(number_of_pages) AS total_number_of_pages,
	SUM(price) AS total_price
FROM books;

-- Author's age
SELECT
	MIN(year_of_birth) AS oldest_author,
	MAX(year_of_birth) AS youngest_author
FROM authors;
