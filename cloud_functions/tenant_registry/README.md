# E-Pravesh Tenant Registry Cloud Functions

Cloud Functions for managing tenant/organization configuration in the E-Pravesh multi-tenant visitor management system.

## Functions

### 1. `getTenantConfig` (Callable)
Resolves a subdomain to its organization configuration, including Firebase credentials, branding, and feature flags.

**Request:**
```json
{
  "subdomain": "barti"
}
```

**Response:**
```json
{
  "id": "org_123",
  "subdomain": "barti",
  "name": "BARTI",
  "status": "active",
  "firebaseConfig": { ... },
  "branding": { ... },
  "features": { ... },
  "subscriptionPlan": "enterprise"
}
```

### 2. `listOrganizations` (Callable, Admin Only)
Lists all active organizations in the registry.

### 3. `createOrganization` (Callable, Admin Only)
Creates a new organization in the registry.

### 4. `updateOrganization` (Callable, Admin Only)
Updates an existing organization's configuration.

## Setup

### Prerequisites
- Node.js 18+
- Firebase CLI: `npm install -g firebase-tools`
- Firebase project created: `epravesh-tenant-registry`

### Installation

1. Navigate to the functions directory:
   ```bash
   cd cloud_functions/tenant_registry
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Login to Firebase:
   ```bash
   firebase login
   ```

4. Set the project:
   ```bash
   firebase use epravesh-tenant-registry
   ```

## Deployment

### Deploy all functions:
```bash
npm run deploy
```

### Deploy specific function:
```bash
firebase deploy --only functions:getTenantConfig
```

## Testing Locally

### Start emulator:
```bash
npm run serve
```

### Test with Firebase shell:
```bash
npm run shell
```

Then in the shell:
```javascript
getTenantConfig({ subdomain: 'barti' })
```

## Security

- `getTenantConfig`: Public (no authentication required)
- `listOrganizations`: Requires authentication + admin role
- `createOrganization`: Requires authentication + admin role
- `updateOrganization`: Requires authentication + admin role

**TODO:** Implement admin role checking before production deployment.

## Firestore Structure

Organizations are stored in the `organizations` collection:

```
organizations/
  {orgId}/
    id: string
    subdomain: string (unique, indexed)
    name: string
    status: 'active' | 'trial' | 'suspended' | 'inactive'
    firebaseConfig: {
      android: { apiKey, appId, messagingSenderId, projectId, storageBucket }
      ios: { ... }
    }
    branding: {
      logoUrl: string?
      primaryColor: string
      secondaryColor: string
      appName: string
    }
    features: {
      visitorPhotos: boolean
      customFields: boolean
      ...
    }
    subscription: {
      plan: 'free' | 'basic' | 'premium' | 'enterprise'
      status: 'active' | 'cancelled'
    }
    createdAt: timestamp
    updatedAt: timestamp
```

## Indexes Required

Create these Firestore indexes:

1. **organizations** collection:
   - Single field: `subdomain` (Ascending)
   - Single field: `status` (Ascending)
   - Composite: `status` (Ascending) + `name` (Ascending)

Create via Firebase Console or use:
```bash
firebase deploy --only firestore:indexes
```

## Environment Variables

None required currently. Firebase Admin SDK initializes automatically in Cloud Functions environment.

## Monitoring

View function logs:
```bash
npm run logs
```

Or in Firebase Console:
- Functions → getTenantConfig → Logs

## Cost Estimation

- **getTenantConfig**: ~100ms execution, called on app startup
- **Estimated cost**: Free tier covers ~125,000 invocations/month
- **Scaling**: Function auto-scales with demand

## Troubleshooting

### "Function not found" error
- Ensure function is deployed: `firebase deploy --only functions`
- Check project ID: `firebase use`

### "Permission denied" error
- Verify Firestore rules allow Cloud Functions to read `organizations`
- Check that Firebase Admin SDK is initialized

### "Organization not found" error
- Verify organization exists in Firestore
- Check subdomain spelling and case (must be lowercase)

## Next Steps

1. Deploy to production: `npm run deploy`
2. Add admin authentication checks
3. Set up monitoring alerts
4. Create backup/restore procedures
5. Implement rate limiting for public endpoints
