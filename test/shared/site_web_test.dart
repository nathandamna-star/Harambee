import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/shared/models/site_web.dart';

void main() {
  test('adresse complétée et mise en forme', () {
    expect(normaliserSiteWeb('monmagasin.be'), 'https://monmagasin.be');
    expect(
      normaliserSiteWeb(' WWW.MonMagasin.BE/ '),
      'https://www.monmagasin.be',
    );
    expect(
      normaliserSiteWeb('http://boutique.exemple.com/produits?x=1'),
      'http://boutique.exemple.com/produits?x=1',
    );
    expect(
      normaliserSiteWeb('HTTPS://Exemple.fr/Page'),
      'https://exemple.fr/Page',
    );
  });

  test('adresses refusées', () {
    for (final saisie in [
      '',
      'mon site',
      'monmagasin',
      'javascript:alert(1)',
      'https://',
      'ftp://exemple.com',
      'https://${'a' * 300}.be',
    ]) {
      expect(normaliserSiteWeb(saisie), isNull, reason: saisie);
    }
  });

  test('affichage lisible', () {
    expect(siteWebLisible('https://www.monmagasin.be'), 'monmagasin.be');
    expect(siteWebLisible('http://exemple.com/page/'), 'exemple.com/page');
  });
}
