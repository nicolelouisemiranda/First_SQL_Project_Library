-- Create parent tables
CREATE TABLE authors (
	author_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	author VARCHAR(50) NOT NULL,
	gender CHAR(6),
	country VARCHAR(50),
	date_of_birth DATE
);

CREATE TABLE publishers (
	publisher_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	publisher VARCHAR(50) NOT NULL
);

CREATE TABLE book_status (
	status  VARCHAR(11) PRIMARY KEY
);

CREATE TABLE book_formats (
	book_format VARCHAR(9) PRIMARY KEY
);

CREATE TABLE book_genres (
	genre VARCHAR(50) PRIMARY KEY
);

-- Create child table
CREATE TABLE books (
	book_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	title VARCHAR(255) NOT NULL,
	author_id INT NOT NULL,
	publisher_id INT NOT NULL,
	number_of_pages INT,
	publishing_date DATE,
	reading_date DATE DEFAULT CURRENT_DATE,
	status VARCHAR(11) NOT NULL DEFAULT 'reading',
	book_format VARCHAR(9) NOT NULL DEFAULT 'physical',
	genre VARCHAR(50) NOT NULL,
	isbn CHAR(13) UNIQUE ,
	price NUMERIC(10,2), -- physical book price on amazon
	
	CONSTRAINT fk_book_author
		FOREIGN KEY (author_id)
		REFERENCES authors(author_id),
		
	CONSTRAINT fk_book_publisher
		FOREIGN KEY (publisher_id)
		REFERENCES publishers(publisher_id),
		
	CONSTRAINT fk_book_status
		FOREIGN KEY (status)
		REFERENCES book_status(status),
		
	CONSTRAINT fk_book_format
		FOREIGN KEY (book_format)
		REFERENCES book_formats(book_format),
		
	CONSTRAINT fk_book_genre
		FOREIGN KEY (genre)
		REFERENCES book_genres(genre)
	
);

-- Inserting data

INSERT INTO book_status
VALUES
('read'),
('reading'),
('to be read'),
('interrupted');

INSERT INTO book_formats 
VALUES 
('ebook'),
('physical'),
('audiobook');

INSERT INTO book_genres 
VALUES
('romance'),
('poetry'),
('science fiction'),
('self-help');

-- Changing column name as I could not find the exact birth date of some authors
ALTER TABLE authors 
RENAME COLUMN date_of_birth TO year_of_birth;

-- Changing table column type accordingly
ALTER TABLE authors 
ALTER COLUMN year_of_birth TYPE INT
USING EXTRACT(YEAR FROM year_of_birth);

-- Inserting data via csv file
-- Inputting data into a temporary table
CREATE TABLE temporary_table(
	title VARCHAR(255),
	author VARCHAR(50),
	country VARCHAR(50),
	year_of_birth INT,
	gender VARCHAR(6),
	publisher VARCHAR(50),
	number_of_pages INT,
	publishing_date DATE,
	reading_date DATE,
	status VARCHAR(50),
	book_format VARCHAR(50),
	genre VARCHAR(50),
	isbn CHAR(13),
	price NUMERIC(10,2)

);

-- Insert data from spreadsheet to the table
-- COPY temporary_table FROM 'C:\Users\nlklo\Downloads\book_spreadsheet.csv' DELIMITER ',' CSV HEADER;

-- Handling null values and correcting number format
ALTER TABLE temporary_table 
ALTER COLUMN year_of_birth TYPE INT;

UPDATE temporary_table 
SET year_of_birth = 0
WHERE year_of_birth IS NULL;

-- Insert author data
INSERT INTO authors(author, gender, country, year_of_birth)
SELECT DISTINCT author, gender, country, year_of_birth -- Important to add DISTINCT as there are duplicated authors in the spreadsheet
FROM temporary_table;

-- Insert publisher data
INSERT INTO publishers(publisher)
SELECT DISTINCT publisher
FROM temporary_table;

-- Insert genre data
INSERT INTO book_genres(genre)
SELECT DISTINCT genre
FROM temporary_table
-- fixing error of genres that are already in the table
WHERE genre NOT IN (
	SELECT book_genres.genre 
	FROM book_genres
);

-- Insert data in books
-- Fixing issue with author_id and publisher_id by using JOIN
INSERT INTO books(title, author_id, publisher_id, number_of_pages, publishing_date, reading_date, status, book_format, genre, isbn, price)
SELECT 
	tt.title, 
	-- The author_id is not stored in the temporary_table, but in the authors table
	-- Using JOIN to match the author name from the tt to the authors table 
	-- But selecting only the author_id in for the books table
	a.author_id, 
	-- The same happens with publisher_id, which is not stored in the tt table
	-- Using the JOIN to match the publisher name 
	-- But selecting only the publisher Id
	p.publisher_id, 
	tt.number_of_pages, 
	tt.publishing_date, 
	tt.reading_date, 
	tt.status, 
	tt.book_format, 
	tt.genre, 
	tt.isbn, 
	tt.price
FROM temporary_table tt
JOIN authors a
	ON a.author = tt.author 
JOIN publishers p
	ON p.publisher = tt.publisher;
