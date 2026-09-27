import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { describe, it } from 'node:test';
import { construireCommerce, geohash, motsClesRecherche, motsNormalises } from '../demo/construire.js';

describe('données de démonstration', () => {
  it('même recherche que l\'app : minuscules, sans accents, débuts de mots', () => {
    assert.deepEqual(motsNormalises('Librairie Grâce & Paix'), ['librairie', 'grace', 'paix']);
    const cles = motsClesRecherche(['Chez Mama', 'Lyon']);
    for (const c of ['ch', 'che', 'chez', 'ma', 'mam', 'mama', 'ly', 'lyon']) assert.ok(cles.includes(c));
    assert.ok(!cles.includes('c'));
  });

  it('geohash standard (Paris : u09tv…)', () => {
    assert.ok(geohash(48.8566, 2.3522).startsWith('u09tv'));
    assert.equal(geohash(57.64911, 10.40744, 11), 'u4pruydqqvj');
  });

  it('dix commerces publiés, marqués « démo », avec produits et avis', () => {
    const donnees = JSON.parse(readFileSync(new URL('../demo/commerces.json', import.meta.url)));
    const maintenant = new Date('2026-09-27');
    const commerces = donnees.map((c, i) => construireCommerce(c, i, maintenant));
    assert.equal(commerces.length, 10);
    for (const c of commerces) {
      assert.match(c.id, /^demo-/);
      assert.equal(c.commerce.demo, true);
      assert.equal(c.commerce.statut, 'publie');
      assert.ok(c.produits.length >= 2);
      assert.ok(c.avis.length >= 2);
      assert.equal(c.commerce.geohash.length, 9);
    }
    const awa = commerces.find((c) => c.id === 'demo-maquis-chez-awa');
    assert.deepEqual(awa.commerce.horaires.lundi, []);
    assert.deepEqual(awa.commerce.horaires.mardi, ['11:30-22:30']);
    assert.ok(awa.commerce.motsCles.includes('awa'));
  });
});
