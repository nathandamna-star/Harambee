import { readFileSync } from 'node:fs';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

export async function creerEnvironnement() {
  return initializeTestEnvironment({
    projectId: 'demo-harambee',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
    storage: {
      rules: readFileSync(new URL('../storage.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 9199,
    },
  });
}

export function commerceValide(proprietaire, extra = {}) {
  return {
    nom: 'Chez Mama',
    categorie: 'restaurant',
    description: 'Cuisine ivoirienne',
    photos: [],
    adresse: '12 rue de la Paix, Lyon',
    pays: 'FR',
    ville: 'Lyon',
    continent: 'europe',
    telephone: '+33400000000',
    labelAfricain: true,
    labelChretien: false,
    charteSigneeLe: null,
    statut: 'en_verification',
    proprietaire,
    noteMoyenne: 0,
    nbAvis: 0,
    ...extra,
  };
}

/// Écrit des données de départ sans passer par les règles.
export async function preparer(env, donnees) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    for (const [chemin, valeur] of Object.entries(donnees)) {
      await db.doc(chemin).set(valeur);
    }
  });
}
