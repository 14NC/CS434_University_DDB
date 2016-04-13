DROP TRIGGER IF EXISTS CHECK_ENROLLMENT_LIMIT;
DROP TRIGGER IF EXISTS ROOM_RESTRICTION;

DELIMITER $$

CREATE TRIGGER CHECK_ENROLLMENT_LIMIT
BEFORE INSERT ON ENROLLMENTS
FOR EACH ROW
BEGIN
	/*Constraint limits students from enrolling in more than 6 classes per term*/
	DECLARE ClassCount INT;
	
	SET ClassCount = (SELECT COUNT(*) FROM ENROLLMENTS WHERE Sid = New.Sid AND Term = NEW.Term); 

	IF (ClassCount > 5) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Cannot add enrollment, student already fully registered!';
	END IF;

	/*Constraint does not allow more students to register for a class than there are seats*/
	IF (SELECT COUNT(*) FROM ENROLLMENTS WHERE Term = NEW.Term AND LineNo = NEW.LineNo) >= (SELECT Capacity FROM SECTIONS WHERE Term = NEW.Term AND LineNo = NEW.LineNo) THEN
                SIGNAL SQLSTATE '45002'
                SET MESSAGE_TEXT = 'Cannot add enrollment, class full!';
        END IF;
END;

CREATE TRIGGER ROOM_RESTRICTION
BEFORE INSERT ON SECTIONS
FOR EACH ROW
BEGIN
	/*Constraint does not allow two classes to be in the same room at the same time*/
	IF (SELECT COUNT(*) FROM SECTIONS WHERE Room = NEW.Room AND Days = NEW.Days AND Term = NEW.Term AND StartTime = NEW.StartTime) > 0 THEN
		SIGNAL SQLSTATE '45001'
		SET MESSAGE_TEXT = 'Cannot add section, room already in use!';
	END IF;

	/*Constraint does not allow a professor to teach a class outside their department*/
	IF(SELECT DeptId FROM INSTRUCTORS WHERE LastName = NEW.InstrLname AND FirstName = NEW.InstrFname) != (SELECT DeptId FROM COURSES WHERE Cno = NEW.Cno) THEN
		SIGNAL SQLSTATE '45003'
		SET MESSAGE_TEXT = 'Cannot add section, Professor not from the correct department!';
	END IF;

	/*Constraint limits an instructor from teaching more than 5 sections a term*/
	IF(SELECT COUNT(*) FROM SECTIONS WHERE Term = NEW.Term) > 4 THEN
		SIGNAL SQLSTATE '45004'
		SET MESSAGE_TEXT = 'Cannot add section, Professor teaching max amount of sections!';
	END IF;
END;
