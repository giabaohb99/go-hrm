-- Update admin password with correct bcrypt hash
-- Password: admin123
-- This hash is generated using bcrypt with cost 10
UPDATE lit_user 
SET u_password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE id = 1;
