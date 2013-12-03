SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `ChsPaddler` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `ChsPaddler` ;

-- -----------------------------------------------------
-- Table `ChsPaddler`.`User`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ChsPaddler`.`User` ;

CREATE TABLE IF NOT EXISTS `ChsPaddler`.`User` (
  `Email` VARCHAR(45) NOT NULL,
  `Password` VARCHAR(45) NOT NULL,
  `FirstName` VARCHAR(45) NOT NULL,
  `LastName` VARCHAR(45) NOT NULL,
  `Phone` VARCHAR(45) NULL,
  PRIMARY KEY (`Email`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ChsPaddler`.`Guide`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ChsPaddler`.`Guide` ;

CREATE TABLE IF NOT EXISTS `ChsPaddler`.`Guide` (
  `idGuide` INT NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(45) NULL,
  `LastName` VARCHAR(45) NULL,
  PRIMARY KEY (`idGuide`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ChsPaddler`.`Tour`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ChsPaddler`.`Tour` ;

CREATE TABLE IF NOT EXISTS `ChsPaddler`.`Tour` (
  `idTour` INT NOT NULL AUTO_INCREMENT,
  `TourDatetime` DATETIME NOT NULL,
  `Capacity` INT NOT NULL,
  `Guide_idGuide` INT NOT NULL,
  PRIMARY KEY (`idTour`, `Guide_idGuide`),
  INDEX `fk_Tour_Guide1_idx` (`Guide_idGuide` ASC),
  CONSTRAINT `fk_Tour_Guide1`
    FOREIGN KEY (`Guide_idGuide`)
    REFERENCES `ChsPaddler`.`Guide` (`idGuide`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ChsPaddler`.`Reservation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ChsPaddler`.`Reservation` ;

CREATE TABLE IF NOT EXISTS `ChsPaddler`.`Reservation` (
  `idReservation` INT NOT NULL AUTO_INCREMENT,
  `GroupSize` INT NOT NULL,
  `User_Email` VARCHAR(45) NOT NULL,
  `Tour_idTour` INT NOT NULL,
  PRIMARY KEY (`idReservation`, `User_Email`, `Tour_idTour`),
  INDEX `fk_Reservation_User1_idx` (`User_Email` ASC),
  INDEX `fk_Reservation_Tour1_idx` (`Tour_idTour` ASC),
  CONSTRAINT `fk_Reservation_User1`
    FOREIGN KEY (`User_Email`)
    REFERENCES `ChsPaddler`.`User` (`Email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Reservation_Tour1`
    FOREIGN KEY (`Tour_idTour`)
    REFERENCES `ChsPaddler`.`Tour` (`idTour`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

USE `ChsPaddler` ;

-- -----------------------------------------------------
-- Placeholder table for view `ChsPaddler`.`upcomingReservations`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ChsPaddler`.`upcomingReservations` (`User_Email` INT, `idReservation` INT, `TourDatetime` INT, `GroupSize` INT, `guideName` INT);

-- -----------------------------------------------------
-- View `ChsPaddler`.`upcomingReservations`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `ChsPaddler`.`upcomingReservations` ;
DROP TABLE IF EXISTS `ChsPaddler`.`upcomingReservations`;
USE `ChsPaddler`;
CREATE  OR REPLACE VIEW `upcomingReservations` AS
SELECT r.User_Email, r.idReservation, t.TourDatetime, r.GroupSize, concat(g.FirstName, ' ', g.LastName) guideName
	FROM `Reservation` r INNER JOIN `Tour` t INNER JOIN `Guide` g
	ON r.Tour_idTour = t.idTour AND t.Guide_idGuide = g.idGuide
	WHERE t.TourDatetime >= curdate();

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
