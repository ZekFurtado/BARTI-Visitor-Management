# Notification & Visitor Approval Debug Guide

## Issues Fixed

### 1. ✅ **Visitor Approval Error - "Visit not found in visitor profiles"**
**Problem**: When visitors were registered, visits didn't have proper IDs, causing approval failures.

**Root Cause**: The `Visit.fromVisitor()` conversion created visits with null IDs, but the approval system expected valid IDs.

**Solution**: 
- Updated `addVisitToProfile()` to generate unique IDs for visits without IDs
- Updated `createOrUpdateVisitorProfile()` to ensure all visits have IDs when creating new profiles
- Added proper ID generation using Firestore document IDs

### 2. 🔧 **Push Notification Issues**
**Problem**: Employees not receiving push notifications when visitors are registered.

**Debugging Added**:
- Enhanced logging in visitor registration flow
- Added comprehensive FCM debugging in notification service
- Added stack trace logging for notification exceptions

## Testing Instructions

### Test 1: Visitor Registration & Approval Flow

1. **Register a Visitor as Gatekeeper**:
   - Login as gatekeeper
   - Go to visitor registration
   - Fill out visitor details
   - Select an employee to meet
   - Click "Register & Notify Employee"
   - ✅ **Expected**: Registration succeeds, no visit ID errors

2. **Check Debug Logs**:
   Look for these logs in the console:
   ```
   🔔 Attempting to send notification to employee: [EMPLOYEE_ID]
   🐛 === NOTIFICATION DEBUG START ===
   🐛 Current device FCM token: [TOKEN]...
   🐛 ✅ Stored FCM token found
   🐛 ✅ Service account credentials are configured
   🐛 ✅ Access token generated successfully
   📱 Attempting to send notification via FCM HTTP v1...
   📱 FCM Response Status: 200
   ✅ Notification sent successfully via FCM HTTP v1
   ```

3. **Approve/Reject as Employee**:
   - Login as the selected employee
   - Go to employee dashboard
   - See the pending visitor request
   - Click approve or reject
   - ✅ **Expected**: No "Visit not found" errors

### Test 2: Notification Troubleshooting

If notifications still don't work, check the debug output for these scenarios:

#### Scenario A: Service Account Issues
```
❌ Service account credentials not configured!
🔧 Please configure the service account credentials in assets/config/service_account.json
```
**Solution**: Verify service account JSON has valid credentials

#### Scenario B: FCM Token Issues  
```
❌ No FCM token found for employee: [EMPLOYEE_ID]
```
**Solution**: Employee needs to login again to store their FCM token

#### Scenario C: Network/API Issues
```
❌ FCM HTTP v1 Error: [ERROR_MESSAGE]
📱 FCM Response Status: [NON_200_CODE]
```
**Solution**: Check internet connection and Firebase project configuration

#### Scenario D: Permission Issues
```
🐛 Permission status: AuthorizationStatus.denied
```
**Solution**: Grant notification permissions on the employee's device

### Test 3: Notification Permissions

**Employee Device Setup**:
1. Login as employee
2. Allow notification permissions when prompted
3. Verify FCM token is stored:
   - Check Firestore `users` collection
   - Look for `fcmToken` field in employee's document

### Test 4: Multiple Visits from Same Visitor

1. **First Visit**: Register visitor with phone number
2. **Second Visit**: Register same visitor (same phone) for different employee
3. ✅ **Expected**: 
   - Both visits appear in visitor profile
   - Both have unique visit IDs
   - Both employees receive notifications
   - Both can approve/reject independently

## Debugging Commands

### Check Service Account Configuration
```bash
# Verify JSON structure (run from project root)
python3 -c "
import json
with open('assets/config/service_account.json') as f:
    data = json.load(f)
print('✅ Valid JSON structure')
print('Project ID:', data.get('project_id', 'MISSING'))
print('Has private_key:', bool('private_key' in data and len(data.get('private_key', '')) > 50))
print('Client email exists:', bool('client_email' in data))
"
```

### Check App Compilation
```bash
# Check for compilation errors
flutter analyze lib/src/visitor/
flutter analyze lib/core/services/notification_service.dart
```

### Run App with Logging
```bash
# Run app and monitor logs
flutter run --debug
# Watch for the debug output patterns mentioned above
```

## Common Issues & Solutions

### 1. **"Service account credentials not configured"**
- Ensure `assets/config/service_account.json` exists
- Verify it contains valid Firebase service account JSON
- Restart the app after adding the file

### 2. **"No FCM token found for employee"**
- Employee needs to login again to generate and store FCM token
- Check Firestore `users` collection for `fcmToken` field

### 3. **"FCM Response Status: 401/403"**
- Service account doesn't have FCM permissions
- Wrong project ID in service account
- Check Firebase Console > Project Settings > Service Accounts

### 4. **"Visit not found in visitor profiles"**
- This should now be fixed with our ID generation updates
- If still occurs, check that visits have proper IDs in Firestore

### 5. **Notifications sent but not received**
- Check device notification settings
- Verify app is not in battery optimization
- Test with app in foreground vs background
- Check if local notifications appear (app in foreground)

## Firebase Console Checks

### 1. **Cloud Messaging**
- Go to Firebase Console > Project Settings > Cloud Messaging
- Verify FCM is enabled
- Check for any error messages

### 2. **Firestore Data**
- Check `visitor_profiles` collection structure
- Verify visits have proper IDs
- Check `users` collection for FCM tokens

### 3. **Service Accounts**
- Go to Project Settings > Service Accounts
- Verify the service account has proper roles
- Check key hasn't expired

## Expected Debug Output Flow

**Successful Flow**:
```
🔔 Attempting to send notification to employee: abc123
🐛 === NOTIFICATION DEBUG START ===
🐛 1. Checking FCM initialization...
🐛 Current device FCM token: eyJ0eXAiOiJKV1Q...
🐛 2. Checking stored FCM token...
🐛 ✅ Stored FCM token found  
🐛 3. Checking service account configuration...
🐛 ✅ Service account credentials are configured
🐛 ✅ Access token generated successfully
🐛 4. Checking notification permissions...
🐛 Permission status: AuthorizationStatus.authorized
🐛 === NOTIFICATION DEBUG END ===
📱 Attempting to send notification via FCM HTTP v1...
📱 FCM Response Status: 200
✅ Notification sent successfully via FCM HTTP v1
✅ Visitor notification sent successfully to employee: John Doe
```

This comprehensive debugging should help identify exactly where the notification flow is failing and guide you to the solution.