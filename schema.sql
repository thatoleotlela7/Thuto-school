-- Thuto School Register — database schema (PostgreSQL)

CREATE TYPE user_role AS ENUM ('admin', 'teacher', 'parent', 'student');
CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'late', 'excused');

-- Every login belongs here, regardless of role
CREATE TABLE users (
  id            SERIAL PRIMARY KEY,
  email         VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name     VARCHAR(255) NOT NULL,
  role          user_role NOT NULL,
  phone         VARCHAR(30),
  created_at    TIMESTAMP DEFAULT now()
);

CREATE TABLE classes (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(50) NOT NULL,
  grade_level VARCHAR(20) NOT NULL,
  teacher_id  INTEGER REFERENCES users(id)
);

CREATE TABLE students (
  id            SERIAL PRIMARY KEY,
  user_id       INTEGER REFERENCES users(id),
  full_name     VARCHAR(255) NOT NULL,
  class_id      INTEGER REFERENCES classes(id),
  date_of_birth DATE,
  enrolled_at   DATE DEFAULT CURRENT_DATE
);

CREATE TABLE parent_student (
  parent_user_id INTEGER REFERENCES users(id),
  student_id     INTEGER REFERENCES students(id),
  PRIMARY KEY (parent_user_id, student_id)
);

CREATE TABLE subjects (
  id   SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE attendance (
  id                SERIAL PRIMARY KEY,
  student_id        INTEGER REFERENCES students(id),
  date              DATE NOT NULL,
  status            attendance_status NOT NULL,
  self_checked_in   BOOLEAN NOT NULL DEFAULT false,
  recorded_by       INTEGER REFERENCES users(id),
  UNIQUE (student_id, date)
);

CREATE TABLE terms (
  id         SERIAL PRIMARY KEY,
  name       VARCHAR(50) NOT NULL,
  start_date DATE,
  end_date   DATE
);

CREATE TABLE grades (
  id          SERIAL PRIMARY KEY,
  student_id  INTEGER REFERENCES students(id),
  subject_id  INTEGER REFERENCES subjects(id),
  term_id     INTEGER REFERENCES terms(id),
  score       NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
  comment     TEXT,
  recorded_by INTEGER REFERENCES users(id),
  UNIQUE (student_id, subject_id, term_id)
);

CREATE TABLE fee_items (
  id          SERIAL PRIMARY KEY,
  student_id  INTEGER REFERENCES students(id),
  term_id     INTEGER REFERENCES terms(id),
  name        VARCHAR(100) NOT NULL,
  amount      NUMERIC(10,2) NOT NULL,
  paid        BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMP DEFAULT now()
);

CREATE TYPE session_status AS ENUM ('upcoming', 'live', 'ended');

CREATE TABLE live_sessions (
  id             SERIAL PRIMARY KEY,
  subject_id     INTEGER REFERENCES subjects(id),
  class_id       INTEGER REFERENCES classes(id),
  teacher_id     INTEGER REFERENCES users(id),
  scheduled_time TIMESTAMP NOT NULL,
  status         session_status NOT NULL DEFAULT 'upcoming',
  created_at     TIMESTAMP DEFAULT now()
);

CREATE TABLE lessons (
  id             SERIAL PRIMARY KEY,
  subject_id     INTEGER REFERENCES subjects(id),
  class_id       INTEGER REFERENCES classes(id),
  teacher_id     INTEGER REFERENCES users(id),
  title          VARCHAR(255) NOT NULL,
  has_homework   BOOLEAN NOT NULL DEFAULT false,
  homework_notes TEXT,
  posted_at      TIMESTAMP DEFAULT now()
);

CREATE TABLE session_reminders (
  user_id    INTEGER REFERENCES users(id),
  session_id INTEGER REFERENCES live_sessions(id),
  PRIMARY KEY (user_id, session_id)
);

CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_grades_student ON grades(student_id);
CREATE INDEX idx_students_class ON students(class_id);
CREATE INDEX idx_fee_items_student ON fee_items(student_id);
CREATE INDEX idx_sessions_status ON live_sessions(status);
