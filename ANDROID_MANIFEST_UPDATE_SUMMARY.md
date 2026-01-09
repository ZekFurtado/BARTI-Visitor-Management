# Android Manifest Updates for FCM Notifications

## What Was Added

### 1. **Permissions** (Added at top of manifest)
```xml
<!-- Internet permission for FCM -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Wake lock permission for FCM -->
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Notification permission (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Vibration permission for notifications -->
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Receive boot completed for notification channels -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

**Why these are needed:**
- `INTERNET`: FCM requires internet to receive push notifications
- `WAKE_LOCK`: Allows app to wake device when notification arrives
- `POST_NOTIFICATIONS`: Required for Android 13+ to show notifications
- `VIBRATE`: Enables vibration when notifications arrive
- `RECEIVE_BOOT_COMPLETED`: Maintains notification channels after device restart

### 2. **Firebase Messaging Services** (Added inside application tag)
```xml
<!-- Firebase Messaging Service -->
<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>

<!-- Firebase Messaging Background Service -->
<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:exported="false" />
```

**Why these are needed:**
- These services handle incoming FCM messages
- Background service processes notifications when app is closed
- Intent filter captures Firebase messaging events

### 3. **Local Notifications Support**
```xml
<!-- Notification Channel for local notifications -->
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

**Why these are needed:**
- Handles local notifications (when app is in foreground)
- Maintains scheduled notifications after device restart
- Supports various device boot completion events

### 4. **Notification Tap Handling**
```xml
<!-- Intent filter to handle notification taps -->
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

**Why this is needed:**
- Handles when user taps on a notification
- Routes user to appropriate screen in the app

### 5. **FCM Configuration Metadata**
```xml
<!-- Default notification icon for FCM -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@mipmap/ic_launcher" />

<!-- Default notification channel for FCM -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="visitor_management_channel" />
```

**Why these are needed:**
- Sets default icon for FCM notifications
- Defines notification channel for better Android notification management

## Impact

### Before Update:
❌ **FCM notifications would not work on Android**
- No permissions to show notifications
- No services to handle incoming messages
- No notification channel configuration

### After Update:
✅ **Full FCM notification support**
- Permissions granted for notifications
- Services configured to handle background messages
- Proper notification channels and icons
- Notification tap handling configured

## Testing the Changes

### 1. **Rebuild the App**
```bash
flutter clean
flutter pub get
flutter run --debug
```

### 2. **Test Notification Flow**
1. Register a visitor as gatekeeper
2. Employee should receive push notification
3. Tap notification to open app
4. Verify notification appears in system tray

### 3. **Test Different Scenarios**
- **App in foreground**: Should show local notification overlay
- **App in background**: Should show system notification
- **App closed**: Should show system notification and open app when tapped

### 4. **Check Permissions**
On Android 13+, the app will request notification permission on first run.
Grant the permission when prompted.

## Common Issues After Update

### 1. **Build Errors**
If you get build errors, try:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd .. && flutter run
```

### 2. **Notification Permission Denied**
If notifications don't work:
- Go to Android Settings > Apps > Visitor Management > Notifications
- Ensure notifications are enabled

### 3. **Background App Restrictions**
Some Android devices have aggressive battery optimization:
- Go to Settings > Battery > Battery Optimization
- Find your app and set to "Not optimized"

## What This Fixes

1. ✅ **Android notification permissions** - App can now show notifications
2. ✅ **FCM background processing** - Messages processed when app is closed
3. ✅ **Notification channels** - Proper Android notification organization
4. ✅ **Notification tap handling** - Tapping notifications opens the app
5. ✅ **Device restart compatibility** - Notifications work after reboot

Your Android app should now properly receive and display FCM notifications!