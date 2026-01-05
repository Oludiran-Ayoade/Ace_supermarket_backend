# SendGrid Email Integration Setup

This guide will help you set up SendGrid for sending password reset emails in your Ace Supermarket backend.

## Why SendGrid?

- ✅ **Free Tier**: 100 emails/day forever
- ✅ **No SMTP Blocking**: Works perfectly on Render and other hosting platforms
- ✅ **Fast Delivery**: Emails sent via API, not SMTP
- ✅ **Easy Setup**: Just 3 environment variables needed
- ✅ **Reliable**: Industry-standard email service used by millions

---

## Step 1: Create SendGrid Account

1. **Go to SendGrid**: https://signup.sendgrid.com/
2. **Sign up** with your email (free account)
3. **Verify your email** address
4. **Complete the onboarding** questionnaire

---

## Step 2: Create API Key

1. **Login to SendGrid**: https://app.sendgrid.com/
2. **Go to Settings** → **API Keys** (left sidebar)
3. **Click "Create API Key"**
4. **Name**: `Ace Supermarket Backend`
5. **Permissions**: Select **"Full Access"** (or at minimum "Mail Send")
6. **Click "Create & View"**
7. **Copy the API Key** immediately (you won't see it again!)

Example API Key format:
```
SG.xxxxxxxxxxxxxxxxxxxx.yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
```

---

## Step 3: Verify Sender Email

SendGrid requires you to verify the email address you'll send from:

### Option A: Single Sender Verification (Recommended for Free Tier)

1. **Go to Settings** → **Sender Authentication**
2. **Click "Verify a Single Sender"**
3. **Fill in details**:
   - **From Name**: `Ace Supermarket`
   - **From Email**: Your email (e.g., `your-email@gmail.com` or `noreply@yourdomain.com`)
   - **Reply To**: Same as From Email
   - **Company**: `Ace Supermarket`
   - **Address**: Your business address
4. **Click "Create"**
5. **Check your email** and click the verification link

### Option B: Domain Authentication (For Production)

If you have your own domain (e.g., `acesupermarket.com`):

1. **Go to Settings** → **Sender Authentication**
2. **Click "Authenticate Your Domain"**
3. **Follow the DNS setup instructions**

---

## Step 4: Configure Render Environment Variables

1. **Go to Render Dashboard**: https://dashboard.render.com/
2. **Select your backend service** (ace-supermarket-backend)
3. **Click "Environment"** tab
4. **Add these environment variables**:

```bash
# Required - Your SendGrid API Key from Step 2
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxx.yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

# Required - The verified email from Step 3
SENDGRID_FROM_EMAIL=your-verified-email@gmail.com

# Optional - Name shown in email "From" field
SENDGRID_FROM_NAME=Ace Supermarket
```

5. **Click "Save Changes"**
6. **Render will auto-deploy** with new settings (takes 2-3 minutes)

---

## Step 5: Test Email Sending

After deployment completes:

1. **Open your Flutter app**
2. **Go to Forgot Password**
3. **Enter**: `ooludiranayoade@gmail.com`
4. **Click "Send Reset Code"**
5. **Check Render logs** - you should see:
   ```
   🔐 PASSWORD RESET OTP for ooludiranayoade@gmail.com: 123456
   ✅ Email sent successfully via SendGrid to ooludiranayoade@gmail.com
   ```
6. **Check your email inbox** - OTP email should arrive within seconds!

---

## Troubleshooting

### "SendGrid not configured" in logs

**Problem**: Missing or invalid `SENDGRID_API_KEY`

**Solution**: 
- Check environment variable is set in Render
- Verify API key is correct (starts with `SG.`)
- Redeploy service after adding variables

---

### "SendGrid failed with status 403"

**Problem**: API key doesn't have "Mail Send" permission

**Solution**:
- Go to SendGrid → Settings → API Keys
- Delete old key
- Create new key with "Full Access" permission

---

### "From email not verified"

**Problem**: `SENDGRID_FROM_EMAIL` is not verified in SendGrid

**Solution**:
- Go to SendGrid → Settings → Sender Authentication
- Verify the email address you're using
- Update `SENDGRID_FROM_EMAIL` to match verified email

---

### Emails going to spam

**Solution**:
- Verify your domain (Option B in Step 3)
- Don't use free email providers (Gmail, Yahoo) as From address
- Use your own domain email if possible

---

## Current Behavior

### Without SendGrid (Current)
```
🔐 PASSWORD RESET OTP for user@email.com: 123456
⚠️ SendGrid not configured - OTP logged only
```
OTP codes are logged to Render console only.

### With SendGrid (After Setup)
```
🔐 PASSWORD RESET OTP for user@email.com: 123456
✅ Email sent successfully via SendGrid to user@email.com
```
OTP codes are logged AND emailed to users.

---

## Cost & Limits

**Free Tier**:
- 100 emails/day
- Perfect for development and small-scale production

**Pro Plan** ($19.95/month):
- 100,000 emails/month
- Upgrade when you exceed 100 emails/day

---

## Security Best Practices

✅ **Never commit API keys** to Git
✅ **Use environment variables** only
✅ **Rotate API keys** every 90 days
✅ **Use least privilege** (Mail Send permission only if possible)
✅ **Monitor usage** in SendGrid dashboard

---

## Support

- **SendGrid Docs**: https://docs.sendgrid.com/
- **SendGrid Support**: https://support.sendgrid.com/
- **Render Docs**: https://render.com/docs/environment-variables

---

## Summary

After completing this setup:
- ✅ Password reset emails will be sent instantly
- ✅ No more SMTP timeout errors
- ✅ OTP codes delivered to user email
- ✅ Logs still show OTP for debugging
- ✅ Professional email delivery at scale

Your forgot password flow will work seamlessly with actual email delivery!
