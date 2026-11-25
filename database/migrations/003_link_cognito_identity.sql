ALTER TABLE students
ADD COLUMN IF NOT EXISTS cognito_sub VARCHAR(255);

CREATE UNIQUE INDEX IF NOT EXISTS students_cognito_sub_unique
ON students (cognito_sub)
WHERE cognito_sub IS NOT NULL;

GRANT UPDATE (cognito_sub) ON TABLE students TO utcapp_service;
