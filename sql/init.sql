-- Crear tabla state
CREATE TABLE IF NOT EXISTS state (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

INSERT INTO state (name) VALUES ('Activo');
INSERT INTO state (name) VALUES ('Inactivo');


-- Crear tabla agency
CREATE TABLE IF NOT EXISTS agency (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    province VARCHAR(120),
    district VARCHAR(120),
    address VARCHAR(255),
    id_state INT NOT NULL,
    part_schedule VARCHAR(255),
    weekend_schedule VARCHAR(255),
    emb VARCHAR(50),
    FOREIGN KEY (id_state) REFERENCES state(id)
);

INSERT INTO agency (name, province, district, address, id_state, part_schedule, weekend_schedule, emb)
VALUES ('Agencia Central', 'Lima', 'Miraflores', 'Av Principal 123', 1, '8am-1pm', '9am-12pm', 'EMB001');

INSERT INTO agency (name, province, district, address, id_state, part_schedule, weekend_schedule, emb)
VALUES ('Agencia Norte', 'Lima', 'Independencia', 'Calle Norte 456', 1, '8am-1pm', 'Cerrado', 'EMB002');

-- Crear tabla user
CREATE TABLE IF NOT EXISTS user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    photo VARCHAR(255),
    cargo VARCHAR(100),
    state_id INT NOT NULL,
    FOREIGN KEY (state_id) REFERENCES state(id)
);

INSERT INTO user (name, email, password, photo, cargo, state_id)
VALUES ('Usuario Uno', 'uno@test.com', '$pbkdf2-sha256$29000$sVZKKYWQkrK2di5lTGmN0Q$6yk0uTyVxuQeSVF0iy0qXF0k7jou6RSvT7SWhu37Qqk', NULL, 'admin', 1);

INSERT INTO user (name, email, password, photo, cargo, state_id)
VALUES ('Usuario Dos', 'dos@test.com', '$pbkdf2-sha256$29000$sVZKKYWQkrK2di5lTGmN0Q$6yk0uTyVxuQeSVF0iy0qXF0k7jou6RSvT7SWhu37Qqk', NULL, 'user', 1);

INSERT INTO user (name, email, password, photo, cargo, state_id)
VALUES ('Usuario Tres', 'tres@test.com', '$pbkdf2-sha256$29000$sVZKKYWQkrK2di5lTGmN0Q$6yk0uTyVxuQeSVF0iy0qXF0k7jou6RSvT7SWhu37Qqk', NULL, 'user', 2);

INSERT INTO user (name, email, password, photo, cargo, state_id)
VALUES ('Usuario Cuatro', 'cuatro@test.com', '$pbkdf2-sha256$29000$sVZKKYWQkrK2di5lTGmN0Q$6yk0uTyVxuQeSVF0iy0qXF0k7jou6RSvT7SWhu37Qqk', NULL, 'user', 2);
