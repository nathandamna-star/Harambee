import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { describe, it } from 'node:test';
import { versHtml } from '../legal.js';

describe('pages légales en ligne', () => {
  it('mêmes textes que dans l\'app', () => {
    for (const f of ['cgu_fr.md', 'confidentialite_fr.md']) {
      assert.equal(
        readFileSync(new URL(`../legal/${f}`, import.meta.url), 'utf8'),
        readFileSync(new URL(`../../assets/legal/${f}`, import.meta.url), 'utf8'),
        `${f} : recopier assets/legal/${f} dans functions/legal/`,
      );
    }
  });

  it('conversion en HTML : titres, listes, encadré, caractères échappés', () => {
    const html = versHtml('# Titre\n> Note <b>\n## Partie\n- un\n- deux\nFin & suite', 'Titre');
    assert.match(html, /<h1>Titre<\/h1>/);
    assert.match(html, /<aside>Note &lt;b&gt;<\/aside>/);
    assert.match(html, /<ul>\n<li>un<\/li>\n<li>deux<\/li>\n<\/ul>/);
    assert.match(html, /<p>Fin &amp; suite<\/p>/);
  });
});
