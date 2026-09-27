import assert from 'node:assert/strict';
import { after, before, describe, it } from 'node:test';
import { deleteApp, initializeApp } from 'firebase/app';
import { connectFirestoreEmulator, doc, getFirestore, setDoc } from 'firebase/firestore';

const PROJET = 'demo-harambee';
const URL = `http://127.0.0.1:5001/${PROJET}/europe-west1/commerce`;

const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'page-commerce');
const db = getFirestore(app);
connectFirestoreEmulator(db, '127.0.0.1', 8080, { mockUserToken: 'owner' });

after(async () => { await deleteApp(app); });

describe('page publique d\'un commerce (émulateur)', () => {
  before(async () => {
    await setDoc(doc(db, 'commerces/publie1'), {
      nom: 'Épicerie Kinshasa', categorie: 'magasin', ville: 'Liège', statut: 'publie', photos: [],
    });
    await setDoc(doc(db, 'commerces/cache1'), {
      nom: 'Pas encore vérifié', categorie: 'magasin', ville: 'Liège', statut: 'en_verification',
    });
  });

  it('un commerce publié s\'affiche', async () => {
    const r = await fetch(`${URL}?id=publie1`);
    assert.equal(r.status, 200);
    const html = await r.text();
    assert.match(html, /Épicerie Kinshasa/);
    assert.match(html, /harambee:\/\/app\/explorer\/commerce\/publie1/);
  });

  it('non publié, inconnu ou identifiant invalide : introuvable', async () => {
    for (const id of ['cache1', 'absent', '../users/x', '']) {
      const r = await fetch(`${URL}?id=${encodeURIComponent(id)}`);
      assert.equal(r.status, 404, id);
      assert.match(await r.text(), /Commerce introuvable/);
    }
  });
});
