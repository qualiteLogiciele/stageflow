-- Crée la base de données Keycloak dans la même instance PostgreSQL
SELECT 'CREATE DATABASE keycloak'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'keycloak')\gexec