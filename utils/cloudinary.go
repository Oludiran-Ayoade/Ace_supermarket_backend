package utils

import (
	"context"
	"fmt"
	"math/rand"
	"mime/multipart"
	"os"
	"path/filepath"
	"time"

	"github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
)

var cld *cloudinary.Cloudinary

// InitCloudinary initializes the Cloudinary client
func InitCloudinary() error {
	cloudName := os.Getenv("CLOUDINARY_CLOUD_NAME")
	apiKey := os.Getenv("CLOUDINARY_API_KEY")
	apiSecret := os.Getenv("CLOUDINARY_API_SECRET")

	if cloudName == "" || apiKey == "" || apiSecret == "" {
		return fmt.Errorf("cloudinary credentials not set in environment variables")
	}

	var err error
	cld, err = cloudinary.NewFromParams(cloudName, apiKey, apiSecret)
	if err != nil {
		return fmt.Errorf("failed to initialize cloudinary: %w", err)
	}

	return nil
}

// UploadImage uploads an image to Cloudinary
func UploadImage(file multipart.File, filename string, folder string) (string, error) {
	if cld == nil {
		return "", fmt.Errorf("cloudinary not initialized")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Generate a unique filename
	ext := filepath.Ext(filename)
	uniqueFilename := fmt.Sprintf("%d_%s%s", time.Now().Unix(), generateRandomString(8), ext)

	// Upload parameters
	uploadParams := uploader.UploadParams{
		PublicID:       uniqueFilename,
		Folder:         folder,
		ResourceType:   "image",
		Transformation: "q_auto,f_auto",
	}

	// Upload the file
	result, err := cld.Upload.Upload(ctx, file, uploadParams)
	if err != nil {
		return "", fmt.Errorf("failed to upload to cloudinary: %w", err)
	}

	return result.SecureURL, nil
}

// UploadDocument uploads a document/file to Cloudinary (PDFs, DOCs, etc.)
func UploadDocument(file multipart.File, filename string, folder string) (string, string, error) {
	if cld == nil {
		return "", "", fmt.Errorf("cloudinary not initialized")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second) // Longer timeout for documents
	defer cancel()

	// Generate a unique filename
	ext := filepath.Ext(filename)
	uniqueFilename := fmt.Sprintf("%d_%s%s", time.Now().Unix(), generateRandomString(8), ext)

	// Upload parameters for raw files (documents)
	uploadParams := uploader.UploadParams{
		PublicID:     uniqueFilename,
		Folder:       folder,
		ResourceType: "raw", // Use "raw" for non-image files
	}

	// Upload the file
	result, err := cld.Upload.Upload(ctx, file, uploadParams)
	if err != nil {
		return "", "", fmt.Errorf("failed to upload document to cloudinary: %w", err)
	}

	return result.SecureURL, result.PublicID, nil
}

// DeleteImage deletes an image from Cloudinary
func DeleteImage(publicID string) error {
	if cld == nil {
		return fmt.Errorf("cloudinary not initialized")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := cld.Upload.Destroy(ctx, uploader.DestroyParams{
		PublicID: publicID,
	})

	if err != nil {
		return fmt.Errorf("failed to delete from cloudinary: %w", err)
	}

	return nil
}

// GetCloudinaryConfig returns the Cloudinary configuration for frontend
func GetCloudinaryConfig() map[string]string {
	return map[string]string{
		"cloud_name":    os.Getenv("CLOUDINARY_CLOUD_NAME"),
		"upload_preset": os.Getenv("CLOUDINARY_UPLOAD_PRESET"),
	}
}

// generateRandomString generates a random string of specified length
func generateRandomString(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	seededRand := rand.New(rand.NewSource(time.Now().UnixNano()))
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[seededRand.Intn(len(charset))]
	}
	return string(b)
}
