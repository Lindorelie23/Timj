# AIA Connect (Aire Information et Analyse)

AIA Connect est une plateforme **hybride** conçue pour la Protection Civile afin de centraliser:

- la collecte des rapports d'incidents/catastrophes depuis les départements,
- la coordination des besoins et réponses,
- la communication interne (chat par département),
- l'ingestion de rapports via **SMS** (quand Internet n'est pas disponible).

Cette solution est pensée pour un contexte sans serveur local:

- **Frontend**: Flutter (Android + Windows, prêt pour Play Store et Microsoft Store)
- **Backend serverless**: Firebase (Firestore + Cloud Functions)
- **Canal SMS**: webhook Twilio (ou autre passerelle SMS compatible webhook)

---

## 1) Architecture

```text
Départements (Mobile/Windows/SMS)
        |
        | Flutter App / SMS
        v
Firebase Authentication  -----> Firestore (reports, chats, departments)
        |
        v
Cloud Functions (API + SMS webhook + validation)
```

### Pourquoi c'est "unique" (et pas un clone Kobo)
- Workflow centré **opérations de réponse** (besoins + actions) et pas seulement collecte de formulaires.
- **Double canal** natif: app connectée + SMS structuré hors-ligne réseau.
- **Tableau d'activité temps réel** pour AIA et chat opérationnel intégré.

---

## 2) Format SMS recommandé

Un département peut envoyer un SMS sous ce format:

```text
AIA#DEPT=Nord#TYPE=Inondation#SEV=4#LOC=Cap-Haitien#BESOIN=Pompes,eau,abris#DETAIL=Riviere en crue
```

La Cloud Function convertit ce SMS en rapport Firestore.

---

## 3) Démarrage rapide

### Prérequis
- Flutter SDK 3.22+
- Node.js 20+
- Firebase CLI
- Projet Firebase créé

### Installer l'application Flutter
```bash
cd app
flutter pub get
```

### Configurer Firebase côté Flutter
1. Créer `app/lib/firebase_options.dart` avec FlutterFire CLI:
   ```bash
   flutterfire configure
   ```
2. Activer Authentication (Email/Password) et Firestore dans Firebase Console.

### Installer les fonctions Cloud
```bash
cd functions
npm install
npm run build
```

### Déployer
```bash
firebase deploy --only firestore:rules,firestore:indexes,functions
```

---

## 4) Publier sur Play Store et Microsoft Store

### Android (Play Store)
```bash
cd app
flutter build appbundle --release
```
Publier le `.aab` dans Google Play Console.

### Windows (Microsoft Store)
```bash
cd app
flutter config --enable-windows-desktop
flutter build windows --release
```
Ensuite empaqueter en MSIX (ex: `msix` package) pour Microsoft Partner Center.

---

## 5) Sécurité minimale
- Règles Firestore limitent l'accès par utilisateur authentifié.
- Cloud Functions vérifient et normalisent les payloads SMS.
- Évolutions recommandées: rôles IAM, audit log, chiffrement des données sensibles.

---

## 6) Prochaines évolutions
- Cartographie SIG (Leaflet/Mapbox/Google Maps)
- Priorisation automatique des interventions (score impact)
- Export PDF/Excel pour rapports quotidiens AIA
- Intégration passerelles SMS locales selon l'opérateur

