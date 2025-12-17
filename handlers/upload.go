package handlers

import (
	"ace-mall-backend/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

// UploadImage handles image upload to Cloudinary
func UploadImage(c *gin.Context) {
	// Get the file from the request
	file, header, err := c.Request.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}
	defer file.Close()

	// Get optional folder parameter
	folder := c.DefaultPostForm("folder", "staff_images")

	// Upload to Cloudinary
	imageURL, err := utils.UploadImage(file, header.Filename, folder)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload image: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Image uploaded successfully",
		"url":     imageURL,
	})
}

// UploadDocument handles document/file upload to Cloudinary (PDFs, DOCs, etc.)
func UploadDocument(c *gin.Context) {
	// Get the file from the request
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}
	defer file.Close()

	// Get optional folder parameter
	folder := c.DefaultPostForm("folder", "documents")

	// Upload to Cloudinary as raw file
	fileURL, publicID, err := utils.UploadDocument(file, header.Filename, folder)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload document: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":           "Document uploaded successfully",
		"url":               fileURL,
		"public_id":         publicID,
		"original_filename": header.Filename,
	})
}

// GetCloudinaryConfig returns Cloudinary configuration for frontend
func GetCloudinaryConfig(c *gin.Context) {
	config := utils.GetCloudinaryConfig()
	c.JSON(http.StatusOK, config)
}

// DeleteImage handles image deletion from Cloudinary
func DeleteImage(c *gin.Context) {
	var req struct {
		PublicID string `json:"public_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Public ID is required"})
		return
	}

	// Delete from Cloudinary
	if err := utils.DeleteImage(req.PublicID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete image: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Image deleted successfully",
	})
}
