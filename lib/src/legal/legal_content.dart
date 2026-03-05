enum LegalDocumentType {
  termsAndConditions,
  privacyPolicy,
  eula,
  dataDeletion,
  contactSupport,
}

class LegalSection {
  final String heading;
  final String body;

  const LegalSection({required this.heading, required this.body});
}

class LegalDocument {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  /// Optional external URL to view the full document online.
  final String? externalUrl;

  const LegalDocument({
    required this.title,
    required this.lastUpdated,
    required this.sections,
    this.externalUrl,
  });
}

/// Central registry for all legal/compliance documents.
/// To update policy text, edit the relevant static field below.
class LegalContent {
  LegalContent._();

  static LegalDocument getDocument(LegalDocumentType type) {
    switch (type) {
      case LegalDocumentType.termsAndConditions:
        return _termsAndConditions;
      case LegalDocumentType.privacyPolicy:
        return _privacyPolicy;
      case LegalDocumentType.eula:
        return _eula;
      case LegalDocumentType.dataDeletion:
        return _dataDeletion;
      case LegalDocumentType.contactSupport:
        return _contactSupport;
    }
  }

  // ---------------------------------------------------------------------------
  // Terms & Conditions
  // ---------------------------------------------------------------------------
  static const LegalDocument _termsAndConditions = LegalDocument(
    title: 'Terms & Conditions',
    lastUpdated: 'March 5, 2026',
    sections: [
      LegalSection(
        heading: '1. Acceptance of Terms',
        body:
            'By downloading, installing, or using the E-Pravesh (ई-प्रवेश) application ("App"), you agree to be bound by these Terms & Conditions. If you do not agree to these terms, please do not use the App.',
      ),
      LegalSection(
        heading: '2. Description of Service',
        body:
            'E-Pravesh is a visitor management application developed for BARTI (Dr Babasaheb Ambedkar Research and Training Institute). The App enables gatekeepers to register visitors and employees to approve or reject visitor requests with real-time notifications.',
      ),
      LegalSection(
        heading: '3. User Accounts',
        body:
            'To use the App, you must create an account with a valid email address. You are responsible for maintaining the confidentiality of your account credentials and must notify us immediately of any unauthorized access.',
      ),
      LegalSection(
        heading: '4. User Roles',
        body:
            'The App provides two user roles:\n\n'
            '• Gatekeepers: Authorized to register visitors, capture visitor details and photos, and send notifications to employees.\n\n'
            '• Employees: Authorized to receive visitor notifications and approve or reject visitor requests.',
      ),
      LegalSection(
        heading: '5. Acceptable Use',
        body:
            'You agree to use the App only for its intended visitor management purpose within BARTI premises. You must not:\n\n'
            '• Use the App for any unlawful purpose\n'
            '• Collect or store personal data beyond what visitor management requires\n'
            '• Share visitor information with unauthorized parties\n'
            '• Attempt to access other users\' accounts or data',
      ),
      LegalSection(
        heading: '6. Data Collection',
        body:
            'The App collects visitor information including names, photos, purpose of visit, and contact details solely for visitor management. This data is stored securely on Firebase Firestore. See our Privacy Policy for full details.',
      ),
      LegalSection(
        heading: '7. Termination',
        body:
            'We reserve the right to suspend or terminate your account if you violate these Terms & Conditions. Upon termination, your access to the App and associated data may be removed.',
      ),
      LegalSection(
        heading: '8. Changes to Terms',
        body:
            'We may update these Terms & Conditions from time to time. Continued use of the App after any changes constitutes acceptance of the revised Terms.',
      ),
      LegalSection(
        heading: '9. Contact',
        body:
            'For questions about these Terms & Conditions, contact us at legal@barti.gov.in.',
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Privacy Policy
  // ---------------------------------------------------------------------------
  static const LegalDocument _privacyPolicy = LegalDocument(
    title: 'Privacy Policy',
    lastUpdated: 'March 5, 2026',
    sections: [
      LegalSection(
        heading: '1. Introduction',
        body:
            'BARTI (Dr Babasaheb Ambedkar Research and Training Institute) is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use E-Pravesh.',
      ),
      LegalSection(
        heading: '2. Information We Collect',
        body:
            'We collect the following types of information:\n\n'
            '• Account Information: Name, email address, role, department, and job title.\n\n'
            '• Visitor Information: Names, photos, contact details, purpose of visit, origin, and visit status.\n\n'
            '• Usage Data: App interactions and logs for security and troubleshooting.',
      ),
      LegalSection(
        heading: '3. How We Use Your Information',
        body:
            'We use collected information to:\n\n'
            '• Provide and operate the visitor management service\n'
            '• Authenticate users and maintain security\n'
            '• Send notifications about visitor requests\n'
            '• Generate visit reports and statistics\n'
            '• Improve the App and troubleshoot issues',
      ),
      LegalSection(
        heading: '4. Data Storage and Security',
        body:
            'Your data is stored securely on Google Firebase Firestore. We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction.',
      ),
      LegalSection(
        heading: '5. Data Sharing',
        body:
            'We do not sell, trade, or transfer your personal information to outside parties. Visitor data is accessible only to authorized BARTI employees and gatekeepers as required for visitor management.',
      ),
      LegalSection(
        heading: '6. Visitor Photos',
        body:
            'Visitor photos are captured and stored solely for identity verification during the visit. Photos are stored securely on Firebase Storage and are accessible only to authorized users.',
      ),
      LegalSection(
        heading: '7. Push Notifications',
        body:
            'The App uses Firebase Cloud Messaging (FCM) to send push notifications. You may control notification preferences through your device settings.',
      ),
      LegalSection(
        heading: '8. Your Rights (GDPR)',
        body:
            'You have the right to:\n\n'
            '• Access your personal data\n'
            '• Correct inaccurate data\n'
            '• Request deletion of your data\n'
            '• Withdraw consent at any time\n\n'
            'To exercise these rights, contact us at privacy@barti.gov.in.',
      ),
      LegalSection(
        heading: '9. Data Retention',
        body:
            'We retain visitor records for the period necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law.',
      ),
      LegalSection(
        heading: '10. Children\'s Privacy',
        body:
            'The App is not intended for individuals under 18 years of age. We do not knowingly collect personal information from children.',
      ),
      LegalSection(
        heading: '11. Changes to This Policy',
        body:
            'We may update this Privacy Policy periodically. We will notify you of changes by updating the date at the top of this policy. Continued use of the App constitutes acceptance of the updated policy.',
      ),
      LegalSection(
        heading: '12. Contact Us',
        body:
            'Email: privacy@barti.gov.in\n'
            'Address: BARTI, Pune, Maharashtra, India',
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // EULA
  // ---------------------------------------------------------------------------
  static const LegalDocument _eula = LegalDocument(
    title: 'End User License Agreement (EULA)',
    lastUpdated: 'March 5, 2026',
    sections: [
      LegalSection(
        heading: '1. Grant of License',
        body:
            'BARTI grants you a limited, non-exclusive, non-transferable, revocable license to install and use E-Pravesh solely for visitor management purposes at BARTI premises.',
      ),
      LegalSection(
        heading: '2. Restrictions',
        body:
            'You may not:\n\n'
            '• Copy, modify, or distribute the App\n'
            '• Reverse engineer, decompile, or disassemble the App\n'
            '• Create derivative works based on the App\n'
            '• Use the App for any commercial purpose outside of BARTI\'s authorized use\n'
            '• Transfer the App or this license to any third party',
      ),
      LegalSection(
        heading: '3. Intellectual Property',
        body:
            'The App and all its content, features, and functionality are owned by BARTI and protected by applicable intellectual property laws.',
      ),
      LegalSection(
        heading: '4. Updates',
        body:
            'BARTI may provide updates, patches, or upgrades to the App. These updates may be required for continued use and are subject to this EULA.',
      ),
      LegalSection(
        heading: '5. Disclaimer of Warranties',
        body:
            'THE APP IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. BARTI DOES NOT WARRANT THAT THE APP WILL BE ERROR-FREE, UNINTERRUPTED, OR SECURE.',
      ),
      LegalSection(
        heading: '6. Limitation of Liability',
        body:
            'TO THE MAXIMUM EXTENT PERMITTED BY LAW, BARTI SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING FROM YOUR USE OF THE APP.',
      ),
      LegalSection(
        heading: '7. Termination',
        body:
            'This license terminates automatically if you fail to comply with any provision of this EULA. Upon termination, you must cease all use of the App.',
      ),
      LegalSection(
        heading: '8. Governing Law',
        body:
            'This EULA is governed by the laws of India, applicable to the state of Maharashtra.',
      ),
      LegalSection(
        heading: '9. Contact',
        body: 'For questions about this EULA, contact legal@barti.gov.in.',
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Data & Account Deletion
  // ---------------------------------------------------------------------------
  static const LegalDocument _dataDeletion = LegalDocument(
    title: 'Data & Account Deletion',
    lastUpdated: 'March 5, 2026',
    sections: [
      LegalSection(
        heading: 'Your Right to Data Deletion',
        body:
            'You have the right to request deletion of your personal data and account from E-Pravesh at any time.',
      ),
      LegalSection(
        heading: 'What Data Will Be Deleted',
        body:
            'Upon a deletion request, we will remove:\n\n'
            '• Your account information (name, email, role)\n'
            '• Your authentication credentials\n'
            '• Visitor records associated with your account\n'
            '• Your notification preferences and history',
      ),
      LegalSection(
        heading: 'Data Retention After Deletion',
        body:
            'Some data may be retained temporarily to:\n\n'
            '• Comply with legal obligations\n'
            '• Resolve disputes\n'
            '• Enforce our agreements\n\n'
            'In such cases, data will be used only as long as legally necessary.',
      ),
      LegalSection(
        heading: 'How to Request Account Deletion',
        body:
            'To request account and data deletion:\n\n'
            '1. Send an email to privacy@barti.gov.in with subject "Account Deletion Request"\n'
            '2. Include your registered email address\n'
            '3. We will process your request within 30 days\n'
            '4. You will receive a confirmation email upon completion\n\n'
            'Alternatively, contact your BARTI system administrator.',
      ),
      LegalSection(
        heading: 'Consequences of Deletion',
        body:
            'Once your account is deleted:\n\n'
            '• You will immediately lose access to the App\n'
            '• All your data will be permanently removed\n'
            '• This action cannot be undone',
      ),
      LegalSection(
        heading: 'Contact for Data Requests',
        body:
            'Email: privacy@barti.gov.in\nResponse time: Within 30 business days',
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Contact & Support
  // ---------------------------------------------------------------------------
  static const LegalDocument _contactSupport = LegalDocument(
    title: 'Contact & Support',
    lastUpdated: 'March 5, 2026',
    sections: [
      LegalSection(
        heading: 'General Support',
        body:
            'For technical support and general inquiries about E-Pravesh, please use the channels below.',
      ),
      LegalSection(
        heading: 'Email',
        body:
            'General Support: support@barti.gov.in\n'
            'Privacy Inquiries: privacy@barti.gov.in\n'
            'Legal Inquiries: legal@barti.gov.in',
      ),
      LegalSection(
        heading: 'Address',
        body:
            'BARTI\nDr Babasaheb Ambedkar Research and Training Institute\nPune, Maharashtra, India',
      ),
      LegalSection(
        heading: 'Office Hours',
        body:
            'Monday – Friday: 10:00 AM – 5:30 PM (IST)\n'
            'Saturday – Sunday: Closed\n'
            'Public Holidays: Closed',
      ),
      LegalSection(
        heading: 'Legal Requests',
        body:
            'For legal inquiries, data requests, or compliance matters:\n\n'
            'Email: legal@barti.gov.in\n'
            'Please specify the nature of your inquiry in the subject line (e.g., "GDPR Request", "Legal Inquiry").',
      ),
      LegalSection(
        heading: 'Response Time',
        body:
            'We aim to respond to all inquiries within 3–5 business days. Data deletion and privacy requests are processed within 30 business days as required by applicable law.',
      ),
    ],
  );
}