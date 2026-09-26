import { after, afterEach, before, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  arrayUnion, collection, deleteDoc, doc, documentId, getDoc, getDocs, limit,
  orderBy, query, serverTimestamp, setDoc, updateDoc, where,
} from 'firebase/firestore';
import { commerceValide, creerEnvironnement, preparer } from './outils.js';

let env;
const client = () => env.authenticatedContext('client1').firestore();
const client2 = () => env.authenticatedContext('client2').firestore();
const pro = () => env.authenticatedContext('pro1').firestore();
const autrePro = () => env.authenticatedContext('pro2').firestore();
const admin = () => env.authenticatedContext('admin1', { admin: true }).firestore();
const visiteur = () => env.unauthenticatedContext().firestore();

const base = {
  'users/client1': { nom: 'Awa', role: 'client', favoris: [] },
  'users/client2': { nom: 'Kofi', role: 'client', favoris: [] },
  'users/pro1': { nom: 'Mama', role: 'pro', favoris: [] },
  'users/pro2': { nom: 'Jean', role: 'pro', favoris: [] },
  'commerces/publie': commerceValide('pro1', { statut: 'publie' }),
  'commerces/attente': commerceValide('pro1'),
  'commerces/publie/produits/p1': { nom: 'Attiéké', prix: 8, devise: 'EUR', publie: true },
  'commerces/publie/produits/cache': { nom: 'Secret', prix: 5, devise: 'EUR', publie: false },
};

before(async () => { env = await creerEnvironnement(); });
afterEach(async () => { await env.clearFirestore(); });
after(async () => { await env.cleanup(); });

describe('utilisateurs', () => {
  it('chacun crée son propre profil client ou pro', async () => {
    await assertSucceeds(setDoc(doc(client(), 'users/client1'), {
      nom: 'Awa', email: 'a@x.com', role: 'client', langue: 'fr', favoris: [],
      createdAt: serverTimestamp(),
    }));
    await assertSucceeds(setDoc(doc(pro(), 'users/pro1'), {
      nom: 'Mama', role: 'pro', favoris: [],
    }));
  });

  it('personne ne se déclare admin', async () => {
    await assertFails(setDoc(doc(client(), 'users/client1'), {
      nom: 'Awa', role: 'admin', favoris: [],
    }));
  });

  it('on ne crée pas le profil d\'un autre', async () => {
    await assertFails(setDoc(doc(client(), 'users/client2'), {
      nom: 'X', role: 'client', favoris: [],
    }));
  });

  it('un profil n\'est lisible que par son titulaire et les admins', async () => {
    await preparer(env, base);
    await assertSucceeds(getDoc(doc(client(), 'users/client1')));
    await assertSucceeds(getDoc(doc(admin(), 'users/client1')));
    await assertFails(getDoc(doc(client2(), 'users/client1')));
    await assertFails(getDoc(doc(visiteur(), 'users/client1')));
  });

  it('rôle : client → pro autorisé, pro → admin refusé', async () => {
    await preparer(env, base);
    await assertSucceeds(updateDoc(doc(client(), 'users/client1'), { role: 'pro' }));
    await assertFails(updateDoc(doc(pro(), 'users/pro1'), { role: 'admin' }));
  });

  it('on gère ses favoris et on supprime son compte', async () => {
    await preparer(env, base);
    await assertSucceeds(updateDoc(doc(client(), 'users/client1'), { favoris: ['publie'] }));
    await assertSucceeds(deleteDoc(doc(client(), 'users/client1')));
  });
});

describe('commerces', () => {
  it('tout le monde lit un commerce publié', async () => {
    await preparer(env, base);
    await assertSucceeds(getDoc(doc(visiteur(), 'commerces/publie')));
    await assertSucceeds(getDocs(query(
      collection(visiteur(), 'commerces'), where('statut', '==', 'publie'))));
  });

  it('un commerce en vérification : propriétaire et admin seulement', async () => {
    await preparer(env, base);
    await assertFails(getDoc(doc(visiteur(), 'commerces/attente')));
    await assertFails(getDoc(doc(client(), 'commerces/attente')));
    await assertFails(getDoc(doc(autrePro(), 'commerces/attente')));
    await assertSucceeds(getDoc(doc(pro(), 'commerces/attente')));
    await assertSucceeds(getDoc(doc(admin(), 'commerces/attente')));
  });

  it('lister tous les commerces sans filtre est refusé', async () => {
    await preparer(env, base);
    await assertFails(getDocs(collection(visiteur(), 'commerces')));
  });

  it('un pro crée un commerce « en vérification » à son nom', async () => {
    await preparer(env, base);
    await assertSucceeds(setDoc(doc(pro(), 'commerces/nouveau'), commerceValide('pro1')));
  });

  it('création refusée : déjà publié, au nom d\'un autre, ou par un client', async () => {
    await preparer(env, base);
    await assertFails(setDoc(doc(pro(), 'commerces/n1'),
      commerceValide('pro1', { statut: 'publie' })));
    await assertFails(setDoc(doc(pro(), 'commerces/n2'), commerceValide('pro2')));
    await assertFails(setDoc(doc(client(), 'commerces/n3'), commerceValide('client1')));
    await assertFails(setDoc(doc(pro(), 'commerces/n4'),
      commerceValide('pro1', { noteMoyenne: 5, nbAvis: 100 })));
  });

  it('le propriétaire modifie sa fiche mais pas statut, labels ni note', async () => {
    await preparer(env, base);
    const ref = doc(pro(), 'commerces/attente');
    await assertSucceeds(updateDoc(ref, { description: 'Nouvelle description' }));
    await assertFails(updateDoc(ref, { statut: 'publie' }));
    await assertFails(updateDoc(ref, { labelChretien: true }));
    await assertFails(updateDoc(ref, { noteMoyenne: 5 }));
    await assertFails(updateDoc(ref, { proprietaire: 'pro2' }));
  });

  it('personne d\'autre ne modifie la fiche', async () => {
    await preparer(env, base);
    await assertFails(updateDoc(doc(autrePro(), 'commerces/publie'), { nom: 'Pirate' }));
    await assertFails(updateDoc(doc(client(), 'commerces/publie'), { nom: 'Pirate' }));
  });

  it('l\'admin publie, attribue les labels, suspend', async () => {
    await preparer(env, base);
    const ref = doc(admin(), 'commerces/attente');
    await assertSucceeds(updateDoc(ref, { statut: 'publie', labelChretien: true }));
    await assertSucceeds(updateDoc(ref, { statut: 'suspendu', motifRefus: 'Signalements' }));
    await assertFails(updateDoc(ref, { statut: 'n_importe_quoi' }));
    await assertFails(updateDoc(ref, { nom: 'Modifié par admin' }));
  });
});

describe('écritures faites par l\'app (mêmes champs que le code Dart)', () => {
  it('création de fiche, ajout des photos, modification', async () => {
    await preparer(env, base);
    const ref = doc(pro(), 'commerces/app1');
    await assertSucceeds(setDoc(ref, {
      nom: 'Maquis', categorie: 'restaurant', description: '', photos: [],
      adresse: 'Cocody', geo: null, geohash: null, pays: 'CI', ville: 'Abidjan',
      continent: 'afrique', horaires: { lundi: ['09:00-19:00'] }, telephone: null,
      devise: 'XOF', charteSigneeLe: null, labelAfricain: true, labelChretien: false,
      statut: 'en_verification', proprietaire: 'pro1', noteMoyenne: 0, nbAvis: 0,
      createdAt: serverTimestamp(), updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(updateDoc(ref, { photos: ['https://exemple/p.jpg'] }));
    await assertSucceeds(updateDoc(ref, {
      nom: 'Maquis Awa', categorie: 'restaurant', description: 'Bon', photos: [],
      adresse: 'Cocody', geo: null, geohash: null, pays: 'CI', ville: 'Abidjan',
      continent: 'afrique', horaires: {}, telephone: '+225', devise: 'XOF',
      charteSigneeLe: null, updatedAt: serverTimestamp(),
    }));
  });

  it('client qui passe en pro', async () => {
    await preparer(env, base);
    await assertSucceeds(updateDoc(doc(client(), 'users/client1'), { role: 'pro' }));
  });

  it('profil créé à la première connexion', async () => {
    await assertSucceeds(setDoc(doc(client(), 'users/client1'), {
      nom: 'Awa', email: 'a@x.com', photoUrl: null, role: 'client', langue: 'fr',
      ville: null, pays: null, favoris: [], createdAt: serverTimestamp(),
    }));
  });

  it('produit : création, réordonnancement, rupture', async () => {
    await preparer(env, base);
    const ref = doc(pro(), 'commerces/publie/produits/app');
    await assertSucceeds(setDoc(ref, {
      nom: 'Alloco', description: '', photoUrl: null, prix: 4.5, devise: 'EUR',
      publie: true, enRupture: false, ordre: 3,
      updatedAt: serverTimestamp(), createdAt: serverTimestamp(),
    }));
    await assertSucceeds(updateDoc(ref, { ordre: 0 }));
    await assertSucceeds(updateDoc(ref, { enRupture: true, updatedAt: serverTimestamp() }));
  });
});

describe('lectures et écritures des clients (Explorer, fiche, favoris)', () => {
  it('recherche filtrée sur les commerces publiés', async () => {
    await preparer(env, base);
    await assertSucceeds(getDocs(query(collection(visiteur(), 'commerces'),
      where('statut', '==', 'publie'), where('continent', '==', 'europe'),
      where('categorie', '==', 'restaurant'), where('labelAfricain', '==', true),
      where('motsCles', 'array-contains', 'ma'), limit(30))));
  });

  it('« près de moi » : zone geohash des commerces publiés', async () => {
    await preparer(env, base);
    await assertSucceeds(getDocs(query(collection(visiteur(), 'commerces'),
      where('statut', '==', 'publie'), where('geohash', '>=', 's0'),
      where('geohash', '<', 's0~'))));
    await assertFails(getDocs(query(collection(visiteur(), 'commerces'),
      where('geohash', '>=', 's0'), where('geohash', '<', 's0~'))));
  });

  it('favoris : lecture par identifiants et ajout', async () => {
    await preparer(env, base);
    await assertSucceeds(getDocs(query(collection(client(), 'commerces'),
      where(documentId(), 'in', ['publie']), where('statut', '==', 'publie'))));
    await assertSucceeds(updateDoc(doc(client(), 'users/client1'), { favoris: arrayUnion('publie') }));
  });

  it('produits visibles et avis d\'une fiche', async () => {
    await preparer(env, base);
    await assertSucceeds(getDocs(query(collection(visiteur(), 'commerces/publie/produits'),
      where('publie', '==', true))));
    await assertSucceeds(getDocs(query(collection(visiteur(), 'commerces/publie/avis'),
      orderBy('createdAt', 'desc'), limit(50))));
  });

  it('avis : création puis modification comme dans l\'app', async () => {
    await preparer(env, base);
    const ref = doc(client(), 'commerces/publie/avis/client1');
    await assertSucceeds(setDoc(ref, {
      auteur: 'client1', auteurNom: 'Awa', note: 4, texte: 'Bon', createdAt: serverTimestamp(),
    }));
    await assertSucceeds(updateDoc(ref, { note: 2, texte: 'Moins bien', updatedAt: serverTimestamp() }));
  });

  it('signalement comme dans l\'app', async () => {
    await preparer(env, base);
    await assertSucceeds(setDoc(doc(client(), 'signalements/x'), {
      auteur: 'client1', cible: 'commerce', cibleId: 'publie', motif: 'Faux',
      traite: false, createdAt: serverTimestamp(),
    }));
  });
});

describe('produits', () => {
  it('produits publiés visibles de tous, produits masqués du seul propriétaire', async () => {
    await preparer(env, base);
    await assertSucceeds(getDoc(doc(visiteur(), 'commerces/publie/produits/p1')));
    await assertFails(getDoc(doc(visiteur(), 'commerces/publie/produits/cache')));
    await assertSucceeds(getDoc(doc(pro(), 'commerces/publie/produits/cache')));
  });

  it('seul le propriétaire ajoute, modifie, supprime', async () => {
    await preparer(env, base);
    const produit = { nom: 'Alloco', prix: 4.5, devise: 'EUR', publie: true, ordre: 1 };
    await assertSucceeds(setDoc(doc(pro(), 'commerces/publie/produits/p2'), produit));
    await assertSucceeds(updateDoc(doc(pro(), 'commerces/publie/produits/p1'), { enRupture: true }));
    await assertSucceeds(deleteDoc(doc(pro(), 'commerces/publie/produits/cache')));
    await assertFails(setDoc(doc(autrePro(), 'commerces/publie/produits/p3'), produit));
    await assertFails(updateDoc(doc(client(), 'commerces/publie/produits/p1'), { prix: 0 }));
  });

  it('prix négatif ou devise inconnue refusés', async () => {
    await preparer(env, base);
    await assertFails(setDoc(doc(pro(), 'commerces/publie/produits/x'),
      { nom: 'X', prix: -1, devise: 'EUR', publie: true }));
    await assertFails(setDoc(doc(pro(), 'commerces/publie/produits/y'),
      { nom: 'Y', prix: 3, devise: 'BTC', publie: true }));
  });
});

describe('avis', () => {
  const avis = (auteur, note = 5) => ({ auteur, note, texte: 'Très bon !' });

  it('un client laisse un avis (identifiant = son uid)', async () => {
    await preparer(env, base);
    await assertSucceeds(setDoc(doc(client(), 'commerces/publie/avis/client1'), avis('client1')));
    await assertSucceeds(getDoc(doc(visiteur(), 'commerces/publie/avis/client1')));
  });

  it('un seul avis par personne : impossible sous un autre identifiant', async () => {
    await preparer(env, base);
    await assertFails(setDoc(doc(client(), 'commerces/publie/avis/autre'), avis('client1')));
  });

  it('note entre 1 et 5, pas d\'avis sur son propre commerce ni sur un non publié', async () => {
    await preparer(env, base);
    await assertFails(setDoc(doc(client(), 'commerces/publie/avis/client1'), avis('client1', 6)));
    await assertFails(setDoc(doc(client(), 'commerces/publie/avis/client1'), avis('client1', 0)));
    await assertFails(setDoc(doc(pro(), 'commerces/publie/avis/pro1'), avis('pro1')));
    await assertFails(setDoc(doc(client(), 'commerces/attente/avis/client1'), avis('client1')));
  });

  it('seul l\'auteur modifie son avis', async () => {
    await preparer(env, { ...base, 'commerces/publie/avis/client1': avis('client1', 4) });
    await assertSucceeds(updateDoc(doc(client(), 'commerces/publie/avis/client1'), { note: 3 }));
    await assertFails(updateDoc(doc(client2(), 'commerces/publie/avis/client1'), { note: 1 }));
    await assertFails(updateDoc(doc(pro(), 'commerces/publie/avis/client1'), { note: 1 }));
  });

  it('la note moyenne n\'est pas modifiable par l\'app', async () => {
    await preparer(env, base);
    await assertFails(updateDoc(doc(client(), 'commerces/publie'), { noteMoyenne: 5, nbAvis: 1 }));
  });
});

describe('messagerie', () => {
  const conv = {
    commerceId: 'publie', commerceNom: 'Chez Mama', clientId: 'client1', proId: 'pro1',
    participants: ['client1', 'pro1'], dernierMessage: '', nonLusClient: 0, nonLusPro: 0,
  };

  it('un client ouvre une conversation avec un commerce', async () => {
    await preparer(env, base);
    await assertSucceeds(setDoc(doc(client(), 'conversations/publie__client1'), conv));
  });

  it('impossible d\'ouvrir une conversation au nom d\'un autre ou avec un faux pro', async () => {
    await preparer(env, base);
    await assertFails(setDoc(doc(client2(), 'conversations/publie__client1'), conv));
    await assertFails(setDoc(doc(client(), 'conversations/publie__client1'),
      { ...conv, proId: 'client2', participants: ['client1', 'client2'] }));
  });

  it('seuls les participants lisent et écrivent', async () => {
    await preparer(env, { ...base, 'conversations/publie__client1': conv });
    const msg = (auteur) => ({ auteur, texte: 'Bonjour', createdAt: serverTimestamp() });
    await assertSucceeds(getDoc(doc(client(), 'conversations/publie__client1')));
    await assertSucceeds(getDoc(doc(pro(), 'conversations/publie__client1')));
    await assertFails(getDoc(doc(client2(), 'conversations/publie__client1')));
    await assertFails(getDoc(doc(admin(), 'conversations/publie__client1')));

    await assertSucceeds(setDoc(
      doc(client(), 'conversations/publie__client1/messages/m1'), msg('client1')));
    await assertSucceeds(setDoc(
      doc(pro(), 'conversations/publie__client1/messages/m2'), msg('pro1')));
    await assertFails(setDoc(
      doc(client2(), 'conversations/publie__client1/messages/m3'), msg('client2')));
    await assertFails(setDoc(
      doc(client(), 'conversations/publie__client1/messages/m4'), msg('pro1')));
    await assertFails(getDoc(doc(client2(), 'conversations/publie__client1/messages/m1')));
  });

  it('un message envoyé ne se modifie pas', async () => {
    await preparer(env, {
      ...base,
      'conversations/publie__client1': conv,
      'conversations/publie__client1/messages/m1': { auteur: 'client1', texte: 'Salut' },
    });
    await assertFails(updateDoc(
      doc(client(), 'conversations/publie__client1/messages/m1'), { texte: 'Modifié' }));
  });
});

describe('signalements', () => {
  const signalement = { auteur: 'client1', cible: 'avis', cibleId: 'x', motif: 'Insultant', traite: false };

  it('un utilisateur signale, seul l\'admin lit et traite', async () => {
    await preparer(env, base);
    await assertSucceeds(setDoc(doc(client(), 'signalements/s1'), signalement));
    await assertFails(getDoc(doc(client(), 'signalements/s1')));
    await assertSucceeds(getDoc(doc(admin(), 'signalements/s1')));
    await assertSucceeds(updateDoc(doc(admin(), 'signalements/s1'), { traite: true }));
  });

  it('pas de signalement anonyme ou au nom d\'un autre', async () => {
    await assertFails(setDoc(doc(visiteur(), 'signalements/s2'), signalement));
    await assertFails(setDoc(doc(client2(), 'signalements/s3'), signalement));
  });
});

describe('commandes', () => {
  const commande = (statut = 'nouvelle') => ({
    commerceId: 'publie', clientId: 'client1', proId: 'pro1', statut,
    sousTotal: 20, total: 22.5, devise: 'EUR', historique: [],
  });

  it('l\'app ne peut pas créer de commande (Cloud Function uniquement)', async () => {
    await preparer(env, base);
    await assertFails(setDoc(doc(client(), 'commandes/c1'), commande()));
  });

  it('lisible par le client, le commerce et l\'admin seulement', async () => {
    await preparer(env, { ...base, 'commandes/c1': commande() });
    await assertSucceeds(getDoc(doc(client(), 'commandes/c1')));
    await assertSucceeds(getDoc(doc(pro(), 'commandes/c1')));
    await assertSucceeds(getDoc(doc(admin(), 'commandes/c1')));
    await assertFails(getDoc(doc(client2(), 'commandes/c1')));
    await assertFails(getDoc(doc(autrePro(), 'commandes/c1')));
  });

  it('le client annule seulement une commande « nouvelle »', async () => {
    await preparer(env, {
      ...base, 'commandes/c1': commande(), 'commandes/c2': commande('acceptee'),
    });
    await assertSucceeds(updateDoc(doc(client(), 'commandes/c1'), { statut: 'annulee' }));
    await assertFails(updateDoc(doc(client(), 'commandes/c2'), { statut: 'annulee' }));
  });

  it('le client ne touche pas aux montants ni aux statuts du commerce', async () => {
    await preparer(env, { ...base, 'commandes/c1': commande() });
    await assertFails(updateDoc(doc(client(), 'commandes/c1'), { total: 1 }));
    await assertFails(updateDoc(doc(client(), 'commandes/c1'), { statut: 'livree' }));
  });

  it('le commerce fait avancer la commande, sans changer les montants', async () => {
    await preparer(env, { ...base, 'commandes/c1': commande() });
    const ref = doc(pro(), 'commandes/c1');
    await assertSucceeds(updateDoc(ref, { statut: 'acceptee' }));
    await assertSucceeds(updateDoc(ref, { statut: 'en_preparation' }));
    await assertFails(updateDoc(ref, { total: 0 }));
    await assertFails(updateDoc(ref, { statut: 'annulee' }));
  });
});

describe('paramètres', () => {
  it('lisibles par tous, modifiables par l\'admin seulement', async () => {
    await preparer(env, { 'parametres/tarifs': { commission: 0.06 } });
    await assertSucceeds(getDoc(doc(visiteur(), 'parametres/tarifs')));
    await assertFails(updateDoc(doc(pro(), 'parametres/tarifs'), { commission: 0 }));
    await assertSucceeds(updateDoc(doc(admin(), 'parametres/tarifs'), { commission: 0.05 }));
  });
});

describe('par défaut', () => {
  it('toute autre collection est refusée', async () => {
    await assertFails(setDoc(doc(admin(), 'divers/x'), { a: 1 }));
    await assertFails(getDoc(doc(visiteur(), 'divers/x')));
  });
});
