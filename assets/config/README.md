# FCM HTTP v1 Configuration

This directory contains configuration files for Firebase Cloud Messaging using the newer HTTP v1 API.

## Setup Instructions

1. **Generate Service Account Key:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project (`visitor-management-e97f4`)
   - Go to Project Settings > Service accounts
   - Click "Generate new private key"
   - Download the JSON file

2. **Configure the Application:**
   - Copy the downloaded JSON file to this directory
   - Rename it to `service_account.json`
   - Ensure the file structure matches the template in `service_account_template.json`

3. **Security Note:**
   - **Never commit `service_account.json` to version control**
   - Add `service_account.json` to your `.gitignore` file
   - In production, consider using environment variables or secure cloud storage

## File Structure

```
assets/config/
├── README.md                    # This file
├── service_account_template.json # Template file (safe to commit)
└── service_account.json         # Real credentials (DO NOT COMMIT)
```

## Verification

After setting up the service account file:

1. Run the app
2. Trigger a visitor registration
3. Check the console logs for FCM debugging information
4. Look for "✅ Access token generated successfully"

If you see "❌ Service account credentials not configured!", ensure:
- The file exists at `assets/config/service_account.json`
- The file contains valid Firebase service account credentials
- The `private_key` field is not empty or placeholder text