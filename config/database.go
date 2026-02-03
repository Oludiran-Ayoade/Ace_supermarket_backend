package config

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

var DB *sql.DB

// ConnectDatabase establishes connection to PostgreSQL
func ConnectDatabase() error {
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_NAME")

	// Use SSL for production (Render), disable for local development
	sslmode := "disable"
	if host != "localhost" && host != "127.0.0.1" {
		sslmode = "require"
	}

	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		host, port, user, password, dbname, sslmode)

	var err error
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		return fmt.Errorf("error opening database: %w", err)
	}

	// Test connection
	if err = DB.Ping(); err != nil {
		return fmt.Errorf("error connecting to database: %w", err)
	}

	log.Println("✅ Database connected successfully")

	// Auto-create work_experience table if it doesn't exist
	_, err = DB.Exec(`
		CREATE TABLE IF NOT EXISTS work_experience (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID REFERENCES users(id) ON DELETE CASCADE,
			company_name VARCHAR(200) NOT NULL,
			position VARCHAR(200) NOT NULL,
			start_date DATE,
			end_date DATE,
			responsibilities TEXT,
			role_id UUID,
			branch_id UUID,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)
	`)
	if err != nil {
		log.Printf("⚠️ Warning: Could not ensure work_experience table: %v", err)
	} else {
		log.Println("✅ work_experience table verified")
	}

	// Create index for faster lookups
	DB.Exec(`CREATE INDEX IF NOT EXISTS idx_work_experience_user_id ON work_experience(user_id)`)

	return nil
}

// CloseDatabase closes the database connection
func CloseDatabase() {
	if DB != nil {
		DB.Close()
		log.Println("Database connection closed")
	}
}
