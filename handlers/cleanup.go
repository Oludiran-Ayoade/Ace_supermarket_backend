package handlers

import (
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
)

// CleanupAllStaffData removes all dummy staff data - USE WITH CAUTION
// This should only be called once before production launch
func CleanupAllStaffData(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Start transaction
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	deletedCounts := make(map[string]int64)

	// 1. Delete guarantor documents
	result, _ := tx.Exec("DELETE FROM guarantor_documents")
	count, _ := result.RowsAffected()
	deletedCounts["guarantor_documents"] = count

	// 2. Delete guarantors
	result, _ = tx.Exec("DELETE FROM guarantors")
	count, _ = result.RowsAffected()
	deletedCounts["guarantors"] = count

	// 3. Delete next of kin
	result, _ = tx.Exec("DELETE FROM next_of_kin WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["next_of_kin"] = count

	// 4. Delete work experience
	result, _ = tx.Exec("DELETE FROM work_experience WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["work_experience"] = count

	// 5. Delete qualifications
	result, _ = tx.Exec("DELETE FROM qualifications WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["qualifications"] = count

	// 6. Delete reviews
	result, _ = tx.Exec("DELETE FROM reviews")
	count, _ = result.RowsAffected()
	deletedCounts["reviews"] = count

	// 7. Delete roster assignments
	result, _ = tx.Exec("DELETE FROM roster_assignments WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["roster_assignments"] = count

	// 8. Delete rosters
	result, _ = tx.Exec("DELETE FROM rosters WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["rosters"] = count

	// 9. Delete shift templates
	result, _ = tx.Exec("DELETE FROM shift_templates WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["shift_templates"] = count

	// 10. Delete notifications
	result, _ = tx.Exec("DELETE FROM notifications WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["notifications"] = count

	// 11. Delete device tokens
	result, _ = tx.Exec("DELETE FROM device_tokens WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["device_tokens"] = count

	// 12. Delete document access logs
	result, _ = tx.Exec("DELETE FROM document_access_logs WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["document_access_logs"] = count

	// 13. Delete promotion history
	result, _ = tx.Exec("DELETE FROM promotion_history WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["promotion_history"] = count

	// 14. Delete terminated staff
	result, _ = tx.Exec("DELETE FROM terminated_staff WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["terminated_staff"] = count

	// 15. Delete all users EXCEPT master HR account
	result, _ = tx.Exec("DELETE FROM users WHERE email != 'hr@acesupermarket.com'")
	count, _ = result.RowsAffected()
	deletedCounts["users"] = count

	// 16. Delete temporary signups
	result, _ = tx.Exec("DELETE FROM temp_signups WHERE 1=1")
	count, _ = result.RowsAffected()
	deletedCounts["temp_signups"] = count

	// Commit transaction
	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit cleanup"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "✅ All staff data cleaned successfully",
		"deleted": deletedCounts,
	})
}
