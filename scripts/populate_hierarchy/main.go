package main

import (
	"database/sql"
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	_ "github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	Email      string
	FullName   string
	RoleName   string
	EmployeeID string
	Department string // Optional, for group heads
}

func main() {
	// Database connection
	connStr := "host=localhost port=5433 user=postgres password=Circumspect1 dbname=aceSuperMarket sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer db.Close()

	// Test connection
	if err := db.Ping(); err != nil {
		log.Fatal("Failed to ping database:", err)
	}

	fmt.Println("✅ Connected to database")

	// Hash the universal password
	password := "password123"
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal("Failed to hash password:", err)
	}

	fmt.Println("✅ Password hashed successfully")

	// Define all hierarchy users
	users := []User{
		// Auditors (using unique employee IDs)
		{Email: "auditor1@acemarket.com", FullName: "Mr. Chukwudi Nwosu", RoleName: "Auditor", EmployeeID: "ACE-AUD-101"},
		{Email: "auditor2@acemarket.com", FullName: "Mrs. Amaka Okafor", RoleName: "Auditor", EmployeeID: "ACE-AUD-102"},

		// Group Heads (already created successfully)
		{Email: "gh.supermarket@acemarket.com", FullName: "Mr. Tunde Bakare", RoleName: "Group Head (SuperMarket)", EmployeeID: "ACE-GH-SM-001", Department: "SuperMarket"},
		{Email: "gh.eatery@acemarket.com", FullName: "Mrs. Ngozi Eze", RoleName: "Group Head (Eatery)", EmployeeID: "ACE-GH-ET-001", Department: "Eatery"},
		{Email: "gh.lounge@acemarket.com", FullName: "Mr. Segun Afolabi", RoleName: "Group Head (Lounge)", EmployeeID: "ACE-GH-LG-001", Department: "Lounge"},
		{Email: "gh.arcade@acemarket.com", FullName: "Miss Funke Adeyemi", RoleName: "Group Head (Fun & Arcade)", EmployeeID: "ACE-GH-AR-001", Department: "Fun & Arcade"},
		{Email: "gh.compliance@acemarket.com", FullName: "Mr. Ibrahim Yusuf", RoleName: "Group Head (Compliance)", EmployeeID: "ACE-GH-CP-001", Department: "Compliance"},
		{Email: "gh.facility@acemarket.com", FullName: "Mr. Emeka Obi", RoleName: "Group Head (Facility Management)", EmployeeID: "ACE-GH-FM-001", Department: "Facility Management"},
	}

	// Insert each user
	for _, user := range users {
		err := insertUser(db, user, string(hashedPassword))
		if err != nil {
			log.Printf("❌ Failed to insert %s: %v", user.Email, err)
		} else {
			fmt.Printf("✅ Inserted: %s (%s)\n", user.FullName, user.Email)
		}
	}

	fmt.Println("\n🎉 All hierarchy users populated successfully!")
	fmt.Println("📧 Universal login credentials:")
	fmt.Println("   Password: password123")
	fmt.Println("\n👥 Admin:")
	fmt.Println("   - hr@acesupermarket.com (HR Administrator - Already exists)")
	fmt.Println("   - auditor1@acemarket.com (Auditor)")
	fmt.Println("   - auditor2@acemarket.com (Auditor)")
	fmt.Println("\n👔 Group Heads:")
	fmt.Println("   - gh.supermarket@acemarket.com")
	fmt.Println("   - gh.eatery@acemarket.com")
	fmt.Println("   - gh.lounge@acemarket.com")
	fmt.Println("   - gh.arcade@acemarket.com")
	fmt.Println("   - gh.compliance@acemarket.com")
	fmt.Println("   - gh.facility@acemarket.com")
}

func insertUser(db *sql.DB, user User, hashedPassword string) error {
	// Get role ID
	var roleID string
	err := db.QueryRow("SELECT id FROM roles WHERE name = $1 OR name LIKE $2 LIMIT 1", user.RoleName, "%"+user.RoleName+"%").Scan(&roleID)
	if err != nil {
		return fmt.Errorf("role not found: %w", err)
	}

	// Get department ID if specified
	var departmentID *string
	if user.Department != "" {
		var deptID string
		err := db.QueryRow("SELECT id FROM departments WHERE name = $1 LIMIT 1", user.Department).Scan(&deptID)
		if err == nil {
			departmentID = &deptID
		}
	}

	// Check if user already exists
	var existingID string
	err = db.QueryRow("SELECT id FROM users WHERE email = $1", user.Email).Scan(&existingID)

	if err == sql.ErrNoRows {
		// Insert new user
		userID := uuid.New().String()
		_, err = db.Exec(`
			INSERT INTO users (
				id, email, password_hash, full_name, role_id, department_id, 
				employee_id, date_joined, is_active, created_at, updated_at
			) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		`,
			userID,
			user.Email,
			hashedPassword,
			user.FullName,
			roleID,
			departmentID,
			user.EmployeeID,
			time.Now(),
			true,
			time.Now(),
			time.Now(),
		)
		return err
	} else if err != nil {
		return err
	} else {
		// Update existing user
		_, err = db.Exec(`
			UPDATE users 
			SET password_hash = $1, full_name = $2, role_id = $3, 
			    department_id = $4, employee_id = $5, 
			    is_active = $6, updated_at = $7
			WHERE email = $8
		`,
			hashedPassword,
			user.FullName,
			roleID,
			departmentID,
			user.EmployeeID,
			true,
			time.Now(),
			user.Email,
		)
		return err
	}
}
