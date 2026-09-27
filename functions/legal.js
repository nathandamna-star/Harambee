// Pages légales publiées sur le web (URL exigées par l'App Store et Google
// Play). Mêmes textes que dans l'app (assets/legal/, copiés dans legal/).

const echapper = (t) => t.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

/** Convertit le format simple des pages (# ## - >) en HTML. */
export function versHtml(texte, titre) {
  const lignes = texte.split('\n');
  const corps = [];
  let liste = false;
  for (const ligne of lignes) {
    const estPuce = ligne.startsWith('- ');
    if (liste && !estPuce) { corps.push('</ul>'); liste = false; }
    if (ligne.startsWith('# ')) corps.push(`<h1>${echapper(ligne.slice(2))}</h1>`);
    else if (ligne.startsWith('## ')) corps.push(`<h2>${echapper(ligne.slice(3))}</h2>`);
    else if (ligne.startsWith('> ')) corps.push(`<aside>${echapper(ligne.slice(2))}</aside>`);
    else if (estPuce) {
      if (!liste) { corps.push('<ul>'); liste = true; }
      corps.push(`<li>${echapper(ligne.slice(2))}</li>`);
    } else if (ligne.trim()) corps.push(`<p>${echapper(ligne)}</p>`);
  }
  if (liste) corps.push('</ul>');
  return `<!doctype html>
<html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${echapper(titre)} · Harambee</title>
<style>
:root{--fond:#F6F1E7;--texte:#1E1B16;--second:#5E574C;--accent:#B4451F;--carte:#FFFDF8}
@media (prefers-color-scheme:dark){:root{--fond:#17140F;--texte:#F1EBE0;--second:#B9B0A2;--accent:#E08A64;--carte:#221E18}}
body{background:var(--fond);color:var(--texte);font:16px/1.6 -apple-system,system-ui,sans-serif;margin:0;padding:24px 16px}
main{max-width:720px;margin:0 auto}
h1{color:var(--accent);font-size:1.6rem;line-height:1.25}
h2{font-size:1.15rem;margin-top:1.8em}
aside{background:var(--carte);border-left:4px solid var(--accent);padding:12px 16px;border-radius:8px;color:var(--second)}
</style></head>
<body><main>${corps.join('\n')}</main></body></html>`;
}
