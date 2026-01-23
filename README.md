# SQL Study: Bookshelf Database

_This project focuses on building a personal bookshelf database using SQL to practice database creation, data modeling, and data insertion techniques. Using PostgreSQL and DBeaver, I designed relational tables, which enables the analysis of my 2025 reading patterns._

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

Based on this list I planned to create 6 different tables: 

* A table to store book information
* A table to store author information
* A table to store publisher information
* A table to store book genres
* A table to store book formats (audiobook, physical, ebook)
* A table to store book status (read, reading, interrupted, etc.)

The relationships between these tables follow a one-to-many (1:N) structure, meaning that one record in a table can be related to multiple records in another table. For example, an author can have multiple books, and a publisher can also have multiple books in its catalog. For this reason, the books table was designed as a child table, with foreign keys referencing the corresponding rows in the parent tables.

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
Below is an image of the database diagram illustrating the relationships between the tables:

<img src="db_diagram.png" alt="Database Diagram">

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

The first issue I faced when transferring data from the temporary_table to the parent tables was the NULL value in one of the entries of the `year_of_birth` column, specifically for the author "Daniel Martins de Barros". I noticed that the command was not transferring the data from the `temporary_table` to the `authors` table. After some research, I learned that PostgreSQL treats NULL values as UNKNOWN rather than FALSE. This causes some commands to behave differently than expected. To overcome this issue, I used the `NULLIF` function to convert the null value to zero. 

```
-- Handling null values
-- Insert author data
INSERT INTO authors(author, gender, country, year_of_birth)
SELECT DISTINCT author, gender, country, NULLIF(year_of_birth, 0) -- Important to add DISTINCT as there are duplicated authors in the spreadsheet
FROM temporary_table;
```
Next, I transferred the publishers and genres data from the `temporary_table` to their respective tables. During this step, I had to adapt the code to handle cases where some book genres present in the `temporary_table` already existed in the `book_genres` table. Without this adjustment, the insertion would fail due to duplicate entries, since genre is defined as a primary key in the `book_genres` table.

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

Finally, I inserted the remaining data in the `books` table. This step was particularly complicated because the `author_id` and `publisher_id` columns must be filled with the primary keys corresponding to each author and publisher. However, this information was not stored in the `temporary_table` but in the `authors` and `publishers` table. After some reasearch, I found that the best way to insert the data correctly was by using the `JOIN` clause.

```
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
```

With this step completed, all tables were filled with their respective data. Since the `temporary_table` was no longer needed, it was removed from the database.

```
-- Deleting the temporary table
DROP TABLE temporary_table;
```

## Resulting Tables

Result for the `book_status` table:

```
status     |
-----------+
read       |
reading    |
to be read |
interrupted|
```

Result for the `book_formats` table:

```
book_format|
-----------+
ebook      |
physical   |
audiobook  |
```

Result for the `book_genres` table:

```
genre          |
---------------+
romance        |
poetry         |
science fiction|
self-help      |
fiction        |
non-fiction    |
science-fiction|
```

Result for the `publishers` table:

```
publisher_id|publisher           |
------------+--------------------+
           1|Editora Aleph       |
           2|Companhia das Letras|
           3|Darkside            |
           4|Paidos              |
           5|Principis           |
           6|Dublinense          |
           7|Rocco               |
           8|Record              |
           9|Fabrica231          |
          10|Editora Sextante    |
          11|Morro Branco        |
          12|BestBolso           |
          13|Cultrix             |
          14|Planeta Minotauro   |
          15|Editora Agora       |
          16|Intrinseca          |
          17|Galera              |
          18|Editora Nos         |
```

Result for the `authors` table:

```
author_id|author                  |gender|country                 |year_of_birth|
---------+------------------------+------+------------------------+-------------+
        1|Marshall B Rosenberg    |Man   |United States of America|         1934|
        2|Mariana Salomao Carrara |Female|Brazil                  |         1986|
        3|Bill Bryson             |Man   |United States of America|         1951|
        4|John Scalzi             |Man   |United States of America|         1969|
        5|Blake Crouch            |Man   |United States of America|         1978|
        6|Simon Singh             |Man   |United Kingdom          |         1964|
        7|Mary Shelley            |Female|United Kingdom          |         1797|
        8|Rebecca Yarros          |Female|United States of America|         1981|
        9|Adrian Tchaikovsky      |Man   |United Kingdom          |         1972|
       10|Daniela Arbex           |Female|Brazil                  |         1973|
       11|Irvin D Yalom           |Man   |United States of America|         1931|
       12|Daniel Martins de Barros|Man   |Brazil                  |             |
       13|Rebecca Solnit          |Female|United States of America|         1961|
       14|Graciliano Ramos        |Man   |Brazil                  |         1940|
       15|Jacqueline Harpman      |Female|Belgium                 |         1929|
       16|Colleen Hoover          |Female|United States of America|         1979|
       17|Isaac Asimov            |Man   |Russia                  |         1959|
       18|Bram Stoker             |Man   |Ireland                 |         1847|
       19|Robert Louis Stevenson  |Man   |United Kingdom          |         1850|
       20|Jonathan Haidt          |Man   |United States of America|         1963|
       21|Mary Pearson            |Female|United States of America|         1955|
       22|Won-pyung Sohn          |Female|South Korea             |         1979|
       23|Arthur C Clarke         |Man   |United Kingdom          |         1917|
       24|Iain Reid               |Man   |Canada                  |         1981|
       25|Ailton Krenak           |Man   |Brazil                  |         1953|
```

Result for the `books` table:

```
book_id|title                                                                                               |author_id|publisher_id|number_of_pages|publishing_date|reading_date|status|book_format|genre          |isbn         |price|
-------+----------------------------------------------------------------------------------------------------+---------+------------+---------------+---------------+------------+------+-----------+---------------+-------------+-----+
      1|A Fall of Moondust                                                                                  |       23|           1|            312|     25/08/2022|  09/07/2025|read  |ebook      |science fiction|9788576575122|60.92|
      2|I Robot                                                                                             |       17|           1|            320|     24/11/2014|  14/04/2025|read  |ebook      |science fiction|9788576572008|57.60|
      3|Old Mans War                                                                                        |        4|           1|            368|     18/04/2016|  24/03/2025|read  |ebook      |science fiction|9788576572992|28.00|
      4|O Amanhã não está a Venda                                                                           |       25|           2|             24|     18/04/2020|  06/08/2025|read  |ebook      |non-fiction    |9788554517328| 0.00|
      5|The Anxious Generation: How the Great Rewiring of Childhood Is Causing an Epidemic of Mental Illness|       20|           2|            440|     12/06/2024|  18/06/2025|read  |ebook      |non-fiction    |9788535938531|49.93|
      6|Shakespeare: The World as a Stage                                                                   |        3|           2|            200|     29/10/2008|  06/01/2025|read  |physical   |non-fiction    |9788535913330|60.26|
      7|The Kiss of Deception                                                                               |       21|           3|            384|     12/05/2016|  24/01/2025|read  |ebook      |romance        |9788566636864|39.06|
      8|Frankenstein                                                                                        |        7|           3|            304|     06/02/2017|  17/09/2025|read  |ebook      |science-fiction|9788594540188|55.90|
      9|A Matter of Life and Death                                                                          |       11|           4|            208|     01/11/2021|  11/10/2025|read  |ebook      |non-fiction    |9786555355192|41.23|
     10|The Strange Case of Dr Jekyll and Mr Hyde                                                           |       19|           5|             96|     05/06/2019|  01/10/2025|read  |ebook      |science-fiction|9788594318121|12.93|
     11|Dracula                                                                                             |       18|           5|            368|     27/04/2020|  29/08/2025|read  |ebook      |fiction        |9786555520002|21.89|
     12|I Who Have Never Known Man                                                                          |       15|           6|            192|     15/09/2021|  30/05/2025|read  |ebook      |science fiction|9786555530445|59.42|
     13|Almond                                                                                              |       22|           7|            288|     31/03/2023|  06/06/2025|read  |ebook      |fiction        |9786555323283|33.65|
     14|Vidas Secas                                                                                         |       14|           8|            176|     04/02/2019|  29/05/2025|read  |physical   |fiction        |9788501114785|29.90|
     15|I'm Thinking of Ending Things                                                                       |       24|           9|            224|     13/04/2021|  26/04/2025|read  |ebook      |fiction        |9786555320954|37.43|
     16|O Lado Bom do Lado Ruim                                                                             |       12|          10|            160|     14/02/2020|  14/04/2025|read  |ebook      |self-help      |9788543109312|34.94|
     17|Children of Time                                                                                    |        9|          11|            520|     19/09/2022|  16/02/2025|read  |ebook      |science fiction|9786586015614|46.00|
     18|Fermats Last Theorem                                                                                |        6|          12|            272|     24/07/2014|  27/08/2025|read  |physical   |non-fiction    |9788577994281|39.00|
     19|Men Explain Things to Me                                                                            |       13|          13|            208|     13/07/2017|  23/06/2025|read  |ebook      |non-fiction    |9788531614163|35.64|
     20|The Fourth Wing                                                                                     |        8|          14|            544|     18/03/2024|  18/08/2025|read  |ebook      |romance        |9788542225853|65.76|
     21|Nonviolent Communication                                                                            |        1|          15|            280|     05/06/2021|  22/05/2025|read  |ebook      |self-help      |9788571832640|69.70|
     22|Holocausto Brasileiro                                                                               |       10|          16|            280|     11/03/2019|  17/02/2025|read  |ebook      |non-fiction    |9788551004630|48.90|
     23|Upgrade                                                                                             |        5|          16|            304|     16/08/2023|  22/07/2025|read  |ebook      |science-fiction|9786555606331|46.45|
     24|Recursion                                                                                           |        5|          16|            320|     03/08/2023|  05/05/2025|read  |ebook      |science fiction|9786555606560|48.90|
     25|Verity                                                                                              |       16|          17|            320|     09/03/2020|  22/11/2025|read  |ebook      |fiction        |9788501117847|33.85|
     26|Se Deus me Chamar não Vou                                                                           |        2|          18|            160|     25/04/2024|  01/12/2025|read  |ebook      |fiction        |9786585832380|64.00|
     27|É Sempre a Hora da Nossa Morte Amem                                                                 |        2|          18|            240|     25/08/2021|  01/11/2025|read  |ebook      |fiction        |9786586135374|57.00|
```
## Exploring the Data
The first two questions I wanted to answer by analyzing the books data were:
* What is the total number of pages I read in 2025?
* If I had bought the physical versions of all the books I read, how much would I have spent?

To answer these questions, I wrote the following query:
```
-- Total number of pages read and total price if I bought the all the physical books 
SELECT 
	SUM(number_of_pages) AS total_number_of_pages,
	SUM(price) AS total_price
FROM books;
```
Result:
```
total_number_of_pages|total_price|
---------------------+-----------+
                 7512|    1178.26|
```
Therefore, I read 7512 pages in 2025. This would have cost me over one thousand reais if I had bought all these books in physical format instead of reading e-books.

Still analyzing the number of pages, I wrote the following query to check which were the five longest books I read:

```
-- See top 5 books with higher page count
SELECT 
	title,
	number_of_pages
FROM books
ORDER BY number_of_pages DESC
LIMIT 5;
```
Result:
```
title                                                                                               |number_of_pages|
----------------------------------------------------------------------------------------------------+---------------+
The Fourth Wing                                                                                     |            544|
Children of Time                                                                                    |            520|
The Anxious Generation: How the Great Rewiring of Childhood Is Causing an Epidemic of Mental Illness|            440|
The Kiss of Deception                                                                               |            384|
Old Mans War                                                                                        |            368|
```
Here, we can see that The Fourth Wing is the longest book, with 544 pages.

I also checked the books I read in chronological order using the following query:
```
-- See all books read in 2025 in chronological order 
SELECT title, reading_date
FROM books 
ORDER BY books.reading_date ASC;
```
Result:
```
title                                                                                               |reading_date|
----------------------------------------------------------------------------------------------------+------------+
Shakespeare: The World as a Stage                                                                   |  06/01/2025|
The Kiss of Deception                                                                               |  24/01/2025|
Children of Time                                                                                    |  16/02/2025|
Holocausto Brasileiro                                                                               |  17/02/2025|
Old Mans War                                                                                        |  24/03/2025|
O Lado Bom do Lado Ruim                                                                             |  14/04/2025|
I Robot                                                                                             |  14/04/2025|
I'm Thinking of Ending Things                                                                       |  26/04/2025|
Recursion                                                                                           |  05/05/2025|
Nonviolent Communication                                                                            |  22/05/2025|
Vidas Secas                                                                                         |  29/05/2025|
I Who Have Never Known Man                                                                          |  30/05/2025|
Almond                                                                                              |  06/06/2025|
The Anxious Generation: How the Great Rewiring of Childhood Is Causing an Epidemic of Mental Illness|  18/06/2025|
Men Explain Things to Me                                                                            |  23/06/2025|
A Fall of Moondust                                                                                  |  09/07/2025|
Upgrade                                                                                             |  22/07/2025|
O Amanhã não está a Venda                                                                           |  06/08/2025|
The Fourth Wing                                                                                     |  18/08/2025|
Fermats Last Theorem                                                                                |  27/08/2025|
Dracula                                                                                             |  29/08/2025|
Frankenstein                                                                                        |  17/09/2025|
The Strange Case of Dr Jekyll and Mr Hyde                                                           |  01/10/2025|
A Matter of Life and Death                                                                          |  11/10/2025|
É Sempre a Hora da Nossa Morte Amem                                                                 |  01/11/2025|
Verity                                                                                              |  22/11/2025|
Se Deus me Chamar não Vou                                                                           |  01/12/2025|
```
From these results, it is possible to see that I started the year alternating between science fiction and other genres. Around September, I went through a phase of gothic literature, reading Dracula, Frankenstein, and The Strange Case of Dr Jekyll and Mr Hyde one after the other.

```
-- Author's age
SELECT 
	author, 
	year_of_birth
FROM authors
WHERE 
	year_of_birth = (SELECT min(year_of_birth) FROM authors) OR 
	year_of_birth = (SELECT max(year_of_birth) FROM authors);
```
```
author                  |year_of_birth|
------------------------+-------------+
Mariana Salomao Carrara |         1986|
Mary Shelley            |         1797|
```
```
-- Author's gender
SELECT 
	gender,
	count(author) AS number_of_authors -- the count function counts the rows of each group!
FROM authors
GROUP BY gender
ORDER BY number_of_authors DESC;
```
```
gender|number_of_authors|
------+-----------------+
Man   |               16|
Female|                9|
```

```
-- Author's country
SELECT
	country,
	count(author) AS number_of_authors
FROM authors
GROUP BY country
ORDER BY number_of_authors DESC;
```
```
country                 |number_of_authors|
------------------------+-----------------+
United States of America|               10|
United Kingdom          |                5|
Brazil                  |                5|
Belgium                 |                1|
Russia                  |                1|
South Korea             |                1|
Ireland                 |                1|
Canada                  |                1|
```
```
-- Group books by genre
SELECT 
	genre,
	count(title) AS number_of_books
FROM books
GROUP BY genre
ORDER BY number_of_books DESC;
```
```
genre          |number_of_books|
---------------+---------------+
fiction        |              7|
non-fiction    |              7|
science fiction|              6|
science-fiction|              3|
self-help      |              2|
romance        |              2|
```

Fix this issue!
```
-- Fixing the issue of formatting with the science-fiction genre
UPDATE books 
SET genre = 'science-fiction'
WHERE genre = 'science fiction';

-- Testing results when grouping books by genre
SELECT 
	genre,
	count(title) AS number_of_books
FROM books
GROUP BY genre
ORDER BY number_of_books DESC;
```
```
genre          |number_of_books|
---------------+---------------+
science-fiction|              9|
fiction        |              7|
non-fiction    |              7|
self-help      |              2|
romance        |              2|
```

```
-- Did I read more than one book from any of the authors?
SELECT 
    b.title,
    a.author
FROM books b
JOIN authors a
    ON a.author_id = b.author_id
WHERE b.author_id IN (SELECT author_id FROM books GROUP BY author_id HAVING COUNT(author_id) > 1)
ORDER BY a.author DESC;
```
```
title                              |author                  |
-----------------------------------+------------------------+
Se Deus me Chamar não Vou          |Mariana Salomao Carrara |
É Sempre a Hora da Nossa Morte Amem|Mariana Salomao Carrara |
Upgrade                            |Blake Crouch            |
Recursion                          |Blake Crouch            |
```

## References
* IBM | [O que é linguagem de consulta estruturada (SQL)?](https://www.ibm.com/br-pt/think/topics/structured-query-language)
* DBeaver Community | [Free Universal Database Tool.](https://dbeaver.io/)
* Dio | [Boas Práticas para a Criação de Tabelas em Bancos de Dados SQL](https://www.dio.me/en/articles/boas-praticas-para-a-criacao-de-tabelas-em-bancos-de-dados-sql)
* Percona | [Why PostgreSQL NULL Values Break Your Queries (And How to Fix Them)](https://www.percona.com/blog/handling-null-values-in-postgresql/)
* RelationalDBDesign | [Linking Tables with Primary Keys and Foreign Keys](https://www.relationaldbdesign.com/database-design/module2/linking-relational-database-tables.php?utm_source=chatgpt.com)
* DataCamp | [SQL Foreign Key](https://www.datacamp.com/tutorial/foreign-key)
* Redgate | [What Is a One-to-Many Relationship in a Database?](https://www.red-gate.com/blog/one-to-many-relationship)
* Wikipedia | [One-to-many (data model)](https://en.wikipedia.org/wiki/One-to-many_(data_model))
* DataCamp | [SQL Subquery: A Comprehensive Guide](https://www.datacamp.com/tutorial/sql-subquery)
* 
