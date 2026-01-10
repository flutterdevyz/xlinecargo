-- database/init.sql
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role VARCHAR(20) DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email, password, role)
VALUES ('Admin', 'admin', '$2a$10$tRdPjFxKDqu2bwyc//x7g.MzuWMNW6MvpM3HVVcaXs03A5MhPh5oW', 'admin')
ON CONFLICT (email) DO NOTHING;

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  product_name VARCHAR(150) NOT NULL,
  quantity INT CHECK (quantity BETWEEN 1 AND 10),
  track_code VARCHAR(100) UNIQUE NOT NULL,
  status VARCHAR(50) DEFAULT 'created',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
