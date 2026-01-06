package utils

import (
	"fmt"
	"log"
	"os"

	"github.com/sendgrid/sendgrid-go"
	"github.com/sendgrid/sendgrid-go/helpers/mail"
)

// SendEmail sends an email using SendGrid HTTP API
func SendEmail(to, subject, htmlBody string) error {
	sendGridAPIKey := os.Getenv("SENDGRID_API_KEY")
	fromEmail := os.Getenv("FROM_EMAIL")
	fromName := "Ace Supermarket"

	if sendGridAPIKey == "" {
		log.Printf("⚠️ SendGrid API key not configured. Logging email instead.\n")
		log.Printf("📧 TO: %s\n", to)
		log.Printf("📧 SUBJECT: %s\n", subject)
		log.Printf("📧 BODY:\n%s\n", htmlBody)
		return nil
	}

	if fromEmail == "" {
		fromEmail = "noreply@acesupermarket.com"
	}

	// Create SendGrid message
	from := mail.NewEmail(fromName, fromEmail)
	toEmail := mail.NewEmail("", to)
	message := mail.NewSingleEmail(from, subject, toEmail, "", htmlBody)

	// Send email via SendGrid API
	client := sendgrid.NewSendClient(sendGridAPIKey)
	response, err := client.Send(message)
	if err != nil {
		log.Printf("❌ Failed to send email to %s: %v\n", to, err)
		return err
	}

	if response.StatusCode >= 400 {
		log.Printf("❌ SendGrid API error for %s: Status %d - %s\n", to, response.StatusCode, response.Body)
		return fmt.Errorf("sendgrid API error: status %d", response.StatusCode)
	}

	log.Printf("✅ Email sent successfully to: %s (Status: %d)\n", to, response.StatusCode)
	return nil
}

// nolint:SA5009
const accountCreatedTemplate = `
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<style>
		body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background-color: #f4f4f4; margin: 0; padding: 0; }
		.container { max-width: 600px; margin: 20px auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
		.header { background: linear-gradient(135deg, #4CAF50 0%%, #2E7D32 100%%); color: white; padding: 40px 30px; text-align: center; }
		.header h1 { margin: 0; font-size: 28px; font-weight: 600; }
		.header p { margin: 10px 0 0 0; font-size: 14px; opacity: 0.9; }
		.content { padding: 40px 30px; }
		.greeting { font-size: 18px; color: #333; margin-bottom: 20px; }
		.info-box { background: linear-gradient(135deg, #f5f7fa 0%%, #c3cfe2 100%%); border-left: 4px solid #4CAF50; padding: 20px; margin: 25px 0; border-radius: 8px; }
		.info-box h3 { margin: 0 0 15px 0; color: #4CAF50; font-size: 16px; }
		.info-item { margin: 10px 0; }
		.info-label { font-weight: 600; color: #555; display: inline-block; width: 120px; }
		.info-value { color: #333; font-family: 'Courier New', monospace; background: white; padding: 4px 8px; border-radius: 4px; }
		.credentials-box { background: #fff3cd; border: 2px solid #ffc107; padding: 20px; margin: 25px 0; border-radius: 8px; }
		.credentials-box h3 { margin: 0 0 15px 0; color: #856404; font-size: 16px; }
		.password-note { background: #d1ecf1; border-left: 4px solid #0c5460; padding: 15px; margin: 20px 0; border-radius: 4px; color: #0c5460; }
		.footer { background: #f8f9fa; padding: 30px; text-align: center; color: #666; font-size: 13px; border-top: 1px solid #e9ecef; }
		.footer p { margin: 5px 0; }
		.icon { font-size: 24px; margin-right: 8px; }
	</style>
</head>
<body>
	<div class="container">
		<div class="header">
			<h1>🛒 ACE SUPERMARKET</h1>
			<p>Staff Management System</p>
		</div>
		<div class="content">
			<p class="greeting">Hello <strong>%s</strong>,</p>
			<p>Welcome to the Ace Supermarket family! 🎉</p>
			<p>An account has been created for you in our Staff Management Application. Below are your account details:</p>
			
			<div class="info-box">
				<h3>📋 Your Account Information</h3>
				<div class="info-item">
					<span class="info-label">Role:</span>
					<span class="info-value">%s</span>
				</div>
				<div class="info-item">
					<span class="info-label">Department:</span>
					<span class="info-value">%s</span>
				</div>
				%s
			</div>
			
			<div class="credentials-box">
				<h3>🔐 Login Credentials</h3>
				<div class="info-item">
					<span class="info-label">Username:</span>
					<span class="info-value">%s</span>
				</div>
				<div class="info-item">
					<span class="info-label">Password:</span>
					<span class="info-value">%s</span>
				</div>
			</div>
			
			<div class="password-note">
				<strong>🔒 Security Notice:</strong> For your security, please change your password immediately after your first login. You can update your password from your profile settings.
			</div>
			
			<p><strong>Next Steps:</strong></p>
			<ol>
				<li>Download the Ace Supermarket Staff App</li>
				<li>Sign in using the credentials above</li>
				<li>Change your password in Profile Settings</li>
				<li>Complete your profile information</li>
			</ol>
			
			<p>If you have any questions or need assistance, please contact your supervisor or the HR department.</p>
		</div>
		<div class="footer">
			<p><strong>Ace Supermarket Management Team</strong></p>
			<p>📧 support@acesupermarket.com</p>
			<p>© 2026 Ace Supermarket. All rights reserved.</p>
		</div>
	</div>
</body>
</html>
`

// SendAccountCreatedEmail sends welcome email to newly created staff
func SendAccountCreatedEmail(to, fullName, email, password, roleName, departmentName, branchName string) error {
	subject := "Welcome to Ace Supermarket - Your Account Has Been Created"

	// Build branch info HTML
	branchHTML := ""
	if branchName != "" {
		branchHTML = fmt.Sprintf(`<div class="info-item">
			<span class="info-label">Branch:</span>
			<span class="info-value">%s</span>
		</div>`, branchName)
	}

	body := fmt.Sprintf(accountCreatedTemplate, fullName, roleName, departmentName, branchHTML, email, password)
	return SendEmail(to, subject, body)
}

// nolint:SA5009
const passwordResetOTPTemplate = `
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<style>
		body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background-color: #f4f4f4; margin: 0; padding: 0; }
		.container { max-width: 600px; margin: 20px auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
		.header { background: linear-gradient(135deg, #4CAF50 0%%, #2E7D32 100%%); color: white; padding: 40px 30px; text-align: center; }
		.header h1 { margin: 0; font-size: 28px; font-weight: 600; }
		.content { padding: 40px 30px; }
		.otp-box { background: linear-gradient(135deg, #4CAF50 0%%, #2E7D32 100%%); color: white; padding: 30px; margin: 25px 0; border-radius: 8px; text-align: center; }
		.otp-code { font-size: 48px; font-weight: bold; letter-spacing: 8px; margin: 20px 0; font-family: 'Courier New', monospace; }
		.warning-box { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px; color: #856404; }
		.footer { background: #f8f9fa; padding: 30px; text-align: center; color: #666; font-size: 13px; border-top: 1px solid #e9ecef; }
	</style>
</head>
<body>
	<div class="container">
		<div class="header">
			<h1>🔐 Password Reset Request</h1>
		</div>
		<div class="content">
			<p>Hello <strong>%s</strong>,</p>
			<p>We received a request to reset your password for your Ace Supermarket staff account.</p>
			
			<div class="otp-box">
				<p style="margin: 0; font-size: 14px; opacity: 0.9;">Your verification code is:</p>
				<div class="otp-code">%s</div>
				<p style="margin: 0; font-size: 14px; opacity: 0.9;">⏰ Valid for 10 minutes</p>
			</div>
			
			<p><strong>How to reset your password:</strong></p>
			<ol>
				<li>Open the Ace Supermarket Staff App</li>
				<li>Enter this 6-digit code</li>
				<li>Create your new password</li>
			</ol>
			
			<div class="warning-box">
				<strong>⚠️ Security Alert:</strong> If you didn't request this password reset, please ignore this email and contact HR immediately.
			</div>
		</div>
		<div class="footer">
			<p><strong>Ace Supermarket Management Team</strong></p>
			<p>📧 support@acesupermarket.com</p>
			<p>© 2026 Ace Supermarket. All rights reserved.</p>
		</div>
	</div>
</body>
</html>
`

// SendPasswordResetOTP sends OTP for password reset
func SendPasswordResetOTP(to, fullName, otp string) error {
	// Always log OTP for debugging
	log.Printf("🔐 PASSWORD RESET OTP for %s: %s", to, otp)
	log.Printf("📧 Full Name: %s", fullName)

	subject := "Password Reset Code - Ace Supermarket"
	body := fmt.Sprintf(passwordResetOTPTemplate, fullName, otp)
	return SendEmail(to, subject, body)
}

// nolint:SA5009
const adminNotificationTemplate = `
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<style>
		body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background-color: #f4f4f4; margin: 0; padding: 0; }
		.container { max-width: 600px; margin: 20px auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
		.header { background: linear-gradient(135deg, #4CAF50 0%%, #2E7D32 100%%); color: white; padding: 40px 30px; text-align: center; }
		.header h1 { margin: 0; font-size: 28px; font-weight: 600; }
		.content { padding: 40px 30px; }
		.message-box { background: #f8f9fa; border-left: 4px solid #4CAF50; padding: 20px; margin: 25px 0; border-radius: 8px; }
		.from-box { background: #e7f3ff; padding: 15px; margin: 20px 0; border-radius: 8px; }
		.footer { background: #f8f9fa; padding: 30px; text-align: center; color: #666; font-size: 13px; border-top: 1px solid #e9ecef; }
	</style>
</head>
<body>
	<div class="container">
		<div class="header">
			<h1>📢 Important Notification</h1>
		</div>
		<div class="content">
			<p>Hello <strong>%s</strong>,</p>
			<p>You have received an important message from the management team:</p>
			
			<div class="from-box">
				<strong>From:</strong> %s (%s)
			</div>
			
			<div class="message-box">
				<h3 style="margin-top: 0; color: #4CAF50;">%s</h3>
				<p style="white-space: pre-wrap;">%s</p>
			</div>
			
			<p>Please check your Ace Supermarket Staff App for more details.</p>
		</div>
		<div class="footer">
			<p><strong>Ace Supermarket Management Team</strong></p>
			<p>📧 support@acesupermarket.com</p>
			<p>© 2026 Ace Supermarket. All rights reserved.</p>
		</div>
	</div>
</body>
</html>
`

// SendAdminNotification sends notification email from admin to staff
func SendAdminNotification(to, recipientName, senderName, senderRole, title, message string) error {
	subject := "Important Notification - " + title
	body := fmt.Sprintf(adminNotificationTemplate, recipientName, senderName, senderRole, title, message)
	return SendEmail(to, subject, body)
}
