DROP TRIGGER IF EXISTS ENROLLMENT_INSERT_TRIGGERS_BEFORE;
DROP TRIGGER IF EXISTS ENROLLMENT_INSERT_TRIGGERS_AFTER;
DROP TRIGGER IF EXISTS SECTIONS_INSERT_TRIGGERS_BEFORE;
DROP TRIGGER IF EXISTS ENROLLMENT_UPDATE_TRIGGERS_BEFORE;
DROP TRIGGER IF EXISTS SECTIONS_UPDATE_TRIGGERS_AFTER;
DROP TRIGGER IF EXISTS ENROLLMENT_DELETE_TRIGGERS_AFTER;
DROP TRIGGER IF EXISTS COURSES_UPDATE_TRIGGERS_AFTER;
DROP TRIGGER IF EXISTS ENROLLMENTS_UPDATE_TRIGGERS_AFTER;

DELIMITER $$

CREATE TRIGGER ENROLLMENT_INSERT_TRIGGERS_BEFORE
BEFORE INSERT ON ENROLLMENTS
FOR EACH ROW
BEGIN
        /*CONSTRAINT: limits students from enrolling in more than 6 classes per term*/
        DECLARE ClassCount INT;

        IF (SELECT COUNT(*) FROM ENROLLMENTS WHERE Sid = New.Sid AND Term = NEW.Term) > 5 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot add enrollment, this student is already fully registered!';
        END IF;

        /*CONSTRAINT: does not allow more students to register for a class than there are seats*/
        IF (SELECT COUNT(*) FROM ENROLLMENTS WHERE Term = NEW.Term AND LineNo = NEW.LineNo) >= (SELECT Capacity FROM SECTIONS WHERE Term = NEW.Term AND LineNo = NEW.LineNo) THEN
                SIGNAL SQLSTATE '45002'
                SET MESSAGE_TEXT = 'Cannot add enrollment, this class is full!';
        END IF; 
END;

CREATE TRIGGER ENROLLMENT_INSERT_TRIGGERS_AFTER
AFTER INSERT ON ENROLLMENTS
FOR EACH ROW
BEGIN
		/*TRIGGER: on insert of a new enrollment, update hours value for the student by adding*/
		UPDATE STUDENTS SET hours = (hours + (SELECT Hours FROM SECTIONS s, COURSES c WHERE NEW.Term = s.Term AND NEW.LineNo = s.LineNo AND s.Cno = c.Cno)) WHERE Sid=NEW.Sid;
		
		/*TRIGGER: on insert of a new enrollment, update GPA for the student*/
		UPDATE STUDENTS SET GPA = (SELECT SUM(Grade*Hours)/(COUNT(Grade)*4) FROM ENROLLMENTS e, SECTIONS s, COURSES c WHERE e.Sid = NEW.Sid AND NEW.Term = s.Term AND NEW.LineNo = s.LineNo AND s.Cno = c.Cno) WHERE Sid=NEW.Sid;
END;

CREATE TRIGGER SECTIONS_INSERT_TRIGGERS_BEFORE
BEFORE INSERT ON SECTIONS
FOR EACH ROW
BEGIN
        /*CONSTRAINT: does not allow two classes to be in the same room at the same time*/
        IF (SELECT COUNT(*) FROM SECTIONS WHERE Room = NEW.Room AND Days = NEW.Days AND Term = NEW.Term AND StartTime = NEW.StartTime) > 0 THEN
                SIGNAL SQLSTATE '45001'
                SET MESSAGE_TEXT = 'Cannot add section, room already in use!';
        END IF;

        /*CONSTRAINT: does not allow a professor to teach a class outside their department*/
        IF(SELECT DeptId FROM INSTRUCTORS WHERE LastName = NEW.InstrLname AND FirstName = NEW.InstrFname) != (SELECT DeptId FROM COURSES WHERE Cno = NEW.Cno) THEN
                SIGNAL SQLSTATE '45003'
                SET MESSAGE_TEXT = 'Cannot add section, Professor not from the correct department!';
        END IF;

        /*CONSTRAINT: limits an instructor from teaching more than 5 sections a term*/
        IF(SELECT COUNT(*) FROM SECTIONS WHERE Term = NEW.Term) > 4 THEN
                SIGNAL SQLSTATE '45004'
                SET MESSAGE_TEXT = 'Cannot add section, Professor teaching max amount of sections!';
        END IF;
END;

CREATE TRIGGER ENROLLMENT_UPDATE_TRIGGERS_BEFORE
BEFORE UPDATE ON ENROLLMENTS
FOR EACH ROW
BEGIN
		/*CONSTRAINT: does not allow two classes to be in the same room at the same time*/
        IF (SELECT COUNT(*) FROM SECTIONS WHERE Room = NEW.Room AND Days = NEW.Days AND Term = NEW.Term AND StartTime = NEW.StartTime) > 0 THEN
                SIGNAL SQLSTATE '45001'
                SET MESSAGE_TEXT = 'Cannot add section, room already in use!';
        END IF;
END;

CREATE TRIGGER SECTIONS_UPDATE_TRIGGERS_AFTER
AFTER UPDATE ON SECTIONS
FOR EACH ROW
BEGIN
        /*CONSTRAINT: does not allow a professor to teach a class outside their department*/
        IF(SELECT DeptId FROM INSTRUCTORS WHERE LastName = NEW.InstrLname AND FirstName = NEW.InstrFname) != (SELECT DeptId FROM COURSES WHERE Cno = NEW.Cno) THEN
                SIGNAL SQLSTATE '45003'
                SET MESSAGE_TEXT = 'Cannot add section, Professor not from the correct department!';
        END IF;
END;

CREATE TRIGGER ENROLLMENT_DELETE_TRIGGERS_AFTER
AFTER DELETE ON ENROLLMENTS
FOR EACH ROW
BEGIN
		/*TRIGGER: after delete of an enrollment, update hours value for the student by subtracting */
		UPDATE STUDENTS SET hours = (hours - (SELECT Hours FROM SECTIONS s, COURSES c WHERE OLD.Term = s.Term AND OLD.LineNo = s.LineNo AND s.Cno = c.Cno)) WHERE Sid=OLD.Sid;
		
		/*TRIGGER: after delete of an enrollment, update GPA for the student*/
		UPDATE STUDENTS SET GPA = (SELECT SUM(Grade*Hours)/(COUNT(Grade)*4) FROM ENROLLMENTS e, SECTIONS s, COURSES c WHERE e.Sid = OLD.Sid AND OLD.Term = s.Term AND OLD.LineNo = s.LineNo AND s.Cno = c.Cno) WHERE Sid=OLD.Sid;
END;

CREATE TRIGGER COURSES_UPDATE_TRIGGERS_AFTER
AFTER UPDATE ON COURSES
FOR EACH ROW
BEGIN
		/*TRIGGER: on update of the hours of a course, update hours value for the student by subtracting old and adding new*/
		UPDATE STUDENTS SET hours = (hours - OLD.Hours + NEW.Hours) WHERE Sid IN (SELECT Sid FROM ENROLLMENTS e, SECTIONS s, COURSES c WHERE e.Term = s.Term and e.LineNo = s.LineNo AND s.Cno = c.Cno AND c.Cno = NEW.Cno);

		/*TRIGGER: on update of the hours of a course, update GPA for the student*/
		UPDATE STUDENTS SET GPA = (SELECT SUM(Grade*Hours)/(COUNT(Grade)*4) FROM ENROLLMENTS e, SECTIONS s, COURSES c WHERE e.Term = s.Term AND e.LineNo = s.LineNo AND s.Cno = c.Cno AND e.Sid = STUDENTS.Sid);
END;

CREATE TRIGGER ENROLLMENTS_UPDATE_TRIGGERS_AFTER
AFTER UPDATE ON ENROLLMENTS
FOR EACH ROW
BEGIN
		/*TRIGGER: after update of an enrollment (grade), update GPA for the student*/
		UPDATE STUDENTS SET GPA = (SELECT SUM(Grade*Hours)/(COUNT(Grade)*4) FROM ENROLLMENTS e, SECTIONS s, COURSES c WHERE e.Sid = NEW.Sid AND NEW.Term = s.Term AND NEW.LineNo = s.LineNo AND s.Cno = c.Cno) WHERE Sid=NEW.Sid;
END;

/*
Constraints:
1) 45000 - Students cannot enroll in more than 6 courses a semester. This constraint is placed on the enrollment table
and with respect to inserts. Will not consider updates, assuming if an incorrect insert is made it will be deleted
and a new insert will be made instead of the original one updated.

2) 45001 - Two classes cannot be registered to use the same room at the same time. This will affect both inserts of new classes
in the sections table as well as updates on the sections table indicating the changing of a room for a class.

3) 45002 - Students cannot enroll in a class if the capacity for the room the class is in is reached. This constraint is placed on the
enrollment table for the insertion of new students. Will not consider updates for the same reason stated for constrain 1 above.

4) 45003 - A professor is not able to teach a course that is registered to a department outside of the department the professor belongs
to. This will affect both inserts in the sections table as well as updates on the sections table indicating the changing of a class that 
a professor will be teaching.

5) 45004 - A professor is not able to teach more than 5 courses a semester. This will affect inserts on the sections table. 
*/

/*
Triggers:
Hours) The hours attribute in the students table will need to be updated whenever a new enrollment is inserted/deleted or when the Hours attribute
for a course a student is taking is updated.

GPA) Similar to hours, GPA will need to be updated whenever a new enrollment is inserted/deleted or when the Hours attribute for a course a student
is taking is updated. Additionally GPA also needs to be updated when a grade is changed through an update to the enrollments table. 
*/
