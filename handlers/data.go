package handlers

import (
	"ace-mall-backend/config"
	"ace-mall-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// GetBranches returns all active branches
func GetBranches(c *gin.Context) {
	query := `
		SELECT id, name, location, is_active, created_at, updated_at
		FROM branches
		WHERE is_active = true
		ORDER BY name
	`

	rows, err := config.DB.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}
	defer rows.Close()

	var branches []models.Branch
	for rows.Next() {
		var branch models.Branch
		err := rows.Scan(&branch.ID, &branch.Name, &branch.Location, &branch.IsActive,
			&branch.CreatedAt, &branch.UpdatedAt)
		if err != nil {
			continue
		}
		branches = append(branches, branch)
	}

	c.JSON(http.StatusOK, gin.H{"branches": branches})
}

// GetDepartments returns all active departments
func GetDepartments(c *gin.Context) {
	query := `
		SELECT id, name, description, is_active, created_at, updated_at
		FROM departments
		WHERE is_active = true
		ORDER BY name
	`

	rows, err := config.DB.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}
	defer rows.Close()

	var departments []models.Department
	for rows.Next() {
		var dept models.Department
		err := rows.Scan(&dept.ID, &dept.Name, &dept.Description, &dept.IsActive,
			&dept.CreatedAt, &dept.UpdatedAt)
		if err != nil {
			continue
		}
		departments = append(departments, dept)
	}

	c.JSON(http.StatusOK, gin.H{"departments": departments})
}

// GetSubDepartments returns sub-departments for a department
func GetSubDepartments(c *gin.Context) {
	departmentID := c.Param("department_id")

	query := `
		SELECT id, department_id, name, description, is_active, created_at, updated_at
		FROM sub_departments
		WHERE department_id = $1 AND is_active = true
		ORDER BY name
	`

	rows, err := config.DB.Query(query, departmentID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}
	defer rows.Close()

	var subDepts []models.SubDepartment
	for rows.Next() {
		var subDept models.SubDepartment
		err := rows.Scan(&subDept.ID, &subDept.DepartmentID, &subDept.Name, &subDept.Description,
			&subDept.IsActive, &subDept.CreatedAt, &subDept.UpdatedAt)
		if err != nil {
			continue
		}
		subDepts = append(subDepts, subDept)
	}

	c.JSON(http.StatusOK, gin.H{"sub_departments": subDepts})
}

// GetRoles returns roles, optionally filtered by category or department
func GetRoles(c *gin.Context) {
	category := c.Query("category") // senior_admin, admin, general
	departmentID := c.Query("department_id")

	query := `
		SELECT r.id, r.name, r.category, r.department_id, r.sub_department_id, 
		       r.description, r.is_active, r.created_at, r.updated_at,
		       d.name as department_name, sd.name as sub_department_name
		FROM roles r
		LEFT JOIN departments d ON r.department_id = d.id
		LEFT JOIN sub_departments sd ON r.sub_department_id = sd.id
		WHERE r.is_active = true
	`

	var args []interface{}
	argCount := 1

	if category != "" {
		query += " AND r.category = $" + string(rune(argCount+'0'))
		args = append(args, category)
		argCount++
	}

	if departmentID != "" {
		query += " AND r.department_id = $" + string(rune(argCount+'0'))
		args = append(args, departmentID)
	}

	query += " ORDER BY r.category, r.name"

	rows, err := config.DB.Query(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}
	defer rows.Close()

	var roles []models.Role
	for rows.Next() {
		var role models.Role
		err := rows.Scan(&role.ID, &role.Name, &role.Category, &role.DepartmentID,
			&role.SubDepartmentID, &role.Description, &role.IsActive,
			&role.CreatedAt, &role.UpdatedAt, &role.DepartmentName, &role.SubDepartmentName)
		if err != nil {
			continue
		}
		roles = append(roles, role)
	}

	c.JSON(http.StatusOK, gin.H{"roles": roles})
}

// GetRolesByCategory returns roles for a specific category
func GetRolesByCategory(c *gin.Context) {
	category := c.Param("category")

	query := `
		SELECT r.id, r.name, r.category, r.department_id, r.sub_department_id, 
		       r.description, r.is_active, r.created_at, r.updated_at,
		       d.name as department_name, sd.name as sub_department_name
		FROM roles r
		LEFT JOIN departments d ON r.department_id = d.id
		LEFT JOIN sub_departments sd ON r.sub_department_id = sd.id
		WHERE r.is_active = true AND r.category = $1
		ORDER BY r.name
	`

	rows, err := config.DB.Query(query, category)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}
	defer rows.Close()

	var roles []models.Role
	for rows.Next() {
		var role models.Role
		err := rows.Scan(&role.ID, &role.Name, &role.Category, &role.DepartmentID,
			&role.SubDepartmentID, &role.Description, &role.IsActive,
			&role.CreatedAt, &role.UpdatedAt, &role.DepartmentName, &role.SubDepartmentName)
		if err != nil {
			continue
		}
		roles = append(roles, role)
	}

	c.JSON(http.StatusOK, gin.H{"roles": roles, "category": category})
}
