# SendGrid Email Integration Setup

This application uses SendGrid HTTP API for sending emails (password reset OTPs, account creation notifications, etc.).

## Why SendGrid?

- ✅ **Works on Render**: Uses HTTP API instead of SMTP (Render blocks SMTP ports)
- ✅ **Free Tier**: 100 emails/day forever
- ✅ **Reliable**: Industry-standard email delivery service
- ✅ **Fast**: No SMTP timeouts or connection issues

## Setup Instructions

### 1. Create SendGrid Account

1. Go to https://signup.sendgrid.com/
2. Sign up for a free account
3. Verify your email address

### 2. Get API Key

1. Log in to SendGrid dashboard
2. Go to **Settings** → **API Keys**
3. Click **Create API Key**
4. Name it: `Ace Supermarket Backend`
5. Select **Full Access** or **Mail Send** permission
6. Click **Create & View**
7. **Copy the API key** (you won't see it again!)

### 3. Verify Sender Email (Important!)

SendGrid requires sender verification:

**Option A: Single Sender Verification (Recommended for testing)**
1. Go to **Settings** → **Sender Authentication**
2. Click **Verify a Single Sender**
3. Enter your email (e.g., `your-email@gmail.com`)
4. Fill in the form and submit
5. Check your email and click verification link

**Option B: Domain Authentication (For production)**
1. Go to **Settings** → **Sender Authentication**
2. Click **Authenticate Your Domain**
3. Follow DNS setup instructions for your domain

### 4. Configure Environment Variables

Add these to your environment:

```bash
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
FROM_EMAIL=your-verified-email@gmail.com
```

**For Render:**
1. Go to your service dashboard
2. Click **Environment** tab
3. Add the variables above
4. Click **Save Changes**
5. Service will auto-deploy

**For Local Development:**
Add to your `.env` file:
```
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
FROM_EMAIL=your-verified-email@gmail.com
```

### 5. Test Email Sending

After deployment, test the forgot password flow:

1. Enter a valid email in the app
2. Click "Send Reset Code"
3. Check the email inbox for OTP code
4. OTP will also be logged in Render logs for debugging

## Email Templates

The application sends these types of emails:

1. **Password Reset OTP** - 6-digit code for password reset
2. **Account Created** - Welcome email with login credentials
3. **Admin Notifications** - Important messages from management

All emails use beautiful HTML templates with Ace Supermarket branding.

## Troubleshooting

### "SendGrid API key not configured"
- Check that `SENDGRID_API_KEY` is set in environment variables
- Restart the service after adding the variable

### "Sender email not verified"
- Go to SendGrid → Settings → Sender Authentication
- Verify your sender email address
- Use the verified email in `FROM_EMAIL` variable

### Emails not arriving
- Check spam/junk folder
- Verify sender email is authenticated in SendGrid
- Check Render logs for SendGrid API errors
- Ensure you're within the 100 emails/day free tier limit

## Free Tier Limits

- **100 emails/day** forever
- **2,000 contacts**
- Single sender verification
- Email activity for 30 days

For higher volume, upgrade to paid plans starting at $19.95/month.

## Support

- SendGrid Docs: https://docs.sendgrid.com/
- SendGrid Support: https://support.sendgrid.com/
