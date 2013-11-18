	-- --------------------------------------------------------------------------------
	-- Routine DDL
	-- Note: comments before and after the routine body will not be stored by the server
	-- --------------------------------------------------------------------------------
	DELIMITER $$

	DROP PROCEDURE IF EXISTS insertNewUser$$

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
	END
