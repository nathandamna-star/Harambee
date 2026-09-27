// Page web publique d'un commerce : c'est l'adresse partagée (bouton
// « Partager », QR code des affiches). Elle présente le commerce, ouvre l'app
// si elle est installée, sinon renvoie vers les stores.

/** Adresses des fiches App Store / Google Play (à compléter à la publication). */
export const LIENS_STORES = {
  appStore: null,
  googlePlay: null,
};

const CATEGORIES = {
  magasin: 'Magasin',
  restaurant: 'Restaurant',
  logement: 'Logement',
  service: 'Service',
};

const echapper = (t) => String(t ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;').replace(/'/g, '&#39;');

/** Lien qui ouvre la fiche dans l'app (schéma déclaré sur iOS et Android). */
export function lienApp(id) {
  return `harambee://app/explorer/commerce/${encodeURIComponent(id)}`;
}

function extrait(texte, max) {
  const t = String(texte ?? '').replace(/\s+/g, ' ').trim();
  return t.length <= max ? t : `${t.slice(0, max - 1).trimEnd()}…`;
}

const STYLE = `
:root{--fond:#F6F1E7;--texte:#1E1B16;--second:#5E574C;--accent:#B4451F;--sur-accent:#FFFFFF;--carte:#FFFDF8;--bord:#E4DccE}
@media (prefers-color-scheme:dark){:root{--fond:#17140F;--texte:#F1EBE0;--second:#B9B0A2;--accent:#E08A64;--sur-accent:#1E1B16;--carte:#221E18;--bord:#3A342B}}
*{box-sizing:border-box}
body{background:var(--fond);color:var(--texte);font:16px/1.55 -apple-system,system-ui,sans-serif;margin:0;padding:24px 16px}
main{max-width:560px;margin:0 auto}
.marque{font-family:Georgia,serif;font-weight:700;font-size:1.4rem;color:var(--accent);text-align:center;margin:0 0 20px}
.carte{background:var(--carte);border:1px solid var(--bord);border-radius:20px;overflow:hidden}
.photo{width:100%;aspect-ratio:16/10;object-fit:cover;display:block;background:var(--bord)}
.contenu{padding:20px}
h1{font-family:Georgia,serif;font-size:1.6rem;line-height:1.2;margin:0 0 6px}
.meta{color:var(--second);margin:0 0 12px}
.labels{display:flex;gap:8px;flex-wrap:wrap;margin:0 0 12px;padding:0;list-style:none}
.labels li{border:1px solid var(--accent);color:var(--accent);border-radius:999px;padding:2px 10px;font-size:.85rem}
.bouton{display:block;text-align:center;text-decoration:none;font-weight:600;border-radius:14px;padding:14px;margin-top:12px}
.principal{background:var(--accent);color:var(--sur-accent)}
.secondaire{border:1px solid var(--bord);color:var(--texte)}
.note{color:var(--second);font-size:.9rem;text-align:center;margin-top:20px}
`;

function page({ titre, description, image, url, corps }) {
  return `<!doctype html>
<html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${echapper(titre)}</title>
<meta name="description" content="${echapper(description)}">
<meta property="og:type" content="website">
<meta property="og:site_name" content="Harambee">
<meta property="og:title" content="${echapper(titre)}">
<meta property="og:description" content="${echapper(description)}">
${image ? `<meta property="og:image" content="${echapper(image)}">` : ''}
${url ? `<meta property="og:url" content="${echapper(url)}">` : ''}
<meta name="twitter:card" content="${image ? 'summary_large_image' : 'summary'}">
<style>${STYLE}</style></head>
<body><main><p class="marque">Harambee</p>${corps}</main></body></html>`;
}

function boutonsStores() {
  const liens = [];
  if (LIENS_STORES.appStore) {
    liens.push(`<a class="bouton secondaire" href="${echapper(LIENS_STORES.appStore)}">Télécharger sur l'App Store</a>`);
  }
  if (LIENS_STORES.googlePlay) {
    liens.push(`<a class="bouton secondaire" href="${echapper(LIENS_STORES.googlePlay)}">Télécharger sur Google Play</a>`);
  }
  if (liens.length === 0) {
    return '<p class="note">Harambee arrive bientôt sur l\'App Store et Google Play.</p>';
  }
  return liens.join('\n');
}

/**
 * Page d'un commerce publié. [commerce] : données Firestore ; [url] : adresse
 * de cette page (pour les aperçus de lien).
 */
export function pageCommerce(id, commerce, url) {
  const categorie = CATEGORIES[commerce.categorie] ?? '';
  const lieu = [categorie, commerce.ville].filter(Boolean).join(' · ');
  const image = Array.isArray(commerce.photos) ? commerce.photos[0] : null;
  const description = extrait(commerce.description, 200)
    || `${lieu} — à découvrir sur Harambee.`;
  const labels = [
    commerce.labelAfricain ? '<li>Africain</li>' : '',
    commerce.labelChretien ? '<li>Chrétien</li>' : '',
  ].join('');
  const nbAvis = Number(commerce.nbAvis ?? 0);
  const note = nbAvis > 0
    ? `<p class="meta">★ ${Number(commerce.noteMoyenne ?? 0).toFixed(1).replace('.', ',')} · ${nbAvis} avis</p>`
    : '';

  const corps = `<article class="carte">
${image ? `<img class="photo" src="${echapper(image)}" alt="">` : ''}
<div class="contenu">
<h1>${echapper(commerce.nom)}</h1>
<p class="meta">${echapper(lieu)}</p>
${labels ? `<ul class="labels">${labels}</ul>` : ''}
${note}
${commerce.description ? `<p>${echapper(extrait(commerce.description, 600))}</p>` : ''}
${commerce.adresse ? `<p class="meta">${echapper(commerce.adresse)}</p>` : ''}
${/^https?:\/\//i.test(commerce.siteWeb ?? '') ? `<a class="bouton secondaire" href="${echapper(commerce.siteWeb)}" rel="noopener nofollow">Site web du commerce</a>` : ''}
<a class="bouton principal" href="${echapper(lienApp(id))}">Ouvrir dans l'app Harambee</a>
${boutonsStores()}
</div></article>
<p class="note">Harambee — les commerces africains et chrétiens près de chez vous.</p>`;

  return page({ titre: `${commerce.nom} · Harambee`, description, image, url, corps });
}

/** Page affichée quand le commerce n'existe pas ou n'est pas publié. */
export function pageIntrouvable() {
  const corps = `<article class="carte"><div class="contenu">
<h1>Commerce introuvable</h1>
<p class="meta">Ce commerce n'est plus disponible sur Harambee.</p>
${boutonsStores()}
</div></article>`;
  return page({
    titre: 'Harambee',
    description: 'Les commerces africains et chrétiens près de chez vous.',
    corps,
  });
}
