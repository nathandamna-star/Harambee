import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';

/// « En continuant, vous acceptez les CGU et la politique de confidentialité. »
class LiensLegaux extends StatelessWidget {
  const LiensLegaux({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodySmall;
    return Column(
      children: [
        Text(
          l10n.enContinuantVousAcceptez,
          style: style,
          textAlign: TextAlign.center,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed: () => context.push(Routes.cgu),
              child: Text(l10n.cgu),
            ),
            TextButton(
              onPressed: () => context.push(Routes.confidentialite),
              child: Text(l10n.confidentialite),
            ),
          ],
        ),
      ],
    );
  }
}
