-- Create tickets table
CREATE TABLE IF NOT EXISTS tickets (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36),
    numbers VARCHAR(20),
    lucky_number VARCHAR(2),
    draw_date DATE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    first_name VARCHAR(26) NOT NULL,
    last_name VARCHAR(26) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE
);

-- Create ticket_gains table
CREATE TABLE IF NOT EXISTS ticket_gains (
    id VARCHAR(36) PRIMARY KEY,
    ticket_id VARCHAR(36) NOT NULL REFERENCES tickets(id),
    matching_numbers INTEGER,
    lucky_number_match BOOLEAN,
    gain_amount DECIMAL(10, 2)
);
