--INSERT DATA INTO THE TABLES--
--USERS--
INSERT INTO users (full_name, email, phone_number, username, password) VALUES ('John Doe', 'john.doe@example.com', '1234567890', 'johndoe', 'password');
INSERT INTO users (full_name, email, phone_number, username, password) VALUES ('Jane Doe', 'jane.doe@example.com', '0987654321', 'janedoe', 'password');
--TRAVELS--
INSERT INTO travels (user_id, date, initial_location, final_location, distance) VALUES (1, '2025-01-01', 'New York', 'Los Angeles', 1000);
INSERT INTO travels (user_id, date, initial_location, final_location, distance) VALUES (2, '2025-01-02', 'Los Angeles', 'New York', 1000);
--MOTORCYCLES--
INSERT INTO motorcycles (make, model, year, power, torque, type, displacement, fuel_capacity, weight, user_id) VALUES ('Honda', 'CBR1000RR', 2024, 200, 150, 'Sport', 1000, '100L', 200, 1);
INSERT INTO motorcycles (make, model, year, power, torque, type, displacement, fuel_capacity, weight, user_id) VALUES ('Yamaha', 'YZF-R1', 2024, 200, 150, 'Sport', 1000, '100L', 200, 2);
--OBSERVATIONS--
INSERT INTO observations (motorcycle_id, observation) VALUES (1, 'Good condition');
INSERT INTO observations (motorcycle_id, observation) VALUES (2, 'Bad condition');
--MAINTENANCE--
INSERT INTO maintenance (motorcycle_id, date, description, cost) VALUES (1, '2025-01-01', 'Oil change', 100);
INSERT INTO maintenance (motorcycle_id, date, description, cost) VALUES (2, '2025-01-02', 'Oil change', 100);