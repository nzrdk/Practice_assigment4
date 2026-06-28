DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'schedule_reader') THEN
        CREATE ROLE schedule_reader LOGIN PASSWORD '123456Aa@';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'schedule_editor') THEN
        CREATE ROLE schedule_editor LOGIN PASSWORD '123456Aa@';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'schedule_admin') THEN
        CREATE ROLE schedule_admin LOGIN PASSWORD '123456Aa@';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE uni_db TO schedule_reader, schedule_editor, schedule_admin;
GRANT USAGE ON SCHEMA public TO schedule_reader, schedule_editor, schedule_admin;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO schedule_reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO schedule_editor;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO schedule_admin;
