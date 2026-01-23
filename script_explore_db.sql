-- Total number of pages read and total price if I bought the all the physical books 
SELECT 
	SUM(number_of_pages) AS total_number_of_pages,
	SUM(price) AS total_price
FROM books;

-- See top 5 books with higher page count
SELECT 
	title,
	number_of_pages
FROM books
ORDER BY number_of_pages DESC
LIMIT 5;

-- See all books read in 2025 in chronological order 
SELECT title, reading_date
FROM books 
ORDER BY books.reading_date ASC;

-- Author's age
SELECT 
	author, 
	year_of_birth
FROM authors
WHERE 
	year_of_birth = (SELECT min(year_of_birth) FROM authors) OR 
	year_of_birth = (SELECT max(year_of_birth) FROM authors);

-- Author's gender
SELECT 
	gender,
	count(author) AS number_of_authors -- the count function counts the rows of each group!
FROM authors
GROUP BY gender
ORDER BY number_of_authors DESC;

-- Author's country
SELECT
	country,
	count(author) AS number_of_authors
FROM authors
GROUP BY country
ORDER BY number_of_authors DESC;
