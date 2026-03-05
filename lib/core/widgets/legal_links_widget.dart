import 'package:flutter/material.dart';
import 'package:visitor_management/core/utils/routes.dart';
import 'package:visitor_management/src/legal/legal_content.dart';

/// A compact, horizontally-wrapping row of text links to all legal documents.
/// Suitable for login/registration screen footers.
class LegalLinksWidget extends StatelessWidget {
  const LegalLinksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    final separatorStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    void open(LegalDocumentType type) {
      Navigator.of(context).pushNamed(Routes.legalDocument, arguments: type);
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 0,
      children: [
        GestureDetector(
          onTap: () => open(LegalDocumentType.termsAndConditions),
          child: Text('Terms & Conditions', style: linkStyle),
        ),
        Text('·', style: separatorStyle),
        GestureDetector(
          onTap: () => open(LegalDocumentType.privacyPolicy),
          child: Text('Privacy Policy', style: linkStyle),
        ),
        Text('·', style: separatorStyle),
        GestureDetector(
          onTap: () => open(LegalDocumentType.eula),
          child: Text('EULA', style: linkStyle),
        ),
        Text('·', style: separatorStyle),
        GestureDetector(
          onTap: () => open(LegalDocumentType.dataDeletion),
          child: Text('Data Deletion', style: linkStyle),
        ),
      ],
    );
  }
}
