SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


--  Project Task

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;


-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
SELECT * FROM issued_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121'

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT
	issued_member_id,
	count(issued_id) AS total_book_issued
FROM issued_status 
GROUP BY 1
HAVING COUNT(issued_id) > 1

-- CATS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_counts
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(issued_id) AS no_issued
FROM books AS b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM book_counts

-- Task 7. Retrieve All Books in a Specific Category:
SELECT 
	category,
	book_title,
	COUNT(isbn) AS total_books
FROM books
GROUP BY 1, 2
ORDER BY 3 DESC

-- Task 8: Find Total Rental Income by Category:

SELECT 
	category,
	SUM(rental_price) 
FROM books
GROUP BY 1
ORDER BY 2 DESC

-- List Members Who Registered in the Last 180 Days:
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C120', 'Zezo Alaa', '245baid st', '2025-05-05'),
('C121', 'Ali Hammza', '659rdry st', '2025-06-03');

SELECT * 
FROM members 
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'

--List Employees with Their Branch Manager's Name and their branch details:
SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name AS manager
FROM employees AS e1
JOIN
branch AS b
ON b.branch_id = e1.branch_id
JOIN 
employees AS e2
ON b.manager_id = e2.emp_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

CREATE TABLE expensive_books
AS
SELECT * FROM books
WHERE rental_price > 7

SELECT * FROM expensive_books

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
	DISTINCT ist.issued_book_isbn
FROM issued_status AS ist 
LEFT JOIN
return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE rs.issued_id IS NULL

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books 
(assume a 30-day return period). Display the
member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30;

SELECT 
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	rt.return_date,
	CURRENT_Date - ist.issued_date AS over_dues_days
FROM issued_status AS ist
JOIN
members AS m
	ON m.member_id = ist.issued_member_id
JOIN 
books AS b
	ON b.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status AS rt
	ON rt.issued_id = ist.issued_id
WHERE 
	rt.return_date IS NULL	
AND 
	CURRENT_Date - ist.issued_date > 30
ORDER BY 1

