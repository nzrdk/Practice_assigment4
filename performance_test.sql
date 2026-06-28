INSERT INTO students (id, first_name, last_name, email, phone, course, educational_degree, speciality, active)
SELECT 
    gen_random_uuid()::varchar, 
    'Name_' || seq, 
    'Surname_' || seq, 
    'student_' || seq || '@example.com', 
    '380000000000', 
    (seq % 5) + 1, 
    'Bachelor', 
    'Computer Science', 
    true
FROM generate_series(1, 500000) AS seq;

DROP INDEX IF EXISTS idx_students_email;

EXPLAIN ANALYZE SELECT * FROM students WHERE email = 'student_450000@example.com';

CREATE INDEX idx_students_email ON students(email);

EXPLAIN ANALYZE SELECT * FROM students WHERE email = 'student_450000@example.com';
