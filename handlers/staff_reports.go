package handlers

import (
	"database/sql"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

// StaffReportItem represents a staff member in the report
type StaffReportItem struct {
	ID             string  `json:"id"`
	FullName       string  `json:"full_name"`
	RoleName       string  `json:"role_name"`
	RoleCategory   string  `json:"role_category"`
	DateJoined     *string `json:"date_joined"`
	DateOfBirth    *string `json:"date_of_birth"`
	Gender         string  `json:"gender"`
	CourseOfStudy  *string `json:"course_of_study"`
	Grade          *string `json:"grade"`
	Institution    *string `json:"institution"`
	ExamScores     *string `json:"exam_scores"`
	DepartmentName *string `json:"department_name"`
	BranchName     *string `json:"branch_name"`
	Salary         float64 `json:"current_salary"`
	EmployeeID     *string `json:"employee_id"`
}

// GetStaffReport returns staff data for reports with filtering options
func GetStaffReport(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Get filter parameters
	filterType := c.Query("filter_type") // all, branch, department, role, gender, senior
	branchID := c.Query("branch_id")
	departmentID := c.Query("department_id")
	roleID := c.Query("role_id")
	gender := c.Query("gender")
	sortBy := c.Query("sort_by") // date_joined, name, age

	// Base query - exclude terminated staff
	query := `
		SELECT 
			u.id, u.full_name, u.gender, u.date_of_birth, u.date_joined,
			u.course_of_study, u.grade, u.institution,
			u.current_salary, u.employee_id,
			r.name as role_name, r.category as role_category,
			d.name as department_name,
			b.name as branch_name,
			es.score as exam_scores
		FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		LEFT JOIN departments d ON u.department_id = d.id
		LEFT JOIN branches b ON u.branch_id = b.id
		LEFT JOIN exam_scores es ON u.id = es.user_id
		WHERE u.is_terminated = false
	`

	args := []interface{}{}
	argCount := 1

	// Apply filters based on filter_type
	switch filterType {
	case "branch":
		if branchID != "" {
			query += fmt.Sprintf(` AND u.branch_id = $%d`, argCount)
			args = append(args, branchID)
			argCount++
		}
	case "department":
		if departmentID != "" {
			query += fmt.Sprintf(` AND u.department_id = $%d`, argCount)
			args = append(args, departmentID)
			argCount++
		}
	case "role":
		if roleID != "" {
			query += fmt.Sprintf(` AND u.role_id = $%d`, argCount)
			args = append(args, roleID)
			argCount++
		}
	case "gender":
		if gender != "" {
			query += fmt.Sprintf(` AND u.gender = $%d`, argCount)
			args = append(args, gender)
			argCount++
		}
	case "senior":
		query += ` AND r.category = 'senior_admin'`
	}

	// Apply sorting
	switch sortBy {
	case "date_joined":
		query += ` ORDER BY u.date_joined ASC` // Oldest first
	case "name":
		query += ` ORDER BY u.full_name ASC`
	case "age":
		query += ` ORDER BY u.date_of_birth ASC` // Oldest first
	default:
		query += ` ORDER BY u.date_joined ASC` // Default to oldest staff first
	}

	rows, err := db.Query(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch staff report: " + err.Error()})
		return
	}
	defer rows.Close()

	var staff []StaffReportItem
	for rows.Next() {
		var item StaffReportItem
		var dateJoined, dateOfBirth sql.NullTime
		var courseOfStudy, grade, institution, employeeID, examScores sql.NullString
		var departmentName, branchName sql.NullString

		err := rows.Scan(
			&item.ID, &item.FullName, &item.Gender, &dateOfBirth, &dateJoined,
			&courseOfStudy, &grade, &institution,
			&item.Salary, &employeeID,
			&item.RoleName, &item.RoleCategory,
			&departmentName, &branchName,
			&examScores,
		)

		if err != nil {
			continue
		}

		// Handle nullable fields
		if dateJoined.Valid {
			dateStr := dateJoined.Time.Format("2006-01-02")
			item.DateJoined = &dateStr
		}
		if dateOfBirth.Valid {
			dobStr := dateOfBirth.Time.Format("2006-01-02")
			item.DateOfBirth = &dobStr
		}
		if courseOfStudy.Valid {
			item.CourseOfStudy = &courseOfStudy.String
		}
		if grade.Valid {
			item.Grade = &grade.String
		}
		if institution.Valid {
			item.Institution = &institution.String
		}
		if examScores.Valid {
			item.ExamScores = &examScores.String
		}
		if employeeID.Valid {
			item.EmployeeID = &employeeID.String
		}
		if departmentName.Valid {
			item.DepartmentName = &departmentName.String
		}
		if branchName.Valid {
			item.BranchName = &branchName.String
		}

		staff = append(staff, item)
	}

	c.JSON(http.StatusOK, gin.H{
		"staff": staff,
		"count": len(staff),
	})
}
