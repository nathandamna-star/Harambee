import assert from 'node:assert/strict';
import { test } from 'node:test';
import { lienApp, pageCommerce, pageIntrouvable } from '../pageCommerce.js';

const commerce = {
  nom: 'Chez Mama <Awa>',
  categorie: 'restaurant',
  ville: 'Bruxelles',
  description: 'Cuisine ivoirienne : attiéké, alloco et poisson braisé.',
  adresse: 'Chaussée de Wavre 1, 1050 Ixelles',
  photos: ['https://exemple.test/photo.jpg'],
  labelAfricain: true,
  labelChretien: false,
  noteMoyenne: 4.5,
  nbAvis: 12,
  statut: 'publie',
};

test('la page présente le commerce et échappe le HTML', () => {
  const html = pageCommerce('mama1', commerce, 'https://x.test/commerce?id=mama1');
  assert.match(html, /Chez Mama &lt;Awa&gt;/);
  assert.doesNotMatch(html, /<Awa>/);
  assert.match(html, /Restaurant · Bruxelles/);
  assert.match(html, /<li>Africain<\/li>/);
  assert.doesNotMatch(html, /<li>Chrétien<\/li>/);
  assert.match(html, /★ 4,5 · 12 avis/);
  assert.match(html, /og:image" content="https:\/\/exemple.test\/photo.jpg"/);
  assert.match(html, /href="harambee:\/\/app\/explorer\/commerce\/mama1"/);
  assert.match(html, /arrive bientôt/);
});

test('lien vers le site web, seulement en http(s)', () => {
  const avecSite = pageCommerce('m', { ...commerce, siteWeb: 'https://chezmama.be' });
  assert.match(avecSite, /href="https:\/\/chezmama.be"/);
  const piege = pageCommerce('m', { ...commerce, siteWeb: 'javascript:alert(1)' });
  assert.doesNotMatch(piege, /javascript:/);
});

test('lien vers l\'app encodé, page introuvable sans données', () => {
  assert.equal(lienApp('a/b'), 'harambee://app/explorer/commerce/a%2Fb');
  const html = pageIntrouvable();
  assert.match(html, /Commerce introuvable/);
});
