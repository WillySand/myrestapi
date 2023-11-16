-- MySQL Script generated by MySQL Workbench
-- Mon Nov 13 17:12:13 2023
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mydb` ;

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Cart`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Cart` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Cart` (
  `idCart` INT NOT NULL,
  `idUser` INT NULL,
  PRIMARY KEY (`idCart`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`CartItem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`CartItem` ;

CREATE TABLE IF NOT EXISTS `mydb`.`CartItem` (
  `idCartItem` INT NOT NULL AUTO_INCREMENT,
  `idCart` INT NOT NULL,
  `idMenu` INT NOT NULL,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`idCartItem`),
  INDEX `fk_CartItem_Cart_idx` (`idCart` ASC) VISIBLE,
  INDEX `fk_CartItem_Menu1_idx` (`idMenu` ASC) VISIBLE,
  CONSTRAINT `fk_CartItem_Cart`
    FOREIGN KEY (`idCart`)
    REFERENCES `mydb`.`Cart` (`idCart`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_CartItem_Menu1`
    FOREIGN KEY (`idMenu`)
    REFERENCES `mydb`.`Menu` (`idMenu`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Menu`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Menu` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Menu` (
  `idMenu` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(90) NOT NULL,
  `price` INT NOT NULL,
  `image` BLOB NULL,
  `description` VARCHAR(250) NULL,
  `availability` INT NULL,
  `idResto` INT NOT NULL,
  PRIMARY KEY (`idMenu`),
  INDEX `fk_Menu_Resto1_idx` (`idResto` ASC) VISIBLE,
  CONSTRAINT `fk_Menu_Resto1`
    FOREIGN KEY (`idResto`)
    REFERENCES `mydb`.`Resto` (`idResto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Resto`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Resto` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Resto` (
  `idResto` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(90) NOT NULL,
  `long` FLOAT NOT NULL,
  `lat` FLOAT NOT NULL,
  PRIMARY KEY (`idResto`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


DELIMITER //
CREATE PROCEDURE AddToCart(
    IN p_idMenu INT,
    IN p_quantity INT,
    IN p_idCart INT
)
BEGIN
    DECLARE v_availability INT;

    -- Item is in cart?
    IF ( 
        SELECT COUNT(*)
        FROM mydb.CartItem CI
        WHERE CI.idCart = p_idCart
        AND CI.idMenu = p_idMenu
    ) > 0 THEN
        -- Menu item is already in the cart

        -- Get the availability
        SET v_availability = (
            SELECT M.availability
            FROM mydb.Menu M
            WHERE M.idMenu = p_idMenu
        );

        -- Update the quantity based on availability
        IF p_quantity + (
            SELECT quantity
            FROM mydb.CartItem
            WHERE idCart = p_idCart
            AND idMenu = p_idMenu
        ) <= v_availability THEN
            -- If there is enough availability, add item
            UPDATE mydb.CartItem
            SET quantity = quantity + p_quantity
            WHERE idCart = p_idCart
            AND idMenu = p_idMenu;
            -- If there is not enough availability, don't do anything
        END IF;

    ELSE
        -- If item is not in cart, insert new entry
                -- Get the availability
        SET v_availability = (
            SELECT M.availability
            FROM mydb.Menu M
            WHERE M.idMenu = p_idMenu
        );

        -- Update the quantity based on availability
        IF p_quantity <= v_availability THEN
            -- If there is enough availability, add item
            INSERT INTO mydb.CartItem (idCart, idMenu, quantity)
        VALUES (
            p_idCart,
            p_idMenu,
            p_quantity 
			);
		ELSE
			-- If there is not enough availability, Throw error
			SELECT 'Error: Quantity exceeds availability' AS errorMessage;            
        END IF;
    END IF;
END //

DELIMITER ;
DELIMITER //
CREATE PROCEDURE EditCartMenu(
    IN p_idMenu INT,
    IN p_idCartItem INT
)
BEGIN
    DECLARE v_availability INT;
	DECLARE v_quantity INT;
    -- CartItem exist?
    IF ( 
        SELECT COUNT(*)
        FROM mydb.CartItem CI
        WHERE CI.idCartItem = p_idCartItem
    ) > 0 THEN
        -- Menu item is already in the cart
        -- Get the availability
        SET v_availability = (
            SELECT M.availability
            FROM mydb.Menu M
            WHERE M.idMenu = p_idMenu
        );
		SET v_quantity = (
            SELECT CI.quantity
            FROM mydb.CartItem CI
            WHERE CI.idCartItem = p_idCartItem
        );
        -- Update the quantity based on availability
        IF v_quantity <= v_availability THEN
            -- If there is enough availability, change the menu item
            UPDATE mydb.CartItem
            SET idMenu = p_idMenu
            WHERE idCartItem = p_idCartItem;
		ELSE
			-- If there is not enough availability, Throw error
			SELECT 'Error: Quantity exceeds availability' AS errorMessage;
        END IF;
    END IF;
END //

DELIMITER ;
DELIMITER //
CREATE PROCEDURE EditCartQuantity(
    IN p_quantity INT,
    IN p_idCartItem INT
)
BEGIN
    DECLARE v_availability INT;

    -- Item is in cart?
    IF ( 
        SELECT COUNT(*)
        FROM mydb.CartItem CI
        WHERE CI.idCartItem = p_idCartItem
    ) > 0 THEN
        -- Menu item is already in the cart

        -- Get the availability
        SET v_availability = (
            SELECT M.availability
            FROM mydb.Menu M
            JOIN mydb.CartItem CI ON M.idMenu = CI.idMenu
            WHERE CI.idCartItem = p_idCartItem
        );

        -- Update the quantity based on availability
        IF p_quantity <= v_availability THEN
            -- If there is enough availability, add item
            UPDATE mydb.CartItem
            SET quantity = p_quantity
            WHERE idCartItem = p_idCartItem;
		ELSE
			-- If there is not enough availability, throw error
			SELECT 'Error: Quantity exceeds availability' AS errorMessage;
        END IF;
    END IF;
END //

DELIMITER ;
DELIMITER //
CREATE PROCEDURE EditCart(
    IN p_idMenu INT,
    IN p_quantity INT,
    IN p_idCartItem INT
)
BEGIN
    DECLARE v_availability INT;

    -- Item is in cart?
    IF ( 
        SELECT COUNT(*)
        FROM mydb.CartItem CI
        WHERE CI.idCartItem = p_idCartItem
    ) > 0 THEN
        -- Menu item is already in the cart

        -- Get the availability
        SET v_availability = (
            SELECT M.availability
            FROM mydb.Menu M
            WHERE M.idMenu = p_idMenu
        );

        -- Update the quantity based on availability
        IF p_quantity <= v_availability THEN
            -- If there is enough availability, add item
            UPDATE mydb.CartItem
            SET quantity = p_quantity, idmenu = p_idMenu
            WHERE idCartItem = p_idCartItem;
		ELSE
			-- If there is not enough availability, Throw error
			SELECT 'Error: Quantity exceeds availability' AS errorMessage;
        END IF;
    END IF;
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE CheckoutCart(IN p_idCart INT)
BEGIN
    DECLARE v_totalPrice INT;

    -- Check if the cart exists
    IF EXISTS (SELECT 1 FROM mydb.Cart WHERE idCart = p_idCart) THEN
        -- Calculate total prices
        SELECT SUM(M.price * CI.quantity) INTO v_totalPrice
        FROM mydb.CartItem CI
        JOIN mydb.Menu M ON CI.idMenu = M.idMenu
        WHERE CI.idCart = p_idCart AND M.availability > CI.quantity;

        -- Check if quantity is less than availability
        IF v_totalPrice IS NOT NULL THEN
            -- Return cart content with total price
            SELECT CI.idCartItem, CI.idMenu, M.name, CI.quantity, M.price, v_totalPrice AS totalPrice
            FROM mydb.CartItem CI
            JOIN mydb.Menu M ON CI.idMenu = M.idMenu
            WHERE CI.idCart = p_idCart;
        ELSE
            SELECT 'Error: Quantity exceeds availability' AS errorMessage;
        END IF;
    ELSE
        SELECT 'Error: Cart does not exist' AS errorMessage;
    END IF;
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE CheckoutCartWithRemoval(IN p_idCart INT)
BEGIN
    DECLARE v_totalPrice INT;
    DECLARE v_errorMessage VARCHAR(255);

    -- Check if the cart exists
    IF EXISTS (SELECT 1 FROM mydb.Cart WHERE idCart = p_idCart) THEN
        -- Calculate total prices
        SELECT SUM(M.price * CI.quantity) INTO v_totalPrice
        FROM mydb.CartItem CI
        JOIN mydb.Menu M ON CI.idMenu = M.idMenu
        WHERE CI.idCart = p_idCart;

        -- Check if quantity is less than availability
        IF v_totalPrice IS NOT NULL THEN
            -- Check if quantities exceed availability
            IF NOT EXISTS (
                SELECT 1
                FROM mydb.CartItem CI
                JOIN mydb.Menu M ON CI.idMenu = M.idMenu
                WHERE CI.idCart = p_idCart AND M.availability > CI.quantity;
            ) THEN
                -- Update availability and drop idCartItem
                UPDATE mydb.Menu M
                JOIN mydb.CartItem CI ON M.idMenu = CI.idMenu
                SET M.availability = M.availability - CI.quantity
                WHERE CI.idCart = p_idCart;

                -- Return cart content with total price
                SELECT CI.idCartItem, CI.idMenu, M.name, CI.quantity, M.price, v_totalPrice AS totalPrice
                FROM mydb.CartItem CI
                JOIN mydb.Menu M ON CI.idMenu = M.idMenu
                WHERE CI.idCart = p_idCart;

                -- Drop idCartItem
                DELETE FROM mydb.CartItem WHERE idCart = p_idCart;
            ELSE
                SET v_errorMessage = 'Error: Quantity exceeds availability';
            END IF;
        ELSE
            SET v_errorMessage = 'Error: No items in the cart';
        END IF;
    ELSE
        SET v_errorMessage = 'Error: Cart does not exist';
    END IF;

    -- If there's an error message, return it
    IF v_errorMessage IS NOT NULL THEN
        SELECT v_errorMessage AS errorMessage;
    END IF;
END //

DELIMITER ;