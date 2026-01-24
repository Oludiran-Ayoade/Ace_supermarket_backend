package handlers

import (
	"ace-mall-backend/utils"
	"database/sql"
	"fmt"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
)

// BulkUploadDocuments handles bulk upload of staff documents to Cloudinary
// Expects multipart form with:
// - staff_id: UUID of staff member
// - document_type: Type of document (passport, birth_certificate, etc.)
// - files: Multiple document files
func BulkUploadDocuments(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Parse multipart form (max 100MB for bulk documents)
	if err := c.Request.ParseMultipartForm(100 << 20); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to parse form data"})
		return
	}

	form := c.Request.MultipartForm
	files := form.File["documents"]

	if len(files) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No documents provided"})
		return
	}

	var successCount, errorCount int
	var errors []map[string]interface{}
	results := []map[string]interface{}{}

	// Process each file
	for _, fileHeader := range files {
		// Expected filename format: {staff_id}_{document_type}.{ext}
		// Example: abc123_passport.jpg, def456_birth_certificate.pdf
		filename := fileHeader.Filename
		parts := strings.Split(strings.TrimSuffix(filename, filepath.Ext(filename)), "_")

		if len(parts) < 2 {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": "Invalid filename format. Expected: {staff_id}_{document_type}.{ext}",
			})
			continue
		}

		staffID := parts[0]
		documentType := strings.Join(parts[1:], "_") // Rejoin in case document type has underscores

		// Verify staff exists
		var staffName string
		err := db.QueryRow("SELECT full_name FROM users WHERE id = $1", staffID).Scan(&staffName)
		if err == sql.ErrNoRows {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":     filename,
				"staff_id": staffID,
				"error":    "Staff member not found",
			})
			continue
		}

		// Open file
		file, err := fileHeader.Open()
		if err != nil {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": "Failed to open file",
			})
			continue
		}
		defer file.Close()

		// Upload to Cloudinary
		folder := fmt.Sprintf("staff_documents/%s", staffID)
		secureURL, publicID, err := utils.UploadDocument(file, filename, folder)
		if err != nil {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": fmt.Sprintf("Failed to upload to Cloudinary: %v", err),
			})
			continue
		}

		// Map document type to database column
		urlColumn, publicIDColumn := getDocumentColumns(documentType)
		if urlColumn == "" {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":          filename,
				"document_type": documentType,
				"error":         "Invalid document type",
			})
			continue
		}

		// Update database with Cloudinary URL
		query := fmt.Sprintf(`
			UPDATE users 
			SET %s = $1, %s = $2, updated_at = CURRENT_TIMESTAMP 
			WHERE id = $3
		`, urlColumn, publicIDColumn)

		_, err = db.Exec(query, secureURL, publicID, staffID)
		if err != nil {
			// Rollback: Delete from Cloudinary if DB update fails
			_ = utils.DeleteImage(publicID)
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": fmt.Sprintf("Failed to update database: %v", err),
			})
			continue
		}

		// Log document access
		_, _ = db.Exec(`
			INSERT INTO document_access_logs (user_id, accessed_by, document_type, action)
			VALUES ($1, $2, $3, 'upload')
		`, staffID, c.GetString("user_id"), documentType)

		successCount++
		results = append(results, map[string]interface{}{
			"file":          filename,
			"staff_id":      staffID,
			"staff_name":    staffName,
			"document_type": documentType,
			"url":           secureURL,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"message":       "Bulk document upload completed",
		"success_count": successCount,
		"error_count":   errorCount,
		"results":       results,
		"errors":        errors,
	})
}

// getDocumentColumns maps document type to database column names
func getDocumentColumns(docType string) (urlColumn, publicIDColumn string) {
	columnMap := map[string][2]string{
		"passport":             {"passport_url", "passport_public_id"},
		"national_id":          {"national_id_url", "national_id_public_id"},
		"birth_certificate":    {"birth_certificate_url", "birth_certificate_public_id"},
		"waec_certificate":     {"waec_certificate_url", "waec_certificate_public_id"},
		"neco_certificate":     {"neco_certificate_url", "neco_certificate_public_id"},
		"jamb_result":          {"jamb_result_url", "jamb_result_public_id"},
		"degree_certificate":   {"degree_certificate_url", "degree_certificate_public_id"},
		"diploma_certificate":  {"diploma_certificate_url", "diploma_certificate_public_id"},
		"nysc_certificate":     {"nysc_certificate_url", "nysc_certificate_public_id"},
		"state_of_origin_cert": {"state_of_origin_cert_url", "state_of_origin_cert_public_id"},
		"lga_certificate":      {"lga_certificate_url", "lga_certificate_public_id"},
		"drivers_license":      {"drivers_license_url", "drivers_license_public_id"},
		"voters_card":          {"voters_card_url", "voters_card_public_id"},
		"resume":               {"resume_url", "resume_public_id"},
		"cover_letter":         {"cover_letter_url", "cover_letter_public_id"},
	}

	if cols, exists := columnMap[docType]; exists {
		return cols[0], cols[1]
	}
	return "", ""
}

// BulkUploadGuarantorDocuments handles bulk upload of guarantor documents
func BulkUploadGuarantorDocuments(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	if err := c.Request.ParseMultipartForm(100 << 20); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to parse form data"})
		return
	}

	form := c.Request.MultipartForm
	files := form.File["documents"]

	if len(files) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No documents provided"})
		return
	}

	var successCount, errorCount int
	var errors []map[string]interface{}
	results := []map[string]interface{}{}

	for _, fileHeader := range files {
		// Expected filename: {staff_id}_g{1|2}_{passport|national_id|work_id}.{ext}
		// Example: abc123_g1_passport.jpg, def456_g2_national_id.pdf
		filename := fileHeader.Filename
		parts := strings.Split(strings.TrimSuffix(filename, filepath.Ext(filename)), "_")

		if len(parts) < 3 {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": "Invalid filename format. Expected: {staff_id}_g{1|2}_{document_type}.{ext}",
			})
			continue
		}

		staffID := parts[0]
		guarantorNum := parts[1] // g1 or g2
		documentType := strings.Join(parts[2:], "_")

		if guarantorNum != "g1" && guarantorNum != "g2" {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": "Invalid guarantor number. Use g1 or g2",
			})
			continue
		}

		guarantorNumber := 1
		if guarantorNum == "g2" {
			guarantorNumber = 2
		}

		// Get guarantor ID
		var guarantorID string
		err := db.QueryRow(`
			SELECT id FROM guarantors 
			WHERE user_id = $1 AND guarantor_number = $2
		`, staffID, guarantorNumber).Scan(&guarantorID)

		if err == sql.ErrNoRows {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": fmt.Sprintf("Guarantor %d not found for staff %s", guarantorNumber, staffID),
			})
			continue
		}

		// Open file
		file, err := fileHeader.Open()
		if err != nil {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": "Failed to open file",
			})
			continue
		}
		defer file.Close()

		// Upload to Cloudinary
		folder := fmt.Sprintf("guarantor_documents/%s", guarantorID)
		secureURL, publicID, err := utils.UploadDocument(file, fileHeader.Filename, folder)
		if err != nil {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": fmt.Sprintf("Failed to upload to Cloudinary: %v", err),
			})
			continue
		}

		// Delete old document if exists
		var oldPublicID sql.NullString
		_ = db.QueryRow(`
			SELECT file_path FROM guarantor_documents 
			WHERE guarantor_id = $1 AND document_type = $2
		`, guarantorID, documentType).Scan(&oldPublicID)

		if oldPublicID.Valid && oldPublicID.String != "" {
			_ = utils.DeleteImage(oldPublicID.String)
		}

		// Insert/Update guarantor document
		_, err = db.Exec(`
			INSERT INTO guarantor_documents (guarantor_id, document_type, file_name, file_path)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (guarantor_id, document_type) 
			DO UPDATE SET file_name = $3, file_path = $4, updated_at = CURRENT_TIMESTAMP
		`, guarantorID, documentType, fileHeader.Filename, publicID)

		if err != nil {
			_ = utils.DeleteImage(publicID)
			errorCount++
			errors = append(errors, map[string]interface{}{
				"file":  filename,
				"error": fmt.Sprintf("Failed to update database: %v", err),
			})
			continue
		}

		successCount++
		results = append(results, map[string]interface{}{
			"file":          filename,
			"staff_id":      staffID,
			"guarantor":     guarantorNum,
			"document_type": documentType,
			"url":           secureURL,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"message":       "Bulk guarantor document upload completed",
		"success_count": successCount,
		"error_count":   errorCount,
		"results":       results,
		"errors":        errors,
	})
}
