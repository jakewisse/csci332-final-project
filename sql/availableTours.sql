-- ----------------------------
-- availableTours.sql
-- ----------------------------
-- This stored procedure will select the tours that are still available
-- as well as their current size.

DELIMITER $$

DROP PROCEDURE IF EXISTS availableTours $$

CREATE PROCEDURE availableTours()

BEGIN

SELECT t.idTour idTour, t.TourDatetime tourDatetime, t.Capacity Capacity, coalesce(sum(r.GroupSize), 0) currentSize
FROM Tour t
LEFT JOIN Reservation r ON r.Tour_idTour = t.idTour
WHERE t.TourDatetime >= CURDATE() AND currentSize < Capacity
GROUP BY t.idTour
HAVING currentSize < Capacity
ORDER BY t.TourDatetime;

END	$$

DELIMITER ;