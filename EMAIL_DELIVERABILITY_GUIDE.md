# Email Deliverability Guide - Avoiding Spam Folder

## Why Emails Go to Spam

Emails from your application may end up in recipients' spam folders due to:

1. **Missing Email Authentication** (SPF, DKIM, DMARC)
2. **Low sender reputation** (new domain/sender)
3. **Spam trigger words** in content
4. **No email engagement** (recipients don't open/click)
5. **Shared IP reputation** (using SendGrid's shared IP)

---

## ✅ Solutions to Improve Deliverability

### 1. **Set Up Email Authentication Records**

Add these DNS records to your domain (acemall.com):

#### **SPF Record** (Sender Policy Framework)
```
Type: TXT
Host: @
Value: v=spf1 include:sendgrid.net ~all
```

#### **DKIM Record** (DomainKeys Identified Mail)
1. Go to SendGrid Dashboard → Settings → Sender Authentication
2. Click "Authenticate Your Domain"
3. Follow the wizard to generate DKIM records
4. Add the provided CNAME records to your DNS

#### **DMARC Record** (Domain-based Message Authentication)
```
Type: TXT
Host: _dmarc
Value: v=DMARC1; p=none; rua=mailto:dmarc@acemall.com
```

### 2. **Verify Your Sender Domain in SendGrid**

**Steps:**
1. Log in to SendGrid Dashboard
2. Navigate to **Settings** → **Sender Authentication**
3. Click **Authenticate Your Domain**
4. Enter your domain: `acemall.com`
5. Add the DNS records provided by SendGrid
6. Click **Verify** once DNS propagates (can take 24-48 hours)

**Benefits:**
- ✅ Emails sent from `noreply@acemall.com` instead of `sendgrid.net`
- ✅ Improved deliverability and trust
- ✅ Reduced spam score

### 3. **Use a Dedicated IP Address** (Optional)

**Current:** You're using SendGrid's shared IP pool
**Upgrade:** Get a dedicated IP address for better control

**How:**
- Upgrade SendGrid plan to Pro or higher
- Request dedicated IP from SendGrid
- Warm up the IP gradually (send increasing volumes over 2-4 weeks)

**Cost:** ~$79.95/month for Pro plan with dedicated IP

### 4. **Improve Email Content**

**Current Issues:**
- Generic "noreply" sender address
- Limited engagement tracking

**Improvements:**

```go
// Use a real sender name and address
fromEmail := "support@acemall.com"  // Instead of noreply
fromName := "Ace Mall Team"

// Add tracking
// SendGrid automatically adds click and open tracking
```

**Avoid Spam Triggers:**
- ❌ ALL CAPS SUBJECT LINES
- ❌ Too many exclamation marks!!!
- ❌ Words like "FREE", "CLICK HERE", "LIMITED TIME"
- ✅ Use professional, clear subject lines
- ✅ Personalize with recipient name
- ✅ Provide clear unsubscribe option

### 5. **Test Email Deliverability**

Use these tools to check your email score:

- **Mail-Tester**: https://www.mail-tester.com/
  - Send a test email to the provided address
  - Get a score out of 10
  - See specific issues to fix

- **GlockApps**: https://glockapps.com/
  - Test spam filter performance
  - Check placement in Gmail, Outlook, etc.

- **MXToolbox**: https://mxtoolbox.com/SuperTool.aspx
  - Check DNS records (SPF, DKIM, DMARC)
  - Verify domain reputation

### 6. **Implement Email Best Practices**

```go
// backend/utils/email.go improvements

// 1. Add unsubscribe link
const emailFooter = `
<p style="font-size: 11px; color: #999; margin-top: 20px;">
    If you no longer wish to receive these emails, 
    <a href="%s/unsubscribe?email=%s" style="color: #999;">unsubscribe here</a>.
</p>
`

// 2. Add List-Unsubscribe header
request.SetHeaders(map[string]string{
    "List-Unsubscribe": fmt.Sprintf("<%s/unsubscribe?email=%s>", os.Getenv("APP_URL"), to),
})

// 3. Set Reply-To address
request.SetReplyTo(mail.NewEmail("Ace Mall Support", "support@acemall.com"))
```

### 7. **Monitor Email Metrics**

Track these metrics in SendGrid:

- **Delivery Rate**: Should be >95%
- **Open Rate**: Should be >15-20%
- **Bounce Rate**: Should be <5%
- **Spam Reports**: Should be <0.1%

**How to Access:**
1. Go to SendGrid Dashboard
2. Navigate to **Statistics** → **Overview**
3. Review metrics and identify issues

---

## 🚀 Quick Setup Checklist

- [ ] Set up SendGrid account with API key
- [ ] Add SPF record to DNS
- [ ] Set up DKIM authentication in SendGrid
- [ ] Add DMARC record to DNS
- [ ] Verify domain in SendGrid
- [ ] Test email with Mail-Tester (aim for 9+/10 score)
- [ ] Update sender address from `noreply` to `support@acemall.com`
- [ ] Monitor deliverability metrics weekly
- [ ] Set up reply monitoring for `support@acemall.com`

---

## 📧 DNS Configuration Example

```
# Your DNS Records (acemall.com)

# SPF Record
Type: TXT
Host: @
Value: v=spf1 include:sendgrid.net ~all
TTL: 3600

# DKIM Records (from SendGrid)
Type: CNAME
Host: s1._domainkey
Value: s1.domainkey.u12345678.wl.sendgrid.net
TTL: 3600

Type: CNAME
Host: s2._domainkey
Value: s2.domainkey.u12345678.wl.sendgrid.net
TTL: 3600

# DMARC Record
Type: TXT
Host: _dmarc
Value: v=DMARC1; p=none; rua=mailto:dmarc@acemall.com
TTL: 3600
```

---

## 🔍 Troubleshooting

**Still going to spam?**

1. **Check DNS propagation**: Use https://dnschecker.org/
2. **Verify SendGrid configuration**: Ensure domain is authenticated
3. **Test with Mail-Tester**: Identify specific issues
4. **Check domain reputation**: Use MXToolbox
5. **Warm up domain**: Start with small volumes, gradually increase
6. **Contact SendGrid support**: They can review your account

**Common Issues:**

- **DNS records not updated**: Wait 24-48 hours for propagation
- **DKIM not verified**: Check CNAME records are correct
- **Shared IP reputation**: Consider dedicated IP
- **Content triggers**: Review email content for spam words
- **Low engagement**: Recipients not opening/clicking emails

---

## 📊 Expected Results

After implementing these improvements:

- **Delivery Rate**: 98%+ (from ~90%)
- **Spam Folder**: <2% (from ~20-30%)
- **Open Rate**: 25-30% (from ~10-15%)
- **Trust Score**: Mail-Tester 9+/10 (from 5-6/10)

---

## 💡 Pro Tips

1. **Use a subdomain**: Send from `mail.acemall.com` to protect main domain reputation
2. **Segment recipients**: Send to engaged users first, then expand
3. **Clean email list**: Remove bounces and inactive emails regularly
4. **A/B test subject lines**: Improve open rates
5. **Send at optimal times**: Test different send times for best engagement

---

## 📞 Support Contacts

- **SendGrid Support**: https://support.sendgrid.com/
- **SendGrid Documentation**: https://docs.sendgrid.com/
- **DNS Provider Support**: Contact your domain registrar (GoDaddy, Namecheap, etc.)

---

**Last Updated:** February 6, 2026
**Next Review:** Check email deliverability metrics monthly
