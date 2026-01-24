/**
 * Cloud Functions for E-Pravesh Tenant Registry
 *
 * These functions handle tenant/organization configuration resolution
 * for the multi-tenant E-Pravesh visitor management system.
 *
 * Deploy with: firebase deploy --only functions --project epravesh-tenant-registry
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * Get tenant configuration by subdomain
 *
 * This callable function resolves a subdomain to its organization configuration,
 * including Firebase credentials, branding, and feature flags.
 *
 * @param {object} data - Request data
 * @param {string} data.subdomain - Organization subdomain to look up
 * @param {object} context - Call context (includes auth info if authenticated)
 * @returns {Promise<object>} Organization configuration
 *
 * @throws {functions.https.HttpsError} not-found - Organization not found
 * @throws {functions.https.HttpsError} invalid-argument - Invalid subdomain format
 * @throws {functions.https.HttpsError} unavailable - Organization is suspended/inactive
 */
exports.getTenantConfig = functions.https.onCall(async (data, context) => {
  const { subdomain } = data;

  // Validate input
  if (!subdomain || typeof subdomain !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Subdomain is required and must be a string'
    );
  }

  const normalizedSubdomain = subdomain.trim().toLowerCase();

  // Validate subdomain format (alphanumeric with hyphens, max 63 chars)
  const subdomainRegex = /^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/;
  if (!subdomainRegex.test(normalizedSubdomain) || normalizedSubdomain.length > 63) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Invalid subdomain format. Use lowercase letters, numbers, and hyphens only.'
    );
  }

  try {
    // Query Firestore for organization by subdomain
    const orgSnapshot = await admin.firestore()
      .collection('organizations')
      .where('subdomain', '==', normalizedSubdomain)
      .limit(1)
      .get();

    if (orgSnapshot.empty) {
      throw new functions.https.HttpsError(
        'not-found',
        `Organization with subdomain "${normalizedSubdomain}" not found`
      );
    }

    const orgDoc = orgSnapshot.docs[0];
    const orgData = orgDoc.data();

    // Check organization status
    if (orgData.status !== 'active' && orgData.status !== 'trial') {
      throw new functions.https.HttpsError(
        'unavailable',
        `Organization "${normalizedSubdomain}" is ${orgData.status}. Please contact support.`
      );
    }

    // Check if trial has expired
    if (orgData.status === 'trial' && orgData.trialEndsAt) {
      const trialEnd = orgData.trialEndsAt.toDate();
      if (trialEnd < new Date()) {
        throw new functions.https.HttpsError(
          'unavailable',
          `Trial period for organization "${normalizedSubdomain}" has expired. Please upgrade to continue.`
        );
      }
    }

    // Return organization configuration
    // NOTE: Sensitive admin keys should NOT be returned here
    return {
      id: orgDoc.id,
      subdomain: orgData.subdomain,
      name: orgData.name,
      status: orgData.status,
      firebaseConfig: orgData.firebaseConfig,
      branding: orgData.branding || {},
      features: orgData.features || {},
      visitorCustomFields: orgData.visitorCustomFields || [],
      employeeCustomFields: orgData.employeeCustomFields || [],
      createdAt: orgData.createdAt,
      subscriptionPlan: orgData.subscription?.plan || 'free',
      // Include limited metadata
      metadata: {
        supportEmail: orgData.email,
        phone: orgData.phone,
        website: orgData.website,
      },
    };

  } catch (error) {
    // If it's already an HttpsError, rethrow it
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Log unexpected errors
    console.error('Error fetching tenant config:', error);

    throw new functions.https.HttpsError(
      'internal',
      'Failed to fetch organization configuration. Please try again later.'
    );
  }
});

/**
 * List all active organizations (admin only)
 *
 * This callable function returns a list of all active organizations.
 * Requires authentication and admin privileges.
 *
 * @param {object} data - Request data (empty)
 * @param {object} context - Call context (must include auth)
 * @returns {Promise<Array>} List of organizations
 *
 * @throws {functions.https.HttpsError} unauthenticated - User not authenticated
 * @throws {functions.https.HttpsError} permission-denied - User not admin
 */
exports.listOrganizations = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated to list organizations'
    );
  }

  // TODO: Implement admin check
  // Check if user is system admin
  // const userDoc = await admin.firestore().collection('admins').doc(context.auth.uid).get();
  // if (!userDoc.exists) {
  //   throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  // }

  try {
    const orgsSnapshot = await admin.firestore()
      .collection('organizations')
      .where('status', 'in', ['active', 'trial'])
      .orderBy('name')
      .get();

    const organizations = orgsSnapshot.docs.map(doc => ({
      id: doc.id,
      subdomain: doc.data().subdomain,
      name: doc.data().name,
      status: doc.data().status,
      subscriptionPlan: doc.data().subscription?.plan,
      createdAt: doc.data().createdAt,
    }));

    return { organizations };

  } catch (error) {
    console.error('Error listing organizations:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to list organizations'
    );
  }
});

/**
 * Create a new organization (admin only)
 *
 * This callable function creates a new organization in the registry.
 * Requires authentication and admin privileges.
 *
 * @param {object} data - Organization data
 * @param {object} context - Call context (must include auth)
 * @returns {Promise<object>} Created organization
 *
 * @throws {functions.https.HttpsError} unauthenticated - User not authenticated
 * @throws {functions.https.HttpsError} permission-denied - User not admin
 * @throws {functions.https.HttpsError} already-exists - Subdomain already taken
 */
exports.createOrganization = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated to create organizations'
    );
  }

  // TODO: Implement admin check

  const {
    subdomain,
    name,
    firebaseConfig,
    branding,
    features,
    subscriptionPlan = 'free',
  } = data;

  // Validate required fields
  if (!subdomain || !name || !firebaseConfig) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'subdomain, name, and firebaseConfig are required'
    );
  }

  const normalizedSubdomain = subdomain.trim().toLowerCase();

  try {
    // Check if subdomain already exists
    const existingOrg = await admin.firestore()
      .collection('organizations')
      .where('subdomain', '==', normalizedSubdomain)
      .limit(1)
      .get();

    if (!existingOrg.empty) {
      throw new functions.https.HttpsError(
        'already-exists',
        `Organization with subdomain "${normalizedSubdomain}" already exists`
      );
    }

    // Create organization document
    const orgRef = await admin.firestore().collection('organizations').add({
      subdomain: normalizedSubdomain,
      name,
      status: subscriptionPlan === 'free' ? 'trial' : 'active',
      firebaseConfig,
      branding: branding || {},
      features: features || {},
      subscription: {
        plan: subscriptionPlan,
        status: 'active',
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      id: orgRef.id,
      subdomain: normalizedSubdomain,
      name,
      message: 'Organization created successfully',
    };

  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    console.error('Error creating organization:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to create organization'
    );
  }
});

/**
 * Update organization configuration (admin only)
 *
 * This callable function updates an existing organization's configuration.
 * Requires authentication and admin privileges.
 *
 * @param {object} data - Update data
 * @param {string} data.organizationId - Organization ID to update
 * @param {object} data.updates - Fields to update
 * @param {object} context - Call context (must include auth)
 * @returns {Promise<object>} Update confirmation
 *
 * @throws {functions.https.HttpsError} unauthenticated - User not authenticated
 * @throws {functions.https.HttpsError} permission-denied - User not admin
 * @throws {functions.https.HttpsError} not-found - Organization not found
 */
exports.updateOrganization = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated to update organizations'
    );
  }

  // TODO: Implement admin check

  const { organizationId, updates } = data;

  if (!organizationId || !updates) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'organizationId and updates are required'
    );
  }

  try {
    const orgRef = admin.firestore().collection('organizations').doc(organizationId);
    const orgDoc = await orgRef.get();

    if (!orgDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        `Organization with ID "${organizationId}" not found`
      );
    }

    // Add updatedAt timestamp
    const updateData = {
      ...updates,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await orgRef.update(updateData);

    return {
      message: 'Organization updated successfully',
      organizationId,
    };

  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    console.error('Error updating organization:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to update organization'
    );
  }
});
