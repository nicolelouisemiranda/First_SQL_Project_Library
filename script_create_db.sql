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
