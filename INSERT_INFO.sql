USE UNIVERSITY;

INSERT INTO DEPARTMENTS
  VALUES ('1', 'Engineering', 'College of Engineering'),
   ('2', 'Information Technology', 'College of Computing Sciences'),
   ('3', 'Information Systems', 'College of Computing Sciences'),
   ('4', 'Computer Science', 'College of Computing Sciences'),
   ('5', 'Humanities', 'College of Liberal Arts Sciences'),
   ('6', 'History', 'College of Liberal Arts Sciences'),
   ('7', 'Math', 'College of Liberal Arts Sciences'),
   ('8', 'Science', 'College of Liberal Arts Sciences');

INSERT INTO INSTRUCTORS
  VALUES ('Dinkerbell', 'Jane', '1', 'MCE RM. 201', '9083552342', 'jdinkerbell@university'),
   ('Newler', 'Mark', '2', 'GITC RM. 331', '9088395793', 'mnewler@university'),
   ('Roxanne', 'Ruiz', '3', 'GITC RM. 330', '9082347575', 'rroxanne@university'),
   ('Nathan', 'Kelly', '4', 'GITC RM. 332', '9089982374', 'knathan@university'),
   ('Dwight', 'Powers', '5', 'CUL RM. 402', '9083214534', 'pdwight@university'),
   ('Nellie', 'Rogers', '6', 'CUL RM. 403', '9083552342', 'rnellie@university'),
   ('Stewart', 'Christine', '7', 'CUL RM. 404', '9083323458', 'cstewart@university'),
   ('Ortega', 'Melanie', '7', 'CUL RM. 404', '9083323458', 'mortega@university'),
   ('Wolf', 'Roy', '8', 'CUL RM. 405', '9084772457', 'rwolf@university');

INSERT INTO COURSES
  VALUES ('1101', 'Fundamentals of Engineering', '1', '1'),
   ('1201', 'Introduction to Networking', '3', '2'),
   ('1121', 'Database Systems', '3', '3'),
   ('1211', 'Operating Systems', '3', '4'),
   ('1222', 'American Culture', '3', '5'),
   ('1110', 'Civil War', '3', '6'),
   ('1103', 'Differential Equations', '3', '7'),
   ('1303', 'Chemistry 1', '3', '8');

INSERT INTO STUDENTS
  VALUES ('0100', 'Otis', 'Clark', 'Freshman', '9081124987', 'Hemlock St.', 'Union', 'NJ', '08930', 'Mechanical Engineering', '1', '50', '3.5'),
   ('0101', 'Janet', 'Chandler', 'Freshman', '9088928473', 'Spruce St.', 'Roselle', 'NJ', '07123', 'Network Security', '2', '30', '3.0'),
   ('0102', 'Amanda', 'Meyer', 'Sophmore', '9088920401', 'Bender Ave.', 'Linden', 'NY', '92834', 'Business Management Information Systems', '3', '75', '3.7'),
   ('0103', 'Gretchen', 'Ruiz', 'Senior', '973774384', 'Sherman Ave', 'New Providence', 'NY', '93902', 'Software Engineering', '4', '115', '3.3'),
   ('0104', 'Darryl', 'Denis', 'Junior', '9738274501', 'Westfield Ave', 'Scotch Plains', 'NY', '94583', 'History', '6', '33', '3.0');

INSERT INTO SECTIONS
  VALUES ('Spring 16', '111', '1101', 'Dinkerbell', 'Jane', 'FMH RM. 102', 'M,F', '08:30:00', '10:00:00', '20'),
   ('Spring 16', '112', '1201', 'Newler', 'Mark', 'CUL RM. 502', 'T,Tr', '010:00:00', '11:30:00', '20'),
   ('Spring 16', '113', '1121', 'Roxanne', 'Ruiz', 'GITC RM. 140', 'W', '18:00:00', '21:00:00', '100'),
   ('Fall 15', '114', '1211', 'Nathan', 'Kelly', 'PC MALL RM. 23', 'M,W', '08:30:00', '10:00:00', '25'),
   ('Fall 15', '115', '1222', 'Dwight', 'Powers', 'FMH RM. 200', 'M,Tr', '13:00:00', '14:30:00', '20'),
   ('Fall 15', '116', '1110', 'Nellie', 'Rogers', 'PC MALL RM. 25', 'F', '18:00:00', '21:00:00', '25');

INSERT INTO ENROLLMENTS
  VALUES ('0100', 'Spring 16', '111', '3.0'),
   ('0101', 'Spring 16', '112', '3.0'),
   ('0102', 'Spring 16', '113', '4.0'),
   ('0103', 'Fall 15', '114', '3.5'),
   ('0104', 'Fall 15', '115', '2.5'),
   ('0100', 'Spring 16', '113', '3.0'),
   ('0101', 'Spring 16', '111', '3.0'),
   ('0102', 'Spring 16', '112', '4.0'),
   ('0103', 'Spring 16', '111', '3.5'),
   ('0104', 'Spring 16', '111', '3.0'),
   ('0100', 'Fall 15', '116', '3.0'),
   ('0103', 'Spring 16', '112', '3.0');
  
