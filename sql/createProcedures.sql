-- ------------------------------------------
-- createProcedures.sql
-- ------------------------------------------
-- Executes all the create statements for all
-- stored procedures.


-- --------------------------------------------------------------------------------
-- checkPassword
-- --------------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS checkPassword$$

CREATE PROCEDURE checkPassword (IN email VARCHAR(45),
								IN pwd VARCHAR(45))
BEGIN
	IF EXISTS(SELECT * FROM User WHERE email = User.email)
	THEN
		IF EXISTS(SELECT * FROM User WHERE email = User.email AND Password(pwd) = User.password)
		THEN SELECT 'true' AS auth;
		ELSE SELECT 'false' AS auth;
		END IF;
	ELSE SIGNAL SQLSTATE '02000';
	END IF;
END $$



-- --------------------------------------------------------------------------------
-- availableTours
-- --------------------------------------------------------------------------------
-- This stored procedure will select the tours that are still available
-- as well as their current size.

DROP PROCEDURE IF EXISTS availableTours $$

CREATE PROCEDURE availableTours()

BEGIN

SELECT t.idTour idTour, t.TourDatetime tourDatetime, t.Capacity Capacity, coalesce(sum(r.GroupSize), 0) currentSize
FROM Tour t
LEFT JOIN Reservation r ON r.Tour_idTour = t.idTour
WHERE t.TourDatetime >= CURDATE()
GROUP BY t.idTour
HAVING currentSize < Capacity
ORDER BY t.TourDatetime;

END	$$

-- --------------------------------------------------------------------------------
-- insertNewUser
-- --------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS insertNewUser $$

CREATE PROCEDURE insertNewUser (
		IN email VARCHAR(45),
		IN pw VARCHAR(45),
		IN firstName VARCHAR(45),
		IN lastName VARCHAR(45),
		IN phone VARCHAR(45)
	)

BEGIN
		INSERT INTO User VALUES (
				email,
				Password(pw), -- Inserting the hashed password
				firstName,
				lastName,
				phone
			);
END $$


-- --------------------------------------------------------------------------------
-- availableTourInfoByDate
-- --------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS availTourInfoByDate $$

CREATE PROCEDURE availTourInfoByDate (IN d DATE)

BEGIN
	
	SELECT a.idTour, concat(g.FirstName, ' ', g.LastName) guideName, a.tourDatetime, a.spaceLeft
	FROM
		(SELECT t.idTour idTour, t.TourDatetime tourDatetime, t.Guide_idGuide, (t.Capacity - coalesce(sum(r.GroupSize), 0)) spaceLeft
		FROM Tour t
		LEFT JOIN Reservation r ON r.Tour_idTour = t.idTour
		WHERE Date(t.TourDatetime) = d
		GROUP BY t.idTour
		HAVING spaceLeft > 0) a
	INNER JOIN Guide g
	ON a.Guide_idGuide = g.idGuide;

END $$


-- --------------------------------------------------------------------------------
-- selectResByUser
-- --------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS `selectResByUser` $$

CREATE PROCEDURE `selectResByUser` (IN userEmail VARCHAR(45))
BEGIN
	SELECT * FROM upcomingReservations -- a view
	WHERE User_Email = userEmail;
END $$


-- --------------------------------------------------------------------------------
-- initTourAndGuideTables
-- --------------------------------------------------------------------------------
-- Used for clearing the Tour and Guide tables and adding some tour guides and tours


DROP PROCEDURE IF EXISTS initTourAndGuideTables $$

CREATE PROCEDURE initTourAndGuideTables()

BEGIN
	-- Clear the tables
	DELETE FROM Tour WHERE 1;
	DELETE FROM Guide WHERE 1;

	INSERT INTO Guide (FirstName, LastName) VALUES
		('Claude', 'Debussy'),
		('David', 'Hilbert'),
		('Kurt', 'Godel');

	SELECT idGuide INTO @DebussyId FROM Guide WHERE LastName = 'Debussy';
	SELECT idGuide INTO @HilbertId FROM Guide WHERE LastName = 'Hilbert';
	SELECT idGuide INTO @GodelId FROM Guide WHERE LastName = 'Godel';
	

	SET @d = CURRENT_DATE();
	SET @endDate = DATE_ADD(@d, INTERVAL 3 MONTH);

	WHILE @d <= @endDate DO
		IF (DAYOFWEEK(@d) <> 1 AND DAYOFWEEK(@d) <> 7) THEN
			INSERT INTO Tour (TourDatetime, Capacity, Guide_idGuide) VALUES
				(concat(@d, ' ', '09:00:00'), 10, @DebussyId),
				(concat(@d, ' ', '13:00:00'), 10, @HilbertId),
				(concat(@d, ' ', '13:00:00'), 10, @GodelId),
				(concat(@d, ' ', '15:00:00'), 10, @DebussyId);
				
		END IF;
		set @d = DATE_ADD(@d, INTERVAL 1 DAY);

	END WHILE;

END $$

