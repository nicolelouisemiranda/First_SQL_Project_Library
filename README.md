# SQL Study: Bookshelf Database

## Introduction

Structured query language (SQL) is a widely used programming language designed to interact with relational database management systems (RDBMS). Due to the fact it was created specifically for this purpose, it is highly efficient and has a high adoption rate among beginners.

The objective of this project is to practice the use of SQL to create and modify databases and also use its capabilities to provide insights from data. For this purpose, a bookshelf database was created containing all the books I have read in 2025, and some statistics were retrieved to analyze my reading patterns.

This project was developed using the software DBeaver Community, which is a Free Open-Source Database Management Tool. This software is recommended for personal projects and supports database systems like My SQL, MariaDB, PostgreSQL, SQLite, and others.

[...]

## Database Creation

Using DBeaver, the first step was to create the library database and then define the parent tables:

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

