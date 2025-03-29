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

Select e.emp_id,
e.emp_name,
b.branch_id,
b.manager_ID,
b.Branch_address,
b.contact_no,
e1.Emp_name as Manager
from employees e
join
Branch b
on e.branch_id=b.branch_id
join employees e1
on e1.branch_id=b.branch_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
Select * from Expensive_books

-- Task 12: Retrieve the List of Books Not Yet Returned

Select distinct(is1.issued_book_name) from 
issued_status is1
left join
return_status rs1
on 
is1.issued_id=rs1.issued_id
where rs1.return_id is NULL;

SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
-- method 1 CTE

With Temp as
(SELECT 
     is1.issued_book_name,
     m.member_ID,
     m.member_name,
     is1.issued_date,
     rs.return_id,
     rs.return_date,
     is1.issued_date + interval 30 day as Threshold
FROM issued_status as is1
LEFT JOIN
return_status as rs
ON is1.issued_id = rs.issued_id
left join members m
on is1.issued_member_id=m.member_id)

Select temp.member_ID,
     temp.member_name,
     temp.issued_book_name,
     temp.issued_date,
     Datediff(curdate(),temp.threshold) as Overdue
     from temp
     where  Datediff(curdate(),temp.threshold)>30
     and temp.return_date is NULL
     order by 1;
     
   -- method 2   
     
     SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1

/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

delimiter $$ -- setting new Delimiter
Create procedure add_book_status (in p_return_ID text,in p_issued_id text) -- setting up parameters

Begin  -- all your logic and code
Declare v_isbn text; -- declaring variable
declare v_book_name text;
 -- inserting into returns based on users input
Insert into return_status(return_id,issued_id,return_date)
values (p_return_id,p_issued_id,curdate());

Select issued_book_isbn,
issued_book_name
into
v_isbn,
v_book_name
from issued_status
where issued_id=p_issued_id;

update books
set status = 'YES'
where isbn= v_isbn;
              
SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS Message;

END $$
delimiter; -- resetting Delimiter

-- testing the add_return_status_procedure 
Select * from books
Where isbn='978-0-679-76489-8';

select * from issued_status
where issued_book_isbn='978-0-679-76489-8';

Select * from return_status
where return_ID='RS119';

Issued_ID IS134
ISBN '978-0-375-41398-8'


Issued_ID IS139
issued_book_isbn 978-0-375-41398-8

call add_book_status('RS119','IS139');

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.
*/

Create table Branch_Perfromance As
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

/*-- Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.*/

-- updating member table issued_date
UPDATE issued_status
SET issued_date = STR_TO_DATE(CONCAT(YEAR(issued_date), '-12-', DAY(issued_date)), '%Y-%m-%d')
WHERE MONTH(issued_date) = 4;
Select * from issued_status;

-- Creating active members table

create table Active_members as
(
Select member_ID,member_name from members
where member_id in (SELECT distinct(issued_member_ID)
FROM issued_status
WHERE issued_date > CURDATE() - INTERVAL 6 MONTH)
);
Select * from Active_members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.


Select e.emp_name,
Count(issued_id) as Issues,
e.branch_ID
from issued_status ist
join employees e
on ist.issued_emp_id=e.emp_id
group by 1,3
order by 2 limit 3;


/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available, 
it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.*/

DELIMITER $$

CREATE PROCEDURE Update_Book_Status(
    IN p_issued_ID TEXT,
    IN p_issued_member_id TEXT,
    IN p_issued_book_isbn TEXT,
    IN p_issued_emp_id TEXT
)
BEGIN
    DECLARE v_status TEXT;

    -- Fetch book status
    SELECT status INTO v_status FROM books WHERE isbn = p_issued_book_isbn;

    -- Check if book is available
    IF LOWER(v_status) = 'yes' THEN 
        -- Insert issued book details
        INSERT INTO issued_status(issued_ID, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_ID, p_issued_member_id, CURDATE(), p_issued_book_isbn, p_issued_emp_id);

        -- Update book status
        UPDATE books SET status = 'No' WHERE isbn = p_issued_book_isbn;

        -- Success message
        SELECT CONCAT('Book records added successfully for book ISBN: ', p_issued_book_isbn) AS Message;
    ELSE
        -- Book unavailable message
        SELECT CONCAT('Sorry, the requested book is unavailable. ISBN: ', p_issued_book_isbn) AS Message;
    END IF;
END $$

DELIMITER ;


delimiter ;

-- testing procedure Update_book_status

create procedure Update_Book_Status(
in p_issued_ID text,
in p_issued_member_id text,
in p_issued_book_isbn text,
in p_issued_emp_id text)

-- testing the procedure 
Select * from issued_status
where issued_book_isbn='978-0-553-29698-2'
select * from books
where isbn='978-0-553-29698-2';

CALL Update_Book_Status('IS137', 'C107', '978-0-553-29698-2', 'E103');



