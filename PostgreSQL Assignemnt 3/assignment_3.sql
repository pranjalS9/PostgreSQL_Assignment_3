 
 ---------------ASSIGNMENT 3--------------------------------
-- QUERY 1
CREATE OR REPLACE PROCEDURE participate_tournament(member_name varchar, tournament_name varchar, tour_year int)
LANGUAGE plpgsql
AS $$
DECLARE
    member_id INT;
    tour_id INT;
BEGIN
    SELECT memberid INTO member_id FROM members where firstname=member_name;
    SELECT id INTO tour_id FROM tournament where tour_name = tournament_name;
    
    INSERT INTO tournament_entry (memberid, tourid, year) VALUES (member_id, tour_id, tour_year);
END;
$$;
drop procedure participate_tournament(member_name varchar, tournament_name varchar, tour_year INT)
CALL participate_tournament('Joe', 'Tour 2', 2023)
select * from members
select * from tournament
select * from tournament_entry

-- QUERY 2

CREATE OR REPLACE FUNCTION tournaments(IN tour_year int, OUT number_of_tournaments int) 
LANGUAGE plpgsql  
AS  
$$  
DECLARE   
BEGIN  
    SELECT
	    COUNT(*) 
    INTO number_of_tournaments
    FROM tournament_entry t
	where tour_year = t.year
	GROUP BY t.year;
End;  
$$; 
SELECT * from tournaments(2023);
select * from tournament_entry

-- QUERY 3

CREATE OR REPLACE FUNCTION yearly_tournament(IN tourn_year int) 
RETURNS table (tournament_name varchar,
			   tour_type varchar,
			   country varchar,
			   is_open boolean
			   )  
LANGUAGE plpgsql  
AS  
$$  
BEGIN 
    RETURN QUERY
    SELECT
	    t1.tour_name as tour_name,
		t1.tour_type as tour_type,
		t1.country as country,
		t1.is_open as is_open
	FROM tournament t1
	JOIN tournament_entry t2 on t1.id = t2.tourid
	WHERE t2.year = tourn_year;
End;  
$$;  
SELECT * from yearly_tournament(2023);
SELECT * from tournament;

-- QUERY 4

create or replace procedure manager_details(IN first_name varchar(100), IN team_name varchar(100))
language plpgsql
as $$
begin
    update members
	set 
	    firstname = first_name
	where teamid = (select teamid
					from team
					where teamname = team_name and memberid = manager);
end; $$
drop procedure manager_details(first_name varchar(100), team_name varchar(100))
CALL manager_details('Rojes', 'Team A');
CALL manager_details('Mahira', 'Team B');
CALL manager_details('Jockey', 'Team C');
select * from members;

-- QUERY 5
CREATE OR REPLACE FUNCTION team_details(IN team_name varchar) 
RETURNS table (firstname varchar,
			   lastname varchar,
			   membershiptype varchar,
			   joindate date,
			   gender varchar
			   )  
LANGUAGE plpgsql  
AS  
$$  
BEGIN 
    RETURN QUERY
    SELECT
	    m1.firstname,
		m1.lastname,
		m2.type,
		m1.joindate,
		m1.gender
	FROM members m1
	JOIN membertype m2 on m1.membertypeid = m2.id
	JOIN team m3 on m1.teamid = m3.teamid
	where m3.teamname = team_name;
End;  
$$;  
SELECT * from team_details('Team A');
select * from members
SELECT * from tournament;

-- QUERY 6
select * from members;

create or replace procedure coach_details1(IN coachsaab varchar(100), IN member_name varchar(100))
language plpgsql
as $$
begin
    if not exists(select * from members where firstname=member_name)
	then
	raise 'Change the member name member doesnt exist';
    else
        update members
	    set 
	        firstname = coachsaab
		    where memberid=(select coachid from members where firstname = member_name );
    end if;
end; $$
call coach_details1('Aryan','James')
select * from members;

 -- QUERY 7
CREATE OR REPLACE FUNCTION number_of_participants(IN tour_year int,OUT num_participants int)
LANGUAGE plpgsql
AS
$$ 
BEGIN
  SELECT
      COUNT(*) INTO num_participants 
  FROM tournament_entry
  WHERE tournament_entry.year=tour_year;
END;
$$;
select * from tournament_entry
select * from number_of_participants(2022);
select * from tournament

-- BONUS PROBLEMS
-- QUERY 1
CREATE OR REPLACE FUNCTION swap_num( INOUT x int, INOUT y int)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT x, y INTO y, x;
END;
$$;
SELECT * FROM swap_num(2, 3)

--QUERY 2
CREATE OR REPLACE FUNCTION currentdate()
RETURNS TABLE(curr_day INT, curr_month text, curr_year INT)
LANGUAGE plpgsql
AS
$$ 
BEGIN
RETURN QUERY
  SELECT
      EXTRACT(day from current_date)::INT as curr_day,
	  to_char(current_date, 'MM') as curr_month,
	  EXTRACT(year from current_date)::INT as curr_year;
END;
$$;
select * from currentdate();

