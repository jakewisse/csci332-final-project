-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
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
END