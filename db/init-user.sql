-- SQL init script to create users table for local Postgres
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),
    full_name VARCHAR(255),
    provider VARCHAR(50) NOT NULL DEFAULT 'LOCAL', -- 'LOCAL' or 'FIREBASE'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable extension for gen_random_uuid (Postgres >=13). If not available use uuid_generate_v4
CREATE EXTENSION IF NOT EXISTS pgcrypto;
