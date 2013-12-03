DELIMITER $$

Use `ChsPaddler` $$

DROP PROCEDURE IF EXISTS `selectResByUser` $$

CREATE PROCEDURE `selectResByUser` (IN userEmail VARCHAR(45))
BEGIN
	SELECT r.idReservation, t.TourDatetime, r.GroupSize, concat(g.FirstName, ' ', g.LastName) guideName
	FROM `Reservation` r INNER JOIN `Tour` t INNER JOIN `Guide` g
	ON r.Tour_idTour = t.idTour AND t.Guide_idGuide = g.idGuide
	WHERE r.User_Email = userEmail;
END $$

DELIMITER ;