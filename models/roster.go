package models

import (
	"time"
)

// ShiftType represents the type of shift
type ShiftType string

const (
	ShiftTypeDay       ShiftType = "day"
	ShiftTypeAfternoon ShiftType = "afternoon"
	ShiftTypeNight     ShiftType = "night"
)

// DayOfWeek represents days of the week
type DayOfWeek string

const (
	Monday    DayOfWeek = "monday"
	Tuesday   DayOfWeek = "tuesday"
	Wednesday DayOfWeek = "wednesday"
	Thursday  DayOfWeek = "thursday"
	Friday    DayOfWeek = "friday"
	Saturday  DayOfWeek = "saturday"
	Sunday    DayOfWeek = "sunday"
)

// Roster represents a weekly roster created by a floor manager
type Roster struct {
	ID             string    `json:"id"`
	FloorManagerID string    `json:"floor_manager_id"`
	DepartmentID   *string   `json:"department_id,omitempty"`
	BranchID       *string   `json:"branch_id,omitempty"`
	WeekStartDate  time.Time `json:"week_start_date"`
	WeekEndDate    time.Time `json:"week_end_date"`
	Status         string    `json:"status"` // draft, published, archived
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`

	// Populated fields
	FloorManagerName *string `json:"floor_manager_name,omitempty"`
	DepartmentName   *string `json:"department_name,omitempty"`
	BranchName       *string `json:"branch_name,omitempty"`
}

// RosterAssignment represents an individual shift assignment
type RosterAssignment struct {
	ID        string    `json:"id"`
	RosterID  string    `json:"roster_id"`
	StaffID   string    `json:"staff_id"`
	DayOfWeek DayOfWeek `json:"day_of_week"`
	ShiftType ShiftType `json:"shift_type"`
	StartTime string    `json:"start_time"` // HH:MM:SS format
	EndTime   string    `json:"end_time"`   // HH:MM:SS format
	Notes     *string   `json:"notes,omitempty"`
	CreatedAt time.Time `json:"created_at"`

	// Populated fields
	StaffName *string `json:"staff_name,omitempty"`
	StaffRole *string `json:"staff_role,omitempty"`
}

// WeeklyReview represents a weekly performance review
type WeeklyReview struct {
	ID                  string    `json:"id"`
	StaffID             string    `json:"staff_id"`
	ReviewerID          string    `json:"reviewer_id"`
	RosterID            *string   `json:"roster_id,omitempty"`
	WeekStartDate       time.Time `json:"week_start_date"`
	WeekEndDate         time.Time `json:"week_end_date"`
	Rating              *int      `json:"rating,omitempty"`             // 1-5
	PunctualityRating   *int      `json:"punctuality_rating,omitempty"` // 1-5
	PerformanceRating   *int      `json:"performance_rating,omitempty"` // 1-5
	AttitudeRating      *int      `json:"attitude_rating,omitempty"`    // 1-5
	Comments            *string   `json:"comments,omitempty"`
	Strengths           *string   `json:"strengths,omitempty"`
	AreasForImprovement *string   `json:"areas_for_improvement,omitempty"`
	CreatedAt           time.Time `json:"created_at"`
	UpdatedAt           time.Time `json:"updated_at"`

	// Populated fields
	StaffName    *string `json:"staff_name,omitempty"`
	ReviewerName *string `json:"reviewer_name,omitempty"`
}

// ShiftTemplate represents predefined shift times for a floor manager
type ShiftTemplate struct {
	ID             string    `json:"id"`
	FloorManagerID string    `json:"floor_manager_id"`
	ShiftType      ShiftType `json:"shift_type"`
	StartTime      string    `json:"start_time"` // HH:MM:SS format
	EndTime        string    `json:"end_time"`   // HH:MM:SS format
	IsDefault      bool      `json:"is_default"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

// CreateRosterRequest represents the request to create a new roster
type CreateRosterRequest struct {
	WeekStartDate string                          `json:"week_start_date" binding:"required"`
	WeekEndDate   string                          `json:"week_end_date" binding:"required"`
	Assignments   []CreateRosterAssignmentRequest `json:"assignments" binding:"required"`
}

// CreateRosterAssignmentRequest represents a single shift assignment in the roster
type CreateRosterAssignmentRequest struct {
	StaffID   string    `json:"staff_id" binding:"required"`
	DayOfWeek DayOfWeek `json:"day_of_week" binding:"required"`
	ShiftType ShiftType `json:"shift_type" binding:"required"`
	StartTime string    `json:"start_time" binding:"required"`
	EndTime   string    `json:"end_time" binding:"required"`
	Notes     *string   `json:"notes"`
}

// CreateWeeklyReviewRequest represents the request to create a weekly review
type CreateWeeklyReviewRequest struct {
	StaffID             string  `json:"staff_id" binding:"required"`
	WeekStartDate       string  `json:"week_start_date" binding:"required"`
	WeekEndDate         string  `json:"week_end_date" binding:"required"`
	Rating              *int    `json:"rating"`
	PunctualityRating   *int    `json:"punctuality_rating"`
	PerformanceRating   *int    `json:"performance_rating"`
	AttitudeRating      *int    `json:"attitude_rating"`
	Comments            *string `json:"comments"`
	Strengths           *string `json:"strengths"`
	AreasForImprovement *string `json:"areas_for_improvement"`
}

// RosterWithAssignments combines roster with its assignments
type RosterWithAssignments struct {
	Roster      Roster             `json:"roster"`
	Assignments []RosterAssignment `json:"assignments"`
	StaffCount  int                `json:"staff_count"`
}

// StaffSchedule represents a staff member's schedule view
type StaffSchedule struct {
	StaffID    string             `json:"staff_id"`
	StaffName  string             `json:"staff_name"`
	WeekStart  time.Time          `json:"week_start"`
	WeekEnd    time.Time          `json:"week_end"`
	Shifts     []RosterAssignment `json:"shifts"`
	TotalHours float64            `json:"total_hours"`
}
