-- ----------------------------
-- availTimeGroupSizeByDate.sql
-- ----------------------------
-- This stored procedure will return the times
-- and available group sizes for a given date

DELIMITER $$

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

DELIMITER ;


-- CALL availTimeGroupSize('2013120