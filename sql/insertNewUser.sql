	-- --------------------------------------------------------------------------------
	-- Routine DDL
	-- Note: comments before and after the routine body will not be stored by the server
	-- --------------------------------------------------------------------------------
	DELIMITER $$

	DROP PROCEDURE IF EXISTS insertNewUser$$

	CREATE PROCEDURE insertNewUser (
			IN email VARCHAR(20),
			IN pw VARCHAR(20),
			IN firstName VARCHAR(20),
			IN lastName VARCHAR(20),
			IN phone VARCHAR(20)
			-- OUT err BIT(1)
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
