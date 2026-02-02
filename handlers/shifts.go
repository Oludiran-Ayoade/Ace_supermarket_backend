package handlers

import (
	"database/sql"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// GetShiftTemplates returns shift templates for the authenticated floor manager
func GetShiftTemplates(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	// Verify user is a floor manager
	var roleName string
	err := db.QueryRow(`
		SELECT r.name
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, userID).Scan(&roleName)

	if err != nil || !strings.Contains(roleName, "Floor Manager") {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only floor managers can access shift templates"})
		return
	}

	query := `
		SELECT id, shift_type, start_time, end_time
		FROM shift_templates
		WHERE floor_manager_id = $1
		ORDER BY 
			CASE shift_type
				WHEN 'day' THEN 1
				WHEN 'afternoon' THEN 2
				WHEN 'night' THEN 3
			END
	`

	rows, err := db.Query(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch shift templates"})
		return
	}
	defer rows.Close()

	templates := []map[string]interface{}{}
	for rows.Next() {
		var id int
		var shiftType, startTime, endTime string

		err := rows.Scan(&id, &shiftType, &startTime, &endTime)
		if err != nil {
			continue
		}

		templates = append(templates, map[string]interface{}{
			"id":         id,
			"shift_type": shiftType,
			"start_time": startTime,
			"end_time":   endTime,
		})
	}

	// If no templates exist, create default ones
	if len(templates) == 0 {
		templates = createDefaultShiftTemplates(db, userID)
	}

	c.JSON(http.StatusOK, templates)
}

// UpdateShiftTemplate updates a shift template's times
func UpdateShiftTemplate(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")
	templateID := c.Param("id")

	var req struct {
		StartTime string `json:"start_time" binding:"required"`
		EndTime   string `json:"end_time" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify the template belongs to this floor manager
	var ownerID int
	err := db.QueryRow(`
		SELECT floor_manager_id FROM shift_templates WHERE id = $1
	`, templateID).Scan(&ownerID)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Shift template not found"})
		return
	}

	if ownerID != mustParseInt(userID) {
		c.JSON(http.StatusForbidden, gin.H{"error": "You can only update your own shift templates"})
		return
	}

	// Update the template
	query := `
		UPDATE shift_templates
		SET start_time = $1, end_time = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $3
	`

	_, err = db.Exec(query, req.StartTime, req.EndTime, templateID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update shift template"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Shift template updated successfully"})
}

// GetAvailableShifts returns available shift types with their times for roster creation
func GetAvailableShifts(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	// Get shift templates for this floor manager
	query := `
		SELECT shift_type, start_time, end_time
		FROM shift_templates
		WHERE floor_manager_id = $1
		ORDER BY 
			CASE shift_type
				WHEN 'day' THEN 1
				WHEN 'afternoon' THEN 2
				WHEN 'night' THEN 3
			END
	`

	rows, err := db.Query(query, userID)
	if err != nil {
		// Return default shifts if query fails
		c.JSON(http.StatusOK, getDefaultShifts())
		return
	}
	defer rows.Close()

	shifts := []map[string]interface{}{}
	for rows.Next() {
		var shiftType, startTime, endTime string

		err := rows.Scan(&shiftType, &startTime, &endTime)
		if err != nil {
			continue
		}

		// Map shift type to display name
		displayName := getShiftDisplayName(shiftType)

		shifts = append(shifts, map[string]interface{}{
			"type":       shiftType,
			"name":       displayName,
			"start_time": startTime,
			"end_time":   endTime,
		})
	}

	// If no shifts found, return defaults
	if len(shifts) == 0 {
		shifts = getDefaultShifts()
	}

	// Add "Off" option
	shifts = append(shifts, map[string]interface{}{
		"type":       "off",
		"name":       "Off",
		"start_time": "00:00:00",
		"end_time":   "00:00:00",
	})

	c.JSON(http.StatusOK, shifts)
}

// Helper functions
func createDefaultShiftTemplates(db *sql.DB, floorManagerID string) []map[string]interface{} {
	defaults := []struct {
		shiftType string
		startTime string
		endTime   string
	}{
		{"day", "07:00:00", "15:00:00"},
		{"afternoon", "15:00:00", "23:00:00"},
		{"night", "23:00:00", "07:00:00"},
	}

	templates := []map[string]interface{}{}
	for _, def := range defaults {
		var id int
		err := db.QueryRow(`
			INSERT INTO shift_templates (floor_manager_id, shift_type, start_time, end_time)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (floor_manager_id, shift_type) DO UPDATE
			SET start_time = EXCLUDED.start_time, end_time = EXCLUDED.end_time
			RETURNING id
		`, floorManagerID, def.shiftType, def.startTime, def.endTime).Scan(&id)

		if err == nil {
			templates = append(templates, map[string]interface{}{
				"id":         id,
				"shift_type": def.shiftType,
				"start_time": def.startTime,
				"end_time":   def.endTime,
			})
		}
	}

	return templates
}

func getDefaultShifts() []map[string]interface{} {
	return []map[string]interface{}{
		{
			"type":       "day",
			"name":       "Morning",
			"start_time": "07:00:00",
			"end_time":   "15:00:00",
		},
		{
			"type":       "afternoon",
			"name":       "Afternoon",
			"start_time": "15:00:00",
			"end_time":   "23:00:00",
		},
		{
			"type":       "night",
			"name":       "Evening",
			"start_time": "23:00:00",
			"end_time":   "07:00:00",
		},
	}
}

func getShiftDisplayName(shiftType string) string {
	switch shiftType {
	case "day":
		return "Morning"
	case "afternoon":
		return "Afternoon"
	case "night":
		return "Evening"
	default:
		return shiftType
	}
}

func mustParseInt(s string) int {
	var i int
	// Simple conversion, ignoring errors for brevity
	for _, c := range s {
		if c >= '0' && c <= '9' {
			i = i*10 + int(c-'0')
		}
	}
	return i
}
