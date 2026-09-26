import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../core/config/stripe.dart';
import '../../../core/theme/app_colors.dart';

enum ResultatPaiement { reussi, annule, echoue }

/// Affiche le formulaire de paiement (carte, Bancontact…).
abstract interface class PaiementService {
  bool get disponible;
  Future<ResultatPaiement> payer(String clientSecret);
}

class PaiementStripe implements PaiementService {
  @override
  bool get disponible => stripeClePublique.isNotEmpty;

  @override
  Future<ResultatPaiement> payer(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Harambee',
          returnURL: '$stripeSchemaUrl://stripe-redirect',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: AppColors.terracotta),
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return ResultatPaiement.reussi;
    } on StripeException catch (e) {
      return e.error.code == FailureCode.Canceled
          ? ResultatPaiement.annule
          : ResultatPaiement.echoue;
    } catch (_) {
      return ResultatPaiement.echoue;
    }
  }
}
