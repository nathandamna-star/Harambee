import assert from 'node:assert/strict';
import { after, beforeEach, describe, it } from 'node:test';
import { deleteApp, initializeApp } from 'firebase/app';
import {
  connectFirestoreEmulator, deleteDoc, doc, getDoc, getFirestore, setDoc, updateDoc,
} from 'firebase/firestore';

// Écritures directes dans l'émulateur, en contournant les règles
// (jeton « owner ») : on teste ici la fonction, pas les règles.
const PROJET = 'demo-harambee';
const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'notes');
const db = getFirestore(app);
connectFirestoreEmulator(db, '127.0.0.1', 8080, { mockUserToken: 'owner' });

async function vider() {
  await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJET}/databases/(default)/documents`, { method: 'DELETE' });
}

/// Attend que la fonction ait mis à jour le commerce.
async function attendreNote(attendu) {
  for (let i = 0; i < 50; i++) {
    const d = (await getDoc(doc(db, 'commerces/c1'))).data();
    if (d.nbAvis === attendu.nbAvis && d.noteMoyenne === attendu.noteMoyenne) return d;
    await new Promise((r) => setTimeout(r, 200));
  }
  const d = (await getDoc(doc(db, 'commerces/c1'))).data();
  assert.deepEqual({ nbAvis: d.nbAvis, noteMoyenne: d.noteMoyenne }, attendu);
}

after(async () => { await deleteApp(app); });

describe('note moyenne', () => {
  beforeEach(async () => {
    await vider();
    await setDoc(doc(db, 'commerces/c1'), { nom: 'Chez Mama', statut: 'publie', noteMoyenne: 0, nbAvis: 0 });
  });

  it('suit les ajouts, modifications et suppressions d\'avis', async () => {
    await setDoc(doc(db, 'commerces/c1/avis/a'), { auteur: 'a', note: 5 });
    await attendreNote({ nbAvis: 1, noteMoyenne: 5 });

    await setDoc(doc(db, 'commerces/c1/avis/b'), { auteur: 'b', note: 4 });
    await setDoc(doc(db, 'commerces/c1/avis/c'), { auteur: 'c', note: 4 });
    await attendreNote({ nbAvis: 3, noteMoyenne: 4.3 });

    await updateDoc(doc(db, 'commerces/c1/avis/a'), { note: 1 });
    await attendreNote({ nbAvis: 3, noteMoyenne: 3 });

    await deleteDoc(doc(db, 'commerces/c1/avis/a'));
    await deleteDoc(doc(db, 'commerces/c1/avis/b'));
    await deleteDoc(doc(db, 'commerces/c1/avis/c'));
    await attendreNote({ nbAvis: 0, noteMoyenne: 0 });
  });
});
