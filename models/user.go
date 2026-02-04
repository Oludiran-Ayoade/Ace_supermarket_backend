package models

import (
	"time"
)

// User represents a staff member
type User struct {
	ID           string `json:"id"`
	Email        string `json:"email"`
	PasswordHash string `json:"-"` // Never expose password hash

	// Personal Information
	FullName             string     `json:"full_name"`
	Gender               *string    `json:"gender,omitempty"`
	DateOfBirth          *time.Time `json:"date_of_birth,omitempty"`
	MaritalStatus        *string    `json:"marital_status,omitempty"`
	PhoneNumber          *string    `json:"phone_number,omitempty"`
	HomeAddress          *string    `json:"home_address,omitempty"`
	StateOfOrigin        *string    `json:"state_of_origin,omitempty"`
	ProfileImageURL      *string    `json:"profile_image_url,omitempty"`
	ProfileImagePublicID *string    `json:"profile_image_public_id,omitempty"`

	// Work Information
	EmployeeID        *string   `json:"employee_id,omitempty"`
	RoleID            *string   `json:"role_id,omitempty"`
	RoleName          *string   `json:"role_name,omitempty"`
	RoleCategory      *string   `json:"role_category,omitempty"`
	DepartmentID      *string   `json:"department_id,omitempty"`
	DepartmentName    *string   `json:"department_name,omitempty"`
	SubDepartmentID   *string   `json:"sub_department_id,omitempty"`
	SubDepartmentName *string   `json:"sub_department_name,omitempty"`
	BranchID          *string   `json:"branch_id,omitempty"`
	BranchName        *string   `json:"branch_name,omitempty"`
	DateJoined        time.Time `json:"date_joined"`
	CurrentSalary     *float64  `json:"current_salary,omitempty"`

	// Education
	CourseOfStudy *string `json:"course_of_study,omitempty"`
	Grade         *string `json:"grade,omitempty"`
	Institution   *string `json:"institution,omitempty"`

	// Educational Certificates
	WaecCertificateURL         *string `json:"waec_certificate_url,omitempty"`
	WaecCertificatePublicID    *string `json:"waec_certificate_public_id,omitempty"`
	NecoCertificateURL         *string `json:"neco_certificate_url,omitempty"`
	NecoCertificatePublicID    *string `json:"neco_certificate_public_id,omitempty"`
	JambResultURL              *string `json:"jamb_result_url,omitempty"`
	JambResultPublicID         *string `json:"jamb_result_public_id,omitempty"`
	DegreeCertificateURL       *string `json:"degree_certificate_url,omitempty"`
	DegreeCertificatePublicID  *string `json:"degree_certificate_public_id,omitempty"`
	DiplomaCertificateURL      *string `json:"diploma_certificate_url,omitempty"`
	DiplomaCertificatePublicID *string `json:"diploma_certificate_public_id,omitempty"`

	// Identity Documents
	BirthCertificateURL      *string `json:"birth_certificate_url,omitempty"`
	BirthCertificatePublicID *string `json:"birth_certificate_public_id,omitempty"`
	NationalIDURL            *string `json:"national_id_url,omitempty"`
	NationalIDPublicID       *string `json:"national_id_public_id,omitempty"`
	PassportURL              *string `json:"passport_url,omitempty"`
	PassportPublicID         *string `json:"passport_public_id,omitempty"`
	DriversLicenseURL        *string `json:"drivers_license_url,omitempty"`
	DriversLicensePublicID   *string `json:"drivers_license_public_id,omitempty"`
	VotersCardURL            *string `json:"voters_card_url,omitempty"`
	VotersCardPublicID       *string `json:"voters_card_public_id,omitempty"`

	// Government Documents
	NyscCertificateURL        *string `json:"nysc_certificate_url,omitempty"`
	NyscCertificatePublicID   *string `json:"nysc_certificate_public_id,omitempty"`
	StateOfOriginCertURL      *string `json:"state_of_origin_cert_url,omitempty"`
	StateOfOriginCertPublicID *string `json:"state_of_origin_cert_public_id,omitempty"`
	LgaCertificateURL         *string `json:"lga_certificate_url,omitempty"`
	LgaCertificatePublicID    *string `json:"lga_certificate_public_id,omitempty"`

	// Employment Documents
	ResumeURL           *string `json:"resume_url,omitempty"`
	ResumePublicID      *string `json:"resume_public_id,omitempty"`
	CoverLetterURL      *string `json:"cover_letter_url,omitempty"`
	CoverLetterPublicID *string `json:"cover_letter_public_id,omitempty"`

	// Next of Kin
	NextOfKinName         *string `json:"next_of_kin_name,omitempty"`
	NextOfKinRelationship *string `json:"next_of_kin_relationship,omitempty"`
	NextOfKinPhone        *string `json:"next_of_kin_phone,omitempty"`
	NextOfKinEmail        *string `json:"next_of_kin_email,omitempty"`
	NextOfKinHomeAddress  *string `json:"next_of_kin_home_address,omitempty"`
	NextOfKinWorkAddress  *string `json:"next_of_kin_work_address,omitempty"`

	// Guarantor 1
	Guarantor1Name         *string `json:"guarantor1_name,omitempty"`
	Guarantor1Phone        *string `json:"guarantor1_phone,omitempty"`
	Guarantor1Occupation   *string `json:"guarantor1_occupation,omitempty"`
	Guarantor1Relationship *string `json:"guarantor1_relationship,omitempty"`
	Guarantor1Address      *string `json:"guarantor1_address,omitempty"`
	Guarantor1Email        *string `json:"guarantor1_email,omitempty"`
	Guarantor1Passport     *string `json:"guarantor1_passport,omitempty"`
	Guarantor1NationalID   *string `json:"guarantor1_national_id,omitempty"`
	Guarantor1WorkID       *string `json:"guarantor1_work_id,omitempty"`

	// Guarantor 2
	Guarantor2Name         *string `json:"guarantor2_name,omitempty"`
	Guarantor2Phone        *string `json:"guarantor2_phone,omitempty"`
	Guarantor2Occupation   *string `json:"guarantor2_occupation,omitempty"`
	Guarantor2Relationship *string `json:"guarantor2_relationship,omitempty"`
	Guarantor2Address      *string `json:"guarantor2_address,omitempty"`
	Guarantor2Email        *string `json:"guarantor2_email,omitempty"`
	Guarantor2Passport     *string `json:"guarantor2_passport,omitempty"`
	Guarantor2NationalID   *string `json:"guarantor2_national_id,omitempty"`
	Guarantor2WorkID       *string `json:"guarantor2_work_id,omitempty"`

	// Work Experience
	WorkExperience []map[string]interface{} `json:"work_experience,omitempty"`

	// Role History (roles held at Ace Mall)
	RoleHistory []map[string]interface{} `json:"role_history,omitempty"`

	// Exam Scores
	ExamScores []map[string]interface{} `json:"exam_scores,omitempty"`

	// Status
	IsActive          bool       `json:"is_active"`
	IsTerminated      bool       `json:"is_terminated"`
	TerminationReason *string    `json:"termination_reason,omitempty"`
	TerminationDate   *time.Time `json:"termination_date,omitempty"`

	// Metadata
	CreatedBy *string    `json:"created_by,omitempty"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	LastLogin *time.Time `json:"last_login,omitempty"`
}

// CreateUserRequest represents the request body for creating a user
type CreateUserRequest struct {
	Email         string  `json:"email" binding:"required,email"`
	Password      string  `json:"password" binding:"required,min=6"`
	FullName      string  `json:"full_name" binding:"required"`
	Gender        *string `json:"gender"`
	DateOfBirth   *string `json:"date_of_birth"`
	MaritalStatus *string `json:"marital_status"`
	PhoneNumber   *string `json:"phone_number"`
	HomeAddress   *string `json:"home_address"`
	StateOfOrigin *string `json:"state_of_origin"`

	RoleID          string   `json:"role_id" binding:"required"`
	DepartmentID    *string  `json:"department_id"`
	SubDepartmentID *string  `json:"sub_department_id"`
	BranchID        *string  `json:"branch_id"`
	DateJoined      string   `json:"date_joined" binding:"required"`
	CurrentSalary   *float64 `json:"current_salary"`

	CourseOfStudy *string `json:"course_of_study"`
	Grade         *string `json:"grade"`
	Institution   *string `json:"institution"`
}

// LoginRequest represents login credentials
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse represents the response after successful login
type LoginResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

// Branch represents a mall branch
type Branch struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	Location  string    `json:"location"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Department represents a department
type Department struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description *string   `json:"description,omitempty"`
	IsActive    bool      `json:"is_active"`
	CreatedBy   *string   `json:"created_by,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// SubDepartment represents a sub-department
type SubDepartment struct {
	ID           string    `json:"id"`
	DepartmentID string    `json:"department_id"`
	Name         string    `json:"name"`
	Description  *string   `json:"description,omitempty"`
	IsActive     bool      `json:"is_active"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// Role represents a job role/position
type Role struct {
	ID                string    `json:"id"`
	Name              string    `json:"name"`
	Category          string    `json:"category"` // senior_admin, admin, general
	DepartmentID      *string   `json:"department_id,omitempty"`
	DepartmentName    *string   `json:"department_name,omitempty"`
	SubDepartmentID   *string   `json:"sub_department_id,omitempty"`
	SubDepartmentName *string   `json:"sub_department_name,omitempty"`
	Description       *string   `json:"description,omitempty"`
	IsActive          bool      `json:"is_active"`
	CreatedBy         *string   `json:"created_by,omitempty"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
}

// NextOfKin represents next of kin information
type NextOfKin struct {
	ID           string    `json:"id"`
	UserID       string    `json:"user_id"`
	FullName     string    `json:"full_name"`
	Relationship string    `json:"relationship"`
	Email        *string   `json:"email,omitempty"`
	PhoneNumber  string    `json:"phone_number"`
	HomeAddress  *string   `json:"home_address,omitempty"`
	WorkAddress  *string   `json:"work_address,omitempty"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// Guarantor represents guarantor information
type Guarantor struct {
	ID              string     `json:"id"`
	UserID          string     `json:"user_id"`
	GuarantorNumber int        `json:"guarantor_number"` // 1 or 2
	FullName        string     `json:"full_name"`
	PhoneNumber     string     `json:"phone_number"`
	Occupation      *string    `json:"occupation,omitempty"`
	Relationship    *string    `json:"relationship,omitempty"`
	Sex             *string    `json:"sex,omitempty"`
	Age             *int       `json:"age,omitempty"`
	HomeAddress     *string    `json:"home_address,omitempty"`
	Email           *string    `json:"email,omitempty"`
	DateOfBirth     *time.Time `json:"date_of_birth,omitempty"`
	GradeLevel      *string    `json:"grade_level,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}

// WorkExperience represents previous work experience
type WorkExperience struct {
	ID               string     `json:"id"`
	UserID           string     `json:"user_id"`
	CompanyName      string     `json:"company_name"`
	Position         string     `json:"position"`
	StartDate        time.Time  `json:"start_date"`
	EndDate          *time.Time `json:"end_date,omitempty"`
	Responsibilities *string    `json:"responsibilities,omitempty"`
	CreatedAt        time.Time  `json:"created_at"`
}

// RoleHistory represents role changes within the company
type RoleHistory struct {
	ID              string     `json:"id"`
	UserID          string     `json:"user_id"`
	RoleID          *string    `json:"role_id,omitempty"`
	RoleName        *string    `json:"role_name,omitempty"`
	DepartmentID    *string    `json:"department_id,omitempty"`
	DepartmentName  *string    `json:"department_name,omitempty"`
	BranchID        *string    `json:"branch_id,omitempty"`
	BranchName      *string    `json:"branch_name,omitempty"`
	StartDate       time.Time  `json:"start_date"`
	EndDate         *time.Time `json:"end_date,omitempty"`
	PromotionReason *string    `json:"promotion_reason,omitempty"`
	CreatedBy       *string    `json:"created_by,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
}

// ExamScore represents educational exam scores
type ExamScore struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	ExamType  string    `json:"exam_type"` // WAEC, NECO, JAMB, etc.
	Score     *string   `json:"score,omitempty"`
	YearTaken *int      `json:"year_taken,omitempty"`
	CreatedAt time.Time `json:"created_at"`
}
