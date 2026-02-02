# Firebase Cloud Messaging (FCM) Setup for Push Notifications

This guide explains how to set up Firebase Cloud Messaging for push notifications in the Ace Supermarket app.

## Features

✅ **Admin Message Notifications** - Staff receive push notifications when admins send messages
✅ **30-Minute Shift Reminders** - Staff get notified 30 minutes before their shift starts
✅ **In-App Notifications** - Notifications also appear in the app's notification page
✅ **Multi-Device Support** - Works on iOS, Android, and Web

## Backend Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it: `Ace Supermarket`
4. Disable Google Analytics (optional)
5. Click "Create project"

### 2. Enable Cloud Messaging

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Click **Cloud Messaging** tab
3. Note your **Server Key** (you'll need this for Flutter)

### 3. Generate Service Account Key

1. In Firebase Console, go to **Project Settings** → **Service Accounts**
2. Click **Generate New Private Key**
3. Click **Generate Key** - this downloads a JSON file
4. Rename the file to `firebase-credentials.json`
5. Place it in the backend root directory: `/Users/Gracegold/Desktop/Ace App/backend/`

**⚠️ IMPORTANT: Never commit this file to Git!**

Add to `.gitignore`:
```
firebase-credentials.json
```

### 4. Configure Environment Variable (Optional)

If you want to use a different path for the credentials file:

```bash
FIREBASE_CREDENTIALS_PATH=/path/to/your/firebase-credentials.json
```

### 5. Run Database Migration

The `device_tokens` table is created automatically via migration:

```sql
-- Already created in: backend/database/migrations/009_device_tokens.sql
```

### 6. Deploy to Render

**Upload Firebase Credentials to Render:**

1. Go to your Render service dashboard
2. Click **Environment** tab
3. Add **Secret File**:
   - **Filename**: `firebase-credentials.json`
   - **Contents**: Paste the entire JSON content from your downloaded file
4. Click **Save**

The backend will automatically detect and use this file.

---

## Flutter App Setup

### 1. Install Firebase Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^16.3.0
```

Run:
```bash
flutter pub get
```

### 2. Configure Firebase for Flutter

**For Android:**
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`

**For iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place in `ios/Runner/GoogleService-Info.plist`

### 3. Initialize Firebase in Flutter

**Update `main.dart`:**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}
```

### 4. Request Notification Permissions

```dart
Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  }
}
```

### 5. Get and Register Device Token

**Create a notification service:**

```dart
class NotificationService {
  final ApiService _apiService = ApiService();
  
  Future<void> initialize() async {
    // Get FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    
    if (token != null) {
      // Register with backend
      await _apiService.registerDeviceToken(token);
    }
    
    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _apiService.registerDeviceToken(newToken);
    });
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });
    
    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.data}');
      _handleNotificationTap(message);
    });
  }
  
  void _showLocalNotification(RemoteMessage message) {
    // Show local notification when app is in foreground
    // Implementation depends on flutter_local_notifications
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to appropriate screen based on notification type
    String type = message.data['type'] ?? '';
    
    if (type == 'admin_message') {
      // Navigate to messages page
    } else if (type == 'shift_reminder') {
      // Navigate to schedule page
    }
  }
}
```

### 6. Add API Service Methods

**In `api_service.dart`:**

```dart
Future<void> registerDeviceToken(String deviceToken) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/device-tokens/register'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'device_token': deviceToken,
        'device_type': Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web',
      }),
    );
    
    if (response.statusCode == 200) {
      print('Device token registered successfully');
    }
  } catch (e) {
    print('Failed to register device token: $e');
  }
}

Future<void> unregisterDeviceToken(String deviceToken) async {
  try {
    await http.post(
      Uri.parse('$baseUrl/device-tokens/unregister'),
      headers: await _getHeaders(),
      body: jsonEncode({'device_token': deviceToken}),
    );
  } catch (e) {
    print('Failed to unregister device token: $e');
  }
}
```

### 7. Initialize on Login

**In your login flow:**

```dart
// After successful login
await NotificationService().initialize();
```

---

## Testing Push Notifications

### 1. Test from Backend

Use the test endpoint:

```bash
curl -X POST https://ace-supermarket-backend.onrender.com/api/v1/device-tokens/test \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

### 2. Test Admin Messages

1. Login as CEO/HR/Chairman
2. Go to Messages
3. Send a message to staff
4. Staff should receive push notification immediately

### 3. Test Shift Reminders

1. Create a roster with a shift starting in 30 minutes
2. Wait for the scheduler to run (checks every minute)
3. Staff should receive push notification 30 minutes before shift

---

## Notification Types

### Admin Messages
- **Title**: Message title from admin
- **Body**: Message content
- **Data**: `type: admin_message`, `message_id`, `sender`

### Shift Reminders
- **Title**: "⏰ Shift Reminder"
- **Body**: "Your Morning Shift (09:00 - 17:00) starts in 30 minutes!"
- **Data**: `type: shift_reminder`, `shift_type`, `start_time`, `end_time`, `department`, `branch`

---

## Troubleshooting

### Backend Issues

**"Firebase credentials file not found"**
- Ensure `firebase-credentials.json` exists in backend root
- Or set `FIREBASE_CREDENTIALS_PATH` environment variable

**"FCM client not initialized"**
- Check Firebase credentials file is valid JSON
- Verify service account has Cloud Messaging permissions

### Flutter Issues

**"No device tokens found"**
- Ensure Flutter app calls `registerDeviceToken()` after login
- Check device has internet connection
- Verify FCM token is being generated

**Notifications not appearing**
- Check notification permissions are granted
- Verify app is not in battery optimization
- Test with foreground and background states

---

## Production Checklist

- [ ] Firebase project created
- [ ] Service account key downloaded
- [ ] `firebase-credentials.json` uploaded to Render
- [ ] Flutter app configured with `google-services.json` (Android)
- [ ] Flutter app configured with `GoogleService-Info.plist` (iOS)
- [ ] Device token registration implemented in Flutter
- [ ] Notification permissions requested
- [ ] Foreground notification handling implemented
- [ ] Background notification handling implemented
- [ ] Notification tap handling implemented
- [ ] Tested admin messages
- [ ] Tested shift reminders

---

## Security Notes

- ✅ Firebase credentials file is gitignored
- ✅ Device tokens are user-specific and deleted on logout
- ✅ Invalid tokens are automatically removed
- ✅ All endpoints require JWT authentication
- ✅ Push notifications only sent to authenticated users

---

**Push notifications are now fully integrated! Staff will receive real-time alerts for admin messages and shift reminders on their mobile devices.**
