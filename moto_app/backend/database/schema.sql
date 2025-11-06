--DELETION OF THE TABLES--
DROP TABLE IF EXISTS maintenance CASCADE;
DROP TABLE IF EXISTS observations CASCADE;
DROP TABLE IF EXISTS travels CASCADE;
DROP TABLE IF EXISTS motorcycles CASCADE;
DROP TABLE IF EXISTS users CASCADE;


--TABLE CREATION---
--USER--
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
)
--TRAVELS-- 
CREATE TABLE travels (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    date DATE NOT NULL,
    initial_location VARCHAR(255) NOT NULL,
    final_location VARCHAR(255) NOT NULL,
    distance INT NOT NULL
)
--MOTORCYCLE--
CREATE TABLE motorcycles (
    id SERIAL PRIMARY KEY,
    make VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    year INT NOT NULL,
    power INT NOT NULL,
    torque INT NOT NULL,
    type VARCHAR(255) NOT NULL,
    displacement INT ,
    fuel_capacity VARCHAR(255) NOT NULL,
    weight INT NOT NULL,
    user_id INT NOT NULL REFERENCES users(id)
)

--OBSERVACIONES-----
CREATE TABLE observations (
    id SERIAL PRIMARY KEY,
    motorcycle_id INT NOT NULL REFERENCES motorcycles(id),
    observation TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)

--MANTEINANCE --
CREATE TABLE maintenance (
    id SERIAL PRIMARY KEY,
    motorcycle_id INT NOT NULL REFERENCES motorcycles(id),
    date DATE NOT NULL,
    description TEXT NOT NULL,
    cost DECIMAL(10, 2) NOT NULL
)

-- TECNOMECANIC (Revisión técnico-mecánica)
CREATE TABLE technomechanical (
    id SERIAL PRIMARY KEY,
    motorcycle_id INT NOT NULL REFERENCES motorcycles(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    cost DECIMAL(10, 2) NOT NULL
);

-- SOAT (Seguro Obligatorio)
CREATE TABLE soat (
    id SERIAL PRIMARY KEY,
    motorcycle_id INT NOT NULL REFERENCES motorcycles(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    cost DECIMAL(10, 2) NOT NULL
);
