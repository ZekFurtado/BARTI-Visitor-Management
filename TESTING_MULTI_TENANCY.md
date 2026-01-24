# Multi-Tenancy Testing Guide

This guide will help you test the multi-tenancy features that have been implemented in E-Pravesh.

## 🎯 What's Been Implemented

### Core Features
- ✅ Dynamic Firebase initialization per organization
- ✅ Subdomain-based tenant detection
- ✅ Organization context throughout the app
- ✅ Dynamic theming (colors, app name) per organization
- ✅ Feature flags system
- ✅ Multi-organization user support
- ✅ Organization switching capability

### Demo Mode
For testing without the registry Firebase project, **demo mode is enabled** by default.

Available demo organizations:
- `barti` - Full enterprise features (uses existing Firebase project)
- `demo` - Basic tier features with different branding (blue theme)
- `test` - Free tier features with limited capabilities (green theme)

## 📋 Prerequisites

Before testing, ensure you have:

1. ✅ Flutter SDK installed
2. ✅ Dependencies installed: `flutter pub get`
3. ✅ Existing Firebase project credentials in place (already configured)

## 🧪 Test Scenarios

### Test 1: First Launch (No Subdomain Configured)

**Steps:**
1. Clear app data or use a fresh install
2. Run the app: `flutter run`

**Expected Result:**
- App shows SubdomainEntryScreen
- UI prompts you to enter organization subdomain
- Three options available:
  - Enter subdomain manually
  - Scan QR code (placeholder)
  - Help dialog

**Test Input:**
- Try entering: `barti`
- App should connect and show success dialog

### Test 2: BARTI Organization (Enterprise Tier)

**Steps:**
1. Enter subdomain: `barti`
2. Click "Connect"
3. Restart app (or it may auto-navigate)

**Expected Result:**
- App name: "E-Pravesh - BARTI"
- Primary color: Orange (#FA5013)
- All features enabled (Enterprise tier)
- Existing Firebase data loads correctly
- Login flow works as before

**Features to Verify:**
- ✅ Visitor photo capture (enabled)
- ✅ SMS notifications (enabled)
- ✅ Email notifications (enabled)
- ✅ Visitor history (enabled)
- ✅ Custom fields (enabled)
- ✅ Analytics (enabled)
- ✅ Export (enabled)

### Test 3: Demo Organization (Basic Tier)

**Steps:**
1. Clear cached subdomain (see instructions below)
2. Launch app
3. Enter subdomain: `demo`
4. Click "Connect"

**Expected Result:**
- App name: "E-Pravesh Demo"
- Primary color: Blue (#2196F3)
- Secondary color: Yellow (#FFC107)
- Basic tier features enabled
- Trial mode (30 days)

**Features to Verify:**
- ✅ Visitor photos (enabled)
- ✅ SMS notifications (enabled)
- ✅ Email notifications (enabled)
- ✅ Custom fields (enabled)
- ✅ Analytics (enabled)
- ❌ API access (disabled - should be hidden)

### Test 4: Test Organization (Free Tier)

**Steps:**
1. Clear cached subdomain
2. Enter subdomain: `test`
3. Click "Connect"

**Expected Result:**
- App name: "E-Pravesh Test"
- Primary color: Green (#4CAF50)
- Free tier features (limited)
- Max 10 employees, 2 gatekeepers

**Features to Verify:**
- ✅ Visitor photos (enabled)
- ❌ SMS notifications (disabled)
- ✅ Email notifications (enabled)
- ❌ Custom fields (disabled)
- ❌ Analytics (disabled)
- ❌ Export (disabled)

### Test 5: Feature Guards

**Steps:**
1. Connect to `test` organization (free tier)
2. Navigate to screens with gated features

**Expected Result:**
- Features with FeatureGuard should be hidden or show upgrade prompts
- Buttons for disabled features should be disabled
- Clicking disabled features shows "Feature Not Available" message

**Example Code to Add Feature Guard:**
```dart
FeatureGuard(
  featureName: 'customFields',
  child: CustomFieldsSection(),
  fallback: Text('Custom fields not available in your plan'),
)
```

### Test 6: Invalid Subdomain

**Steps:**
1. Clear cached subdomain
2. Enter subdomain: `nonexistent`
3. Click "Connect"

**Expected Result:**
- Error message: "Organization not found"
- Red error container displayed
- Available options: barti, demo, test
- User can retry with correct subdomain

### Test 7: Subdomain Validation

**Test Invalid Formats:**
- `BARTI` (uppercase) → Should be converted to lowercase automatically
- `ba rti` (spaces) → Should show validation error
- `ba@rti` (special chars) → Should show validation error
- `a` (too short) → Should work (minimum 1 char)
- Empty string → Should show "Please enter a subdomain" error

### Test 8: Organization Context in Code

**Verify organization context is available:**

```dart
// In any widget
final org = context.currentOrganization;
print('Current org: ${org?.name}');

// Check features
if (context.hasFeature('customFields')) {
  // Show custom fields UI
}

// Check limits
if (context.canAddEmployee(currentEmployeeCount)) {
  // Show add employee button
}
```

### Test 9: User Provider

**Test UserProvider methods:**

```dart
final userProvider = context.read<UserProvider>();

// Current organization
print(userProvider.currentOrganization?.name);

// Current role (once user logs in)
print(userProvider.currentRole); // 'Gatekeeper' or 'Employee'

// Role checks
print(userProvider.isGatekeeper);
print(userProvider.isEmployee);
```

## 🛠️ Utility Commands

### Clear Cached Subdomain

**Option 1: Through Code**
Add this temporary button in your app:
```dart
ElevatedButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tenant_subdomain');
    await prefs.remove('cached_organization_config');
    print('Subdomain cache cleared!');
    // Restart app
  },
  child: Text('Clear Subdomain Cache'),
)
```

**Option 2: Clear App Data**
- Android: Settings → Apps → E-Pravesh → Clear Data
- iOS: Uninstall and reinstall

### Enable/Disable Demo Mode

Edit `lib/core/services/tenant_config_service.dart`:

```dart
static const bool _demoMode = true; // Set to false for production
```

### Add Custom Demo Organization

Edit `lib/core/services/tenant_config_service_demo.dart`:

```dart
case 'myorg':
  return OrganizationModel(
    id: 'myorg_id',
    subdomain: 'myorg',
    name: 'My Organization',
    // ... configure as needed
  );
```

## 🐛 Troubleshooting

### Issue: Firebase initialization error

**Symptoms:**
- "Firebase initialization failed" error screen
- App crashes on launch

**Solution:**
1. Check that Firebase credentials in demo organizations are correct
2. Verify Firebase project is active
3. Check `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) are present

### Issue: "Pubspec has been edited" warning

**Solution:**
Add missing dependency to `pubspec.yaml`:

```yaml
dependencies:
  cloud_functions: ^4.5.0  # Add this line
```

Then run: `flutter pub get`

### Issue: Can't see themed colors

**Symptoms:**
- App shows default orange color for all organizations
- Branding not applied

**Solution:**
1. Hot restart (not hot reload) after changing organization
2. Verify `main.dart` uses `organization.branding.toColorScheme()`
3. Check that UserProvider has `setCurrentOrganization` called

### Issue: SubdomainEntryScreen doesn't show

**Symptoms:**
- App goes straight to splash/login

**Solution:**
- Clear SharedPreferences cache (see utility commands above)
- Check `TenantConfigService.detectSubdomain()` is throwing exception

## 📊 Expected Console Logs

When app launches successfully, you should see:

```
[Main] 🚀 E-Pravesh starting...
[Main] ✅ Initialized SharedPreferences and TenantConfigService
[TenantConfigService] Subdomain detected from cache: barti
[TenantConfigService] 🔧 Demo mode enabled - using mock data
[TenantConfigService] ✅ Demo organization loaded: BARTI
[Main] ✅ Organization config loaded: BARTI
[Main] ✅ Firebase initialized for project: visitor-management-e97f4
[Main] ✅ Dependency injection initialized
[Main] ✅ Background service initialized
[Main] ✅ Notification service initialized
[Main] 🎉 Launching E-Pravesh for BARTI
[UserProvider] Organization context set: BARTI (barti_demo_id)
```

## 🎬 Demo Video Script

Record a video showing:

1. **Fresh launch** → SubdomainEntryScreen appears
2. **Enter "barti"** → Success dialog → App loads with orange theme
3. **Clear cache** → Enter "demo" → App loads with blue theme
4. **Clear cache** → Enter "test" → App loads with green theme
5. **Show feature differences** → Compare what's available in each tier
6. **Test validation** → Enter invalid subdomain → Show error
7. **Organization context** → Show current org name in UI

## ✅ Checklist Before Production

- [ ] Set `_demoMode = false` in TenantConfigService
- [ ] Set up actual registry Firebase project
- [ ] Deploy Cloud Functions to registry
- [ ] Create real BARTI organization entry in registry
- [ ] Update registry API keys in TenantConfigService
- [ ] Test with actual registry (not demo mode)
- [ ] Run migration script for existing users
- [ ] Update Firestore security rules
- [ ] Add organization context validation in datasources
- [ ] Complete integration tests
- [ ] Security audit
- [ ] Load testing with multiple organizations

## 📝 Next Steps

After testing, proceed with:

1. **Set up registry Firebase project** (external)
2. **Deploy Cloud Functions** to registry
3. **Create BARTI organization** in registry with real credentials
4. **Write migration script** for existing users
5. **Add feature guards** to existing screens
6. **Integration testing** with real registry
7. **Security testing** and audit

## 💡 Tips

- Use different devices/emulators to test different organizations simultaneously
- Check UserProvider state in DevTools to verify organization context
- Use Flutter Inspector to verify themed colors are applied
- Monitor Firebase Console to ensure correct project is being used
- Test offline mode - cached config should work without network

## 🎉 Success Criteria

You'll know it's working when:
- ✅ Different subdomains load different organizations
- ✅ Themes change per organization
- ✅ Features are hidden/shown based on plan
- ✅ Firebase data is isolated (each org uses correct project)
- ✅ Organization context is available throughout app
- ✅ No errors in console during organization switching
- ✅ SubdomainEntryScreen works smoothly
- ✅ Validation catches invalid input

Happy Testing! 🚀
