-- -------------------------------------------
-- initTourAndGuideTables.sql
-- -------------------------------------------
-- This stored procedure will initialize the 
-- Tour and Guide tables.

DELIMITER $$

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
	SET @endDate = DATE_ADD(@d, INTERVAL 1 YEAR);

	WHILE @d <= @endDate DO
		IF (DAYOFWEEK(@d) = 1 OR DAYOFWEEK(@d) = 7) THEN
			INSERT INTO Tour (TourDatetime, Capacity, Guide_idGuide) VALUES
				(concat(@d, ' ', '09:00:00'), 10, @DebussyId),
				(concat(@d, ' ', '13:00:00'), 10, @HilbertId),
				(concat(@d, ' ', '13:00:00'), 10, @GodelId),
				(concat(@d, ' ', '15:00:00'), 10, @DebussyId);
				
		END IF;
		set @d = DATE_ADD(@d, INTERVAL 1 DAY);

	END WHILE;

END
