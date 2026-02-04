package utils

import (
	"time"
)

// CalculateAge calculates age from date of birth
func CalculateAge(dob time.Time) int {
	now := time.Now()
	age := now.Year() - dob.Year()

	// Adjust if birthday hasn't occurred this year yet
	if now.Month() < dob.Month() || (now.Month() == dob.Month() && now.Day() < dob.Day()) {
		age--
	}

	return age
}

// CalculateAgeFromString calculates age from DOB string (YYYY-MM-DD format)
func CalculateAgeFromString(dobStr string) (int, error) {
	dob, err := time.Parse("2006-01-02", dobStr)
	if err != nil {
		return 0, err
	}
	return CalculateAge(dob), nil
}

// ValidateAgeMatchesDOB validates that provided age matches calculated age from DOB
func ValidateAgeMatchesDOB(dobStr string, providedAge int) bool {
	calculatedAge, err := CalculateAgeFromString(dobStr)
	if err != nil {
		return false
	}
	return calculatedAge == providedAge
}
