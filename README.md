# First_SQL_Project_Library

Structured query language or SQL is a popular programming language used to interact with relational database management systems (RDBMS). Due to the fact it was created for this specific purpose, the language has become very efficient, thus having a high adoption rate between beginners. 

For this project, my goal is to practice the use of SQL to create and modify databases and also use its capabilities to provide insights. For that, I will create a library database with the books I have read in 2025 and get some basic statistics to analyze my reading pattern. 

For that, I will be using the software DBeaver Community, which is a Free Open-Source Database Management Tool. This software is recommended for personal projects like this one and enables you to explore databases like My SQL, MariaDB, PostgreSQL, SQLite, and others.

[...]

In DBeaver, I started by creating the database library and creating the parent tables first:

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

