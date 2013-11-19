DELIMITER $$

Use `ChsPaddler` $$

DROP PROCEDURE IF EXISTS `selectResByUser` $$

CREATE PROCEDURE `selectResByUser` (IN userEmail VARCHAR(45))
BEGIN
	SELECT * FROM `Reservation` WHERE `Reservation`.`User_Email` = userEmail;
END

DELIMITER ;