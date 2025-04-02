use libary;
show tables;
select*from authors;
select *from book_authors;
select*from books;
select* from fines;
select*from members;
select*from transactions;
create database libary;
create database lib;
use lib;
/*1. Members Table
This table stores information about library members.*/
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    membership_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    membership_status ENUM('Active', 'Inactive') DEFAULT 'Active'
);
INSERT INTO members (first_name, last_name, email, phone)
VALUES ('John', 'Doe', 'john.doe@example.com', '1234567890'),
('anu','valli','valli@gmail.com','5472957819'),
('kathir','kasi','kathir@gmail.com','8463769012'),
('dhana','karthir','dhana@gmail.com','4895620173'),
('maya','pandi','maya@gmail.com','9470462759'),
('samaina','sami','samaina@gmail.com','6892345097'),
('pragiya','sarath','pragiya@gmail.com','4859038982'),
('sara','sakthi','sara@gmail.com','2748957632'),
('yuva','sabari','yuva@gmail.com','8764038457'),
('manisha','kanna','manisha@gmail.com','9367823653');
select * from members;

/*2. Books Table
This table stores information about books in the library*/
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    author VARCHAR(255),
    publisher VARCHAR(255),
    genre VARCHAR(100),
    quantity INT DEFAULT 0,
    available_quantity INT DEFAULT 0
);
INSERT INTO books (title, author, publisher, genre, quantity, available_quantity)
VALUES ('The Great Gatsby', 'F. Scott Fitzgerald', 'Charles Scribner\'s Sons', 'Fiction', 5, 5),
('To Kill a Mockingbird','Harper Lee','J.B. Lippincott & Co','Fiction',20,14),
('1984','George Orwell','Secker & Warburg','Dystopian',18,12),
('The Catcher in the Rye','J.D. Salinger Little','Brown and Company','Fiction',12,7),
('Pride and Prejudice','Jane Austen','T. Egerton','Romance',25,20),
('The Hobbit','J.R.R. Tolkien','George Allen & Unwin','Fantasy',30,25),
('Moby-Dick','Herman Melville','Harper & Brothers','Adventure',10,5),
('The Alchemist','Paulo Coelho','HarperOne','Fiction',22,18),
('War and Peace','Leo Tolstoy','The Russian Messenger','Historical Fiction',16,9),
('The Da Vinci Code','Dan Brown','Doubleday','Thriller',28,22);
select * from books;

/*3. Transactions Table
This table records borrowing and returning of books.*/
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    transaction_type ENUM('Borrow', 'Return'),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME,
    return_date DATETIME,
    fine DECIMAL(5, 2) DEFAULT 0.00,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);
/*3. Borrow a Book
When a member borrows a book, the system updates the transaction and reduces the available quantity.*/
INSERT INTO transactions (member_id, book_id, transaction_type, due_date)
VALUES (1,1,'Borrow','2025-03-10'),
(2,2,'Borrow','2025-03-02'),
(3,3,'Return','2025-03-04'),
(4,4,'Borrow','2025-03-03'),
(5,5,'Return','2025-03-10'),
(6,6,'Borrow','2025-03-09'),
(7,7,'Borrow','2025-03-07'),
(8,8,'Return','2025-03-11'),
(9,9,'Borrow','2025-03-12'),
(10,10,'Borrow','2025-03-05');
select * from transactions;
UPDATE books SET available_quantity = available_quantity - 1 WHERE book_id = 1;
/*4. Return a Book*/
UPDATE transactions SET return_date = NOW() WHERE transaction_id = 1;
UPDATE books SET available_quantity = available_quantity + 1 WHERE book_id = 1;
-- If the book is returned late, calculate the fine
UPDATE transactions
SET fine = DATEDIFF(CURDATE(), due_date) * 1.00  -- Assuming 1.00 is the fine per day
WHERE transaction_id = 1 AND DATEDIFF(CURDATE(), due_date) > 0;
select * from transactions where transaction_id=1;

CREATE TABLE fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT,
    fine_amount DECIMAL(5, 2),
    paid_status ENUM('Paid', 'Unpaid') DEFAULT 'Unpaid',
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

INSERT INTO fines (transaction_id, fine_amount)
VALUES (1, 5.00),
(2,6.00),
(3,4.00),
(4,6.00),
(5,3.00),
(6,2.00),
(7,7.00),
(8,4.00),
(9,5.00),
(10,2.00);  -- Fine for late return
select * from fines;

CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(255)
);
insert into authors(author_name) values
('Bharati'),
('Kalki'),
('Jayakanthan'),
('Sujatha'),
('Balakumaran'),
('Vairamuthu'),
('Indira'),
('Ramakrishnan'),
('Murugan'),
('Jeyamohan');

CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);
insert into book_authors(book_id,author_id) values
(1,1),
(2,2),
(3,3),
(4,4),
(5,5),
(6,6),
(7,7),
(8,8),
(9,9),
(10,10);
show tables;

SELECT m.first_name, m.last_name, b.title, t.transaction_date, t.due_date, t.return_date
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.transaction_type = 'Borrow' AND t.return_date IS NULL;

#View All Overdue Books
SELECT m.first_name, m.last_name, b.title, t.due_date, DATEDIFF(CURDATE(), t.due_date) AS overdue_days
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.transaction_type = 'Borrow' AND t.return_date IS NULL AND DATEDIFF(CURDATE(), t.due_date) > 0;

#View Member’s Borrowing History
SELECT m.first_name, m.last_name, b.title, t.transaction_id,t.transaction_type,transaction_date, t.due_date, t.return_date
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.transaction_type='Borrow';

#View All Books in the Library
SELECT book_id, title, author, genre, quantity, available_quantity
FROM books;

#View All Members in the Library
SELECT member_id, first_name, last_name, email, membership_status
FROM members;

#1.Overdue Fine Management
SELECT m.member_id, m.first_name,m.phone, t.book_id,b.title, t.due_date,DATEDIFF(CURDATE(), t.due_date) AS overdue_days,t.fine
FROM members m
JOIN transactions t ON m.member_id = t.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.transaction_type = 'Borrow';
  
/*2 Book Reservation:
Allow members to reserve books that are currently unavailable.*/
SELECT m.member_id,m.first_name,t.book_id,b.title,b.available_quantity
FROM members m 
JOIN transactions t ON m.member_id = t.member_id
JOIN books b ON t.book_id = b.book_id 
WHERE b.available_quantity = 5;

#3 Allow members to reserve books that are currently unavailable.
SELECT m.member_id, m.first_name,m.phone,m.email, t.book_id,b.title, t.due_date,DATEDIFF(CURDATE(), t.due_date) AS overdue_days,t.fine
FROM members m
JOIN transactions t ON m.member_id = t.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.transaction_type = 'Borrow';


select m.first_name,t.due_date,DATEDIFF(CURDATE(),t.due_date) as overdue_days,t.fine
from members m
join transactions t on m.member_id=t.member_id
where t.transaction_type ='Borrow';
  







