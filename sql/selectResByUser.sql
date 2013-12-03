DELIMITER $$

Use `ChsPaddler` $$

DROP PROCEDURE IF EXISTS `selectResByUser` $$

CREATE PROCEDURE `selectResByUser` (IN userEmail VARCHAR(45))
BEGIN
	SELECT * FROM upcomingReservations
	WHERE User_Email = userEmail;
END $$

DELIMITER ;