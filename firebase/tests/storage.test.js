import { after, afterEach, before, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';
import { commerceValide, creerEnvironnement, preparer } from './outils.js';

let env;
const stockage = (uid) => (uid
  ? env.authenticatedContext(uid).storage()
  : env.unauthenticatedContext().storage());

const image = new Uint8Array([0x89, 0x50, 0x4e, 0x47]);
const typeImage = { contentType: 'image/png' };

before(async () => {
  env = await creerEnvironnement();
});
afterEach(async () => {
  await env.clearStorage();
  await env.clearFirestore();
});
after(async () => { await env.cleanup(); });

async function base() {
  await preparer(env, {
    'commerces/c1': commerceValide('pro1', { statut: 'publie' }),
    'conversations/c1__client1': { participants: ['client1', 'pro1'] },
  });
}

describe('photos de commerce', () => {
  it('le propriétaire envoie une image, tout le monde la voit', async () => {
    await base();
    await assertSucceeds(uploadBytes(ref(stockage('pro1'), 'commerces/c1/photo.png'), image, typeImage));
    await assertSucceeds(getBytes(ref(stockage(null), 'commerces/c1/photo.png')));
    await assertSucceeds(deleteObject(ref(stockage('pro1'), 'commerces/c1/photo.png')));
  });

  it('un autre utilisateur ne peut pas envoyer de photo', async () => {
    await base();
    await assertFails(uploadBytes(ref(stockage('pro2'), 'commerces/c1/photo.png'), image, typeImage));
    await assertFails(uploadBytes(ref(stockage(null), 'commerces/c1/photo.png'), image, typeImage));
  });

  it('images uniquement, 5 Mo maximum', async () => {
    await base();
    await assertFails(uploadBytes(ref(stockage('pro1'), 'commerces/c1/doc.pdf'), image,
      { contentType: 'application/pdf' }));
    const grosse = new Uint8Array(5 * 1024 * 1024 + 1);
    await assertFails(uploadBytes(ref(stockage('pro1'), 'commerces/c1/grosse.png'), grosse, typeImage));
  });
});

describe('autres fichiers', () => {
  it('photo de profil : seulement la sienne', async () => {
    await assertSucceeds(uploadBytes(ref(stockage('client1'), 'users/client1/profil.png'), image, typeImage));
    await assertFails(uploadBytes(ref(stockage('client2'), 'users/client1/profil.png'), image, typeImage));
  });

  it('photos de conversation : participants seulement', async () => {
    await base();
    await assertSucceeds(uploadBytes(ref(stockage('client1'), 'conversations/c1__client1/a.png'), image, typeImage));
    await assertSucceeds(getBytes(ref(stockage('pro1'), 'conversations/c1__client1/a.png')));
    await assertFails(getBytes(ref(stockage('client2'), 'conversations/c1__client1/a.png')));
    await assertFails(uploadBytes(ref(stockage('client2'), 'conversations/c1__client1/b.png'), image, typeImage));
  });

  it('tout autre emplacement est refusé', async () => {
    await assertFails(uploadBytes(ref(stockage('client1'), 'divers/x.png'), image, typeImage));
  });
});
