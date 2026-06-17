# Faso Covoiturage 🚗💨

> Plateforme de covoiturage au Burkina Faso — Connectez conducteurs et passagers de manière simple, sécurisée et économique.

## 🏗️ Architecture

```
faso-covoiturage/
├── 📱 mobile_flutter/          # Application mobile (Flutter)
├── 🔧 backend_api/              # API Backend (Node.js + Express + TypeScript)
├── 📚 docs/                     # Documentation
└── 🚀 scripts/                 # Scripts de déploiement
```

## 🛠️ Stack Technologique

| Couche | Technologies |
|--------|-------------|
| **Mobile** | Flutter 3.x, Riverpod, go_router, Dio, Hive |
| **Backend** | Node.js 20, Express 5, TypeScript, Zod |
| **Database** | Firebase Firestore |
| **Auth** | Firebase Auth + JWT |
| **Paiements** | Orange Money, Stripe |
| **Notifications** | Firebase Cloud Messaging |
| **CI/CD** | GitHub Actions |
| **Hosting** | Firebase Hosting |

## 🚀 Installation

### Backend (Local)

```bash
cd backend_api
cp .env.example .env
# Edit .env with your Firebase credentials
npm install
npm run dev
```

### Backend (Docker)

```bash
docker compose up -d
```

### Mobile (Flutter)

```bash
cd mobile_flutter
flutter pub get
flutter run
```

### Firebase Emulators (Dev)

```bash
cd backend_api
firebase emulators:start
```

## 📱 Build Mobile

```bash
# Android
flutter build apk --debug
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

## 🧪 Tests

```bash
# Backend
cd backend_api && npm test

# Mobile
cd mobile_flutter && flutter test
```

## 📂 Collections Firestore

- `users` — Profils utilisateurs
- `trips` — Trajets publiés
- `bookings` — Réservations
- `payments` — Transactions
- `reviews` — Notes
- `notifications` — Push notifications
- `reports` — Signalements

## 🔐 Rôles

| Rôle | Description |
|------|-------------|
| `passenger` | Recherche et réservation de trajets |
| `driver` | Publication et gestion de trajets |
| `admin` | Dashboard et modération |
| `agent_relay` | Support level 1 |

## 🌐 Environnements

| Env | URL |
|-----|-----|
| Dev (local) | `localhost:3000` |
| Staging | `staging.fasocovoiturage.bf` |
| Prod | `api.fasocovoiturage.bf` |

## 👥 Équipe

- **Lead Developer:** Abdoul Hamid COMPAORÉ — CO Digitale
- **Contact:** support@fasocovoiturage.bf

## 📄 Licence

MIT © Faso Covoiturage

---

**Faso Covoiturage** - Voyagez ensemble, économisez plus! 🚗💨