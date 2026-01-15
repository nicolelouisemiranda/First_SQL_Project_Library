# SQL Study: Bookshelf Database

## Introduction

Structured query language (SQL) is a widely used programming language designed to interact with relational database management systems (RDBMS). Due to the fact it was created specifically for this purpose, it is highly efficient and has a high adoption rate among beginners.

The objective of this project is to practice the use of SQL to create and modify databases and also use its capabilities to provide insights from data. For this purpose, a bookshelf database was created containing all the books I have read in 2025, and some statistics were retrieved to analyze my reading patterns.

This project was developed using the software DBeaver Community, which is a Free Open-Source Database Management Tool. This software is recommended for personal projects and supports database systems like My SQL, MariaDB, PostgreSQL, SQLite, and others.

I started by planning the information I would collect about the books I read in 2025:

* Book title
* Author
* Country of origin of the author
* Year of birth of the author
* Gender of the author
* Number of pages
* Publisher
* Publishing date
* ISBN
* Reading date
* Status
* Book format
* Genre
* Price


[...]

## Database Creation

Using DBeaver, the first step was to create the library database and define the parent tables:

```
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
```

Then, I created the child table `books`:

```
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
```
## Data Insertion

The next step was to insert data in the tables. I tested two methods for this task: manually inserting data using SQL statements and bulk inserting data by importing a CSV file. For the smaller tables (`book_status`, `book_formats`, and `book_genres`), I chose to insert the data manually.

```
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
```
I created a CSV file based on an Excel spreadsheet where I collected the missing data needed to fill the remaining columns of the database tables. During my research, I noticed that some authors did not have their complete birth dates available online. Therefore, I decided to change the column `date_of_birth` to `year_of_birth` to keep the information consistent. To do this, I renamed the column using the command `RENAME COLUMN` and, for consistency, changed the column data type from `DATE` to `INT` with the following SQL commands:

```
-- Changing column name as I could not find the exact birth date of some authors
ALTER TABLE authors 
RENAME COLUMN date_of_birth TO year_of_birth;

-- Changing table column type accordingly
ALTER TABLE authors 
ALTER COLUMN year_of_birth TYPE INT
USING EXTRACT(YEAR FROM year_of_birth);
```

To store the bulk-inserted data, I created a temporary table with the same columns as the csv file. This allowed me to store the data temporarily before inserting it into the permanent tables of the database.
```
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
```






```
-- Handling null values and correcting number format
ALTER TABLE temporary_table 
ALTER COLUMN year_of_birth TYPE INT;

UPDATE temporary_table 
SET year_of_birth = 0
WHERE year_of_birth IS NULL;

-- Insert author data
INSERT INTO authors(author, gender, country, year_of_birth)
SELECT DISTINCT author, gender, country, NULLIF(year_of_birth, 0) -- Important to add DISTINCT as there are duplicated authors in the spreadsheet
FROM temporary_table;
```


```
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
```


## References
* IBM | [O que é linguagem de consulta estruturada (SQL)?](https://www.ibm.com/br-pt/think/topics/structured-query-language)
* DBeaver Community | [Free Universal Database Tool.](https://dbeaver.io/)
* Percona | [Why PostgreSQL NULL Values Break Your Queries (And How to Fix Them)](https://www.percona.com/blog/handling-null-values-in-postgresql/)
