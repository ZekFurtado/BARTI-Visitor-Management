# 🚀 Quick Start: Testing Multi-Tenancy

Get started testing the multi-tenancy features in 5 minutes!

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Clear Any Cached Data (Optional)

If you've run the app before:

**Android:**
```bash
flutter clean
adb shell pm clear com.example.visitorManagement
```

**iOS:**
```bash
flutter clean
# Or uninstall from simulator/device
```

## Step 3: Run the App

```bash
flutter run
```

## Step 4: Test Different Organizations

### 🟠 Test 1: BARTI (Enterprise - Orange Theme)

1. App launches → SubdomainEntryScreen appears
2. Enter: `barti`
3. Click "Connect"
4. ✅ See orange theme, "E-Pravesh - BARTI" title
5. All features enabled

### 🔵 Test 2: Demo Org (Basic - Blue Theme)

1. Clear cache (see below)
2. Enter: `demo`
3. Click "Connect"
4. ✅ See blue theme, "E-Pravesh Demo" title
5. Basic tier features

### 🟢 Test 3: Test Org (Free - Green Theme)

1. Clear cache
2. Enter: `test`
3. Click "Connect"
4. ✅ See green theme, "E-Pravesh Test" title
5. Limited features (free tier)

## How to Clear Cache Between Tests

### Option A: Add Debug Button (Recommended)

Add this to any screen temporarily:

```dart
FloatingActionButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tenant_subdomain');
    await prefs.remove('cached_organization_config');

    // Restart app
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  },
  child: Icon(Icons.refresh),
  backgroundColor: Colors.red,
)
```

### Option B: Clear App Data

- **Android**: Settings → Apps → E-Pravesh → Clear Data
- **iOS**: Uninstall and reinstall

## What to Verify

✅ **Theming Works**
- Each org has different colors
- App name changes per org
- MaterialApp uses `organization.branding.toColorScheme()`

✅ **Feature Flags Work**
- Free tier (`test`) has limited features
- Basic tier (`demo`) has more features
- Enterprise tier (`barti`) has all features

✅ **Organization Context Available**
- Check console logs show correct org name
- UserProvider has currentOrganization set
- All screens can access organization via context

✅ **SubdomainEntryScreen Works**
- Shows on first launch
- Validates input correctly
- Shows error for invalid subdomains
- Connects successfully

## Expected Console Output

```
[Main] 🚀 E-Pravesh starting...
[Main] ✅ Initialized SharedPreferences and TenantConfigService
[TenantConfigService] 🔧 Demo mode enabled - using mock data
[TenantConfigService] ✅ Demo organization loaded: BARTI
[Main] ✅ Organization config loaded: BARTI
[Main] ✅ Firebase initialized for project: visitor-management-e97f4
[Main] 🎉 Launching E-Pravesh for BARTI
[UserProvider] Organization context set: BARTI (barti_demo_id)
```

## Troubleshooting

### Issue: "Pubspec has been edited"

**Solution:**
```bash
flutter pub get
```

The `cloud_functions` package was just added.

### Issue: App crashes on launch

**Check:**
1. Run `flutter doctor` - all checks should pass
2. Ensure Firebase is configured (google-services.json / GoogleService-Info.plist)
3. Check console for error messages

### Issue: Theme not changing

**Solution:**
- Hot restart (Ctrl+C and `flutter run` again)
- Don't use hot reload for theme changes
- Clear cache and try again

### Issue: SubdomainEntryScreen doesn't appear

**Check:**
- SharedPreferences might have cached subdomain
- Use clear cache method above
- Check that no subdomain is stored

## Demo Mode

Currently **demo mode is ENABLED** (`_demoMode = true` in TenantConfigService).

This means:
- ✅ Works without registry Firebase project
- ✅ Uses local mock data
- ✅ Perfect for testing
- ⚠️ Must be disabled for production

**Available demo organizations:**
- `barti` - Enterprise tier
- `demo` - Basic tier
- `test` - Free tier

## Next Steps After Testing

Once you've verified everything works:

1. **Disable demo mode** when ready for production:
   ```dart
   // lib/core/services/tenant_config_service.dart
   static const bool _demoMode = false;
   ```

2. **Set up registry Firebase project** (external step)

3. **Deploy Cloud Functions** to registry

4. **Add real organizations** to registry

5. **Run migration script** for existing users

See `TESTING_MULTI_TENANCY.md` for detailed testing scenarios.

## Quick Feature Test

Test if feature flags work:

```dart
// Add this to any widget
if (context.hasFeature('customFields')) {
  print('✅ Custom fields available');
} else {
  print('❌ Custom fields not available');
}
```

Connect to different orgs and watch the output change!

## Support

Questions? Check:
- `TESTING_MULTI_TENANCY.md` - Comprehensive testing guide
- `CLAUDE.md` - Project overview
- `README.md` - General project info

---

**Ready to test?** Run `flutter pub get` then `flutter run`! 🎉
