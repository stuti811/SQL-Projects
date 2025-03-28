-- Task 1. Create a New Book Record
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
Update  members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
Select * from members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
Delete from issued_status
where issued_id='IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
Select issued_book_name from issued_status
where
issued_emp_id='E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
Select issued_emp_id, Count(*) as Books from issued_status 
Group by issued_emp_id
Having Count(issued_book_name)> '1';

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

Create Table NEWTABLE as
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
Select * from NewTable;

-- Task 7. Retrieve All Books in a Specific Category:
Select * from Books
where
Category='Classic';

-- Task 8: Find Total Rental Income by Category:

With Temp as(
Select b.Category,b.rental_price,ist.issued_id,ist.issued_book_name
from Books b
join
Issued_status IST
ON b.isbn = ist.issued_book_isbn
)

Select Category,SUM(rental_price) as Revenue
from temp
group by Category;

-- Task 9 List Members Who Registered in the Last 180 Days:
select * from members where datediff(curdate(),reg_date)>180;

-- Task 10 List Employees with Their Branch Manager's Name and their branch details

