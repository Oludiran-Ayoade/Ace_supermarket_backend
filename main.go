package main

import (
	"ace-mall-backend/config"
	"ace-mall-backend/handlers"
	"ace-mall-backend/middleware"
	"ace-mall-backend/monitoring"
	"ace-mall-backend/scheduler"
	"ace-mall-backend/utils"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Connect to database
	if err := config.ConnectDatabase(); err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer config.CloseDatabase()

	// Initialize Redis
	if err := config.InitRedis(); err != nil {
		log.Println("⚠️  Warning: Redis initialization failed:", err)
		log.Println("Caching will not be available - app will run without cache")
	} else {
		log.Println("✅ Redis initialized successfully")
	}

	// Initialize Cloudinary
	if err := utils.InitCloudinary(); err != nil {
		log.Println("Warning: Cloudinary initialization failed:", err)
		log.Println("Image upload features will not be available")
	} else {
		log.Println("✓ Cloudinary initialized successfully")
	}

	// Initialize Firebase for push notifications
	if err := utils.InitFirebase(); err != nil {
		log.Println("⚠️ Warning: Firebase initialization failed:", err)
		log.Println("Push notifications will not be available")
	}

	// Start shift notification scheduler (30-minute reminders)
	shiftScheduler := scheduler.NewShiftNotificationScheduler(config.DB)
	shiftScheduler.Start()
	defer shiftScheduler.Stop()

	// Set Gin mode
	ginMode := os.Getenv("GIN_MODE")
	if ginMode == "" {
		ginMode = "debug"
	}
	gin.SetMode(ginMode)

	// Create router
	router := gin.Default()

	// Database middleware - inject DB into context
	router.Use(func(c *gin.Context) {
		c.Set("db", config.DB)
		c.Next()
	})

	// Monitoring middleware (must be early in chain)
	router.Use(monitoring.MetricsMiddleware())

	// Cache invalidation middleware (must be before routes)
	router.Use(middleware.CacheInvalidationMiddleware())

	// CORS middleware
	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE, PATCH")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Public routes (no authentication required)
		auth := v1.Group("/auth")
		{
			auth.POST("/login", handlers.Login)
			auth.POST("/forgot-password", handlers.ForgotPassword)
			auth.POST("/verify-reset-otp", handlers.VerifyResetOTP)
			auth.POST("/reset-password", handlers.ResetPassword)
		}

		// Data routes (public for now, can be protected later)
		data := v1.Group("/data")
		{
			data.GET("/branches", handlers.GetBranches)
			data.GET("/departments", handlers.GetDepartments)
			data.GET("/departments/:department_id/sub-departments", handlers.GetSubDepartments)
			data.GET("/roles", handlers.GetRoles)
			data.GET("/roles/category/:category", handlers.GetRolesByCategory)
		}

		// Cloudinary config (public endpoint for frontend)
		v1.GET("/cloudinary/config", handlers.GetCloudinaryConfig)

		// Protected routes (require authentication)
		protected := v1.Group("")
		protected.Use(middleware.AuthMiddleware())
		{
			// Auth routes (authenticated users)
			protected.GET("/auth/me", handlers.GetCurrentUser)
			protected.POST("/auth/change-password", handlers.ChangePassword)
			protected.PUT("/auth/update-email", handlers.UpdateEmail)

			// Upload routes (authenticated users)
			protected.POST("/upload/image", handlers.UploadImage)
			protected.POST("/upload/document", handlers.UploadDocument)
			protected.DELETE("/upload/image", handlers.DeleteImage)

			// Profile routes (all authenticated users)
			protected.GET("/profile", handlers.GetProfile)                   // Get own profile
			protected.GET("/profile/:user_id", handlers.GetProfile)          // Get another user's profile
			protected.PUT("/profile/picture", handlers.UpdateProfilePicture) // Update own profile picture

			// Document management (HR only)
			protected.PUT("/profile/:user_id/document", handlers.UpdateDocument)
			protected.DELETE("/profile/:user_id/document", handlers.DeleteDocument)
			protected.GET("/profile/:user_id/document-logs", handlers.GetDocumentAccessLogs)

			// Roster routes (Floor Managers)
			protected.POST("/roster", handlers.CreateRoster)
			protected.GET("/roster/week", handlers.GetRosterForWeek)
			protected.GET("/roster/by-branch-department", handlers.GetRostersByBranchDepartment) // HR/CEO view rosters
			protected.GET("/roster/my-team", handlers.GetMyTeam)
			protected.GET("/roster/my-assignments", handlers.GetMyAssignments) // Staff schedule

			// Shift templates routes (Floor Managers)
			protected.GET("/shifts/templates", handlers.GetShiftTemplates)
			protected.PUT("/shifts/templates/:id", handlers.UpdateShiftTemplate)
			protected.GET("/shifts/available", handlers.GetAvailableShifts)

			// Review routes (with caching)
			reviewCache := middleware.CacheMiddleware(30 * time.Minute)
			protected.POST("/reviews", handlers.CreateReview)                                     // Floor Manager creates review
			protected.GET("/reviews/my-reviews", reviewCache, handlers.GetMyReviews)              // Staff gets their reviews
			protected.GET("/reviews/staff/:staff_id", reviewCache, handlers.GetStaffReviews)      // Get reviews for specific staff
			protected.GET("/reviews/manager", reviewCache, handlers.GetStaffReviewsForManager)    // Floor Manager gets reviews they created
			protected.GET("/hr/reviews", reviewCache, handlers.GetAllStaffReviews)                // HR/CEO gets all staff reviews
			protected.GET("/reviews/by-department", reviewCache, handlers.GetRatingsByDepartment) // Get ratings by branch/department

			// Legacy review route (for backward compatibility)
			protected.POST("/review", handlers.CreateWeeklyReview)

			// Promotion routes
			protected.POST("/promotions", handlers.PromoteStaff)                         // HR/CEO promotes staff
			protected.GET("/promotions/history/:staff_id", handlers.GetPromotionHistory) // Get promotion history for staff
			protected.DELETE("/promotions/:promotion_id", handlers.DeletePromotion)      // HR/CEO can delete promotion records

			// Notifications routes (with caching)
			notifCache := middleware.CacheMiddleware(5 * time.Minute)
			protected.GET("/notifications", notifCache, handlers.GetUserNotifications)
			protected.GET("/notifications/my", notifCache, handlers.GetMyNotifications)
			protected.GET("/notifications/unread-count", notifCache, handlers.GetUnreadCount)
			protected.PUT("/notifications/:id/read", handlers.MarkNotificationAsRead)
			protected.PUT("/notifications/mark-all-read", handlers.MarkAllNotificationsAsRead)
			protected.POST("/notifications", handlers.CreateNotification)
			protected.DELETE("/notifications/:id", handlers.DeleteNotification)

			// Device token routes (for push notifications)
			protected.POST("/device-tokens/register", handlers.RegisterDeviceToken)
			protected.POST("/device-tokens/unregister", handlers.UnregisterDeviceToken)
			protected.POST("/device-tokens/test", handlers.TestPushNotification)

			// Messages routes (admin only)
			protected.POST("/messages/send", handlers.SendMessage)
			protected.GET("/messages/sent", handlers.GetSentMessages)
			protected.POST("/messages/cleanup", handlers.CleanupExpiredNotifications)

			// Schedule routes (with caching)
			scheduleCache := middleware.CacheMiddleware(15 * time.Minute)
			protected.GET("/schedule/upcoming", scheduleCache, handlers.GetMyUpcomingShifts)

			// Dashboard routes (with caching)
			dashboardCache := middleware.CacheMiddleware(10 * time.Minute)
			protected.GET("/dashboard/stats", dashboardCache, handlers.GetDashboardStats)

			// Floor Manager routes (staff creation)
			protected.POST("/floor-manager/create-staff", handlers.CreateStaffByFloorManager)

			// HR routes (require senior_admin or admin role for oversight)
			hr := protected.Group("/hr")
			hr.Use(middleware.RequireRole("senior_admin", "admin"))
			{
				hr.GET("/staff", handlers.GetAllStaff)
				hr.GET("/stats", handlers.GetStaffStats)
				hr.GET("/promotions", handlers.GetAllPromotions)                                   // Get all promotion history
				hr.GET("/terminated-staff", handlers.GetDepartedStaff)                             // Get terminated/departed staff
				hr.GET("/staff-report", handlers.GetStaffReport)                                   // Get staff report with filters
				hr.POST("/staff", handlers.CreateStaffByHR)                                        // HR can create any type of staff
				hr.POST("/staff/bulk-upload", handlers.BulkUploadStaff)                            // Bulk upload staff via CSV
				hr.POST("/documents/bulk-upload", handlers.BulkUploadDocuments)                    // Bulk upload staff documents
				hr.POST("/documents/guarantor-bulk-upload", handlers.BulkUploadGuarantorDocuments) // Bulk upload guarantor documents
			}

			// Branch Manager routes (require admin or senior_admin role)
			branch := protected.Group("/branch")
			branch.Use(middleware.RequireRole("admin", "senior_admin"))
			{
				branch.GET("/stats", handlers.GetBranchStats)
				branch.GET("/staff", func(c *gin.Context) {
					c.Set("is_branch_endpoint", true)
					handlers.GetAllStaff(c)
				})
			}

			// Staff Profile routes
			protected.GET("/staff/:user_id", handlers.GetProfile)
			protected.PUT("/staff/:user_id", handlers.UpdateStaffProfile)                     // HR only
			protected.PUT("/staff/:user_id/work-experience", handlers.UpdateWorkExperience)   // Update work experience
			protected.PUT("/staff/:user_id/role-history", handlers.UpdateRoleHistory)         // Update Ace role history
			protected.POST("/staff/:user_id/guarantor-document", handlers.UploadGuarantorDoc) // Upload guarantor document

			// Staff Termination routes (HR/COO/CEO only)
			staffTermination := protected.Group("/staff")
			staffTermination.Use(middleware.RequireRole("senior_admin")) // Only senior_admin (HR/CEO/COO)
			{
				staffTermination.POST("/:user_id/terminate", handlers.TerminateStaff)
				staffTermination.POST("/:user_id/restore", handlers.RestoreStaff)
				staffTermination.GET("/departed", handlers.GetDepartedStaff)
			}

			// DANGER ZONE: Cleanup endpoint (use once before production)
			protected.POST("/cleanup/all-staff", middleware.RequireRole("senior_admin"), handlers.CleanupAllStaffData)
		}
	}

	// Public setup endpoint - create master HR (no auth required for initial setup)
	router.POST("/api/v1/setup/master-hr", handlers.CreateMasterHR)

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "Ace Mall Staff Management API is running",
		})
	})

	// Monitoring endpoints
	router.GET("/api/v1/metrics", handlers.GetMetrics)
	router.GET("/api/v1/alerts", handlers.GetAlerts)
	router.GET("/api/v1/health/status", handlers.GetHealthStatus)
	router.GET("/api/v1/cache/stats", middleware.GetCacheStats)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Server starting on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
