package utils

import (
	"log"
	"os"
)

var (
	// ProductionMode controls logging verbosity
	ProductionMode = os.Getenv("PRODUCTION") == "true"
)

// LogInfo logs informational messages (disabled in production)
func LogInfo(format string, v ...interface{}) {
	if !ProductionMode {
		log.Printf("ℹ️  "+format, v...)
	}
}

// LogSuccess logs success messages (disabled in production)
func LogSuccess(format string, v ...interface{}) {
	if !ProductionMode {
		log.Printf("✅ "+format, v...)
	}
}

// LogWarning logs warning messages (always logged)
func LogWarning(format string, v ...interface{}) {
	log.Printf("⚠️  "+format, v...)
}

// LogError logs error messages (always logged)
func LogError(format string, v ...interface{}) {
	log.Printf("❌ "+format, v...)
}

// LogDebug logs debug messages (disabled in production)
func LogDebug(format string, v ...interface{}) {
	if !ProductionMode {
		log.Printf("🔍 "+format, v...)
	}
}
