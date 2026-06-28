DROP TABLE IF EXISTS schedule CASCADE;
DROP TABLE IF EXISTS students_course_group_students CASCADE;
DROP TABLE IF EXISTS students_course_groups CASCADE;
DROP TABLE IF EXISTS instructors_courses CASCADE;
DROP TABLE IF EXISTS lessons_schedule CASCADE;
DROP TABLE IF EXISTS instructors CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS students CASCADE;

CREATE TABLE IF NOT EXISTS students (
    id VARCHAR(36) PRIMARY KEY,
    first_name VARCHAR(200) NOT NULL,
    last_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    course INT,
    educational_degree VARCHAR(20),
    speciality VARCHAR(20),
    active BOOLEAN
);

CREATE TABLE IF NOT EXISTS rooms (
    id VARCHAR(36) PRIMARY KEY,
    building VARCHAR(200),
    floor INT,
    number INT,
    display_name VARCHAR(200),
    seats_number INT CHECK (seats_number > 0)
);

CREATE TABLE IF NOT EXISTS courses (
    id VARCHAR(36) PRIMARY KEY,
    course_display_short_name VARCHAR(36),
    course_display_full_name VARCHAR(200),
    course_description VARCHAR(500),
    lectures_num INT CHECK (lectures_num >= 0),
    practices_num INT CHECK (practices_num >= 0)
);

CREATE TABLE IF NOT EXISTS instructors (
    id VARCHAR(36) PRIMARY KEY,
    first_name VARCHAR(200),
    last_name VARCHAR(200),
    email VARCHAR(200) UNIQUE,
    phone VARCHAR(20),
    active BOOLEAN
);

CREATE TABLE IF NOT EXISTS lessons_schedule (
    id INT PRIMARY KEY,
    start_time TIME,
    end_time TIME,
    CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS instructors_courses (
    instructor_id VARCHAR(36) NOT NULL REFERENCES instructors(id) ON DELETE CASCADE,
    course_id VARCHAR(36) NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    PRIMARY KEY (instructor_id, course_id)
);

CREATE TABLE IF NOT EXISTS students_course_groups (
    id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) NOT NULL REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS students_course_group_students (
    student_id VARCHAR(36) NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    group_id VARCHAR(36) NOT NULL REFERENCES students_course_groups(id) ON DELETE CASCADE,
    PRIMARY KEY (student_id, group_id)
);

CREATE TABLE IF NOT EXISTS schedule (
    id INT PRIMARY KEY,
    course_id VARCHAR(36) REFERENCES courses(id),
    instructor_id VARCHAR(36) REFERENCES instructors(id),
    students_course_group_id VARCHAR(36) REFERENCES students_course_groups(id),
    week_day VARCHAR(20),
    lesson_schedule_id INT REFERENCES lessons_schedule(id),
    room_id VARCHAR(36) REFERENCES rooms(id),
    CONSTRAINT schedule_unique_key UNIQUE (course_id, instructor_id, students_course_group_id, room_id)
);

CREATE INDEX IF NOT EXISTS idx_schedule_course_id ON schedule(course_id);
CREATE INDEX IF NOT EXISTS idx_schedule_instructor_id ON schedule(instructor_id);
CREATE INDEX IF NOT EXISTS idx_schedule_room_id ON schedule(room_id);
CREATE INDEX IF NOT EXISTS idx_students_email ON students(email);

CREATE OR REPLACE PROCEDURE deactivate_student(p_student_id VARCHAR(36))
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE students
    SET active = FALSE
    WHERE id = p_student_id;
END;
$$;

CREATE OR REPLACE FUNCTION check_room_capacity()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT seats_number FROM rooms WHERE id = NEW.room_id) <= 0 THEN
        RAISE EXCEPTION 'Room has no available seats';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_room_capacity
BEFORE INSERT OR UPDATE ON schedule
FOR EACH ROW
EXECUTE FUNCTION check_room_capacity();
