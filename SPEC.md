# Faso Covoiturage - Spécification Technique

## 1. Vue d'ensemble

**Nom du projet:** Faso Covoiturage
**Description:** Plateforme de covoiturage connectant conducteurs et passagers au Burkina Faso de manière simple, sécurisée et économique.
**Type:** Application mobile (iOS/Android) + Backend API + Future Web App

---

## 2. Stack Technologique

### Mobile (Flutter)
- **Framework:** Flutter 3.x
- **Langage:** Dart 3.x
- **State Management:** Riverpod
- **Navigation:** go_router
- **HTTP Client:** Dio avec interceptors
- **Cache Local:** Hive (offline-first)
- **Auth:** Firebase Auth (OTP + Email)
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Maps:** google_maps_flutter

### Backend (Node.js)
- **Runtime:** Node.js 20 LTS
- **Framework:** Express 5
- **Langage:** TypeScript 5.x
- **API Style:** RESTful, versionnée (/v1)
- **Database:** Firebase Firestore
- **Auth:** Firebase Admin SDK + JWT
- **Validation:** Zod
- **Rate Limiting:** express-rate-limit
- **Logging:** Winston

### Infrastructure
- **Hosting:** Firebase Hosting + Cloud Functions
- **Database:** Firebase Firestore (production)
- **CI/CD:** GitHub Actions
- **Containerisation:** Docker + Docker Compose

---

## 3. Architecture

### Clean Architecture (Mobile)

```
lib/
├── core/                    # Configuration & Infrastructure
│   ├── constants/           # Constantes (API URLs, keys)
│   ├── theme/               # Thèmes, couleurs, typographie
│   ├── routing/             # Navigation (go_router)
│   ├── network/             # Dio HTTP client
│   ├── cache/               # Hive service
│   ├── di/                  # Riverpod providers
│   ├── errors/              # Exceptions custom
│   └── utils/               # Helpers (validators, formatters)
├── features/                # Modules fonctionnels
│   ├── auth/
│   ├── passenger/
│   ├── driver/
│   ├── payment/
│   └── admin/
└── shared/                  # Widgets & utils partagés
    ├── widgets/
    └── utils/
```

### Backend API

```
backend_api/
├── src/
│   ├── config/              # Firebase, env
│   ├── controllers/         # Route handlers
│   ├── middleware/          # Auth, rate limit, errors
│   ├── routes/              # API routes
│   ├── services/            # Business logic
│   ├── types/               # TypeScript interfaces
│   └── utils/               # Helpers
├── tests/
└── scripts/
```

---

## 4. Collections Firestore

| Collection | Description | Index |
|-----------|-------------|-------|
| `users` | Profils utilisateurs (passenger, driver, admin) | email, phone |
| `trips` | Trajets publiés | origin, destination, date, driverId |
| `bookings` | Réservations | tripId, passengerId, status |
| `payments` | Transactions | bookingId, method, status |
| `reviews` | Notes driver/passenger | userId, tripId |
| `notifications` | Push notifications | userId, createdAt |
| `reports` | Signalements | reporterId, reportedUserId |

---

## 5. Rôles Utilisateurs (RBAC)

| Rôle | Permissions |
|------|-------------|
| `passenger` | Rechercher trips, réserver, noter driver |
| `driver` | Publier trips, gérer bookings, noter passenger |
| `admin` | Dashboard stats, gestion users/trips, modération |
| `agent_relay` | Support level 1, modération |

---

## 6. API Endpoints

### Auth
- `POST /v1/auth/phone/send` — Envoi OTP
- `POST /v1/auth/phone/verify` — Vérification OTP
- `POST /v1/auth/email/register` — Inscription email
- `POST /v1/auth/email/login` — Connexion email
- `POST /v1/auth/refresh` — Refresh token

### Users
- `GET /v1/users/me` — Profil courant
- `PUT /v1/users/me` — Update profil
- `POST /v1/users/me/kyc` — Submit KYC

### Trips
- `GET /v1/trips` — Recherche (query params: origin, destination, date)
- `POST /v1/trips` — Créer trajet
- `GET /v1/trips/:id` — Détail trajet
- `PUT /v1/trips/:id` — Modifier trajet
- `DELETE /v1/trips/:id` — Annuler trajet

### Bookings
- `POST /v1/bookings` — Réserver
- `GET /v1/bookings/my` — Historique (query: role=passenger|driver)
- `PUT /v1/bookings/:id/status` — Accepter/refuser/annuler

### Payments
- `POST /v1/payments/create` — Initier paiement
- `POST /v1/payments/orange/webhook` — Orange Money callback
- `POST /v1/payments/stripe/webhook` — Stripe callback

### Reviews
- `POST /v1/reviews` — Déposer une note
- `GET /v1/reviews/users/:userId` — Voir notes d'un user

### Admin
- `GET /v1/admin/stats` — Statistiques globales
- `GET /v1/admin/users` — Liste users (pagination)
- `PUT /v1/admin/users/:userId/role` — Changer rôle

---

## 7. Fonctionnalités MVP

### Authentification
- ✅ Inscription/connexion par téléphone (OTP SMS)
- ✅ Connexion par email/mot de passe
- ✅ Profil avec photo (Firebase Storage)
- ✅ Vérification KYC light (pièce identité)

### Passager
- ✅ Recherche de trajets (origin, destination, date)
- ✅ Filtres (prix, places, heure)
- ✅ Réservation instantanée ou sur demande
- ✅ Historique des réservations
- ✅ Notation des conducteurs (1-5 étoiles + commentaire)

### Conducteur
- ✅ Publication de trajets (origin, destination, date, heure, prix, places)
- ✅ Modification/annulation de trajets
- ✅ Gestion des réservations (accepter/refuser)
- ✅ Liste des passagers
- ✅ Notation des passagers

### Paiements
- ✅ Orange Money (intégration réelle ou mock)
- ✅ Carte bancaire (Stripe test mode)
- ✅ Paiement en espèces (confirmation cash)
- ✅ Statuts: pending → confirmed → completed / cancelled

### Notifications Push
- ✅ Confirmation réservation
- ✅ Rappel trajet (24h, 1h avant)
- ✅ Changement statut booking
- ✅ Nouveau message chat

### Admin
- ✅ Dashboard: stats DAU/MAU, trips actifs, revenus
- ✅ Liste utilisateurs avec filtres
- ✅ Modération trips
- ✅ Liste signalements

---

## 8. Sécurité

- **Auth:** Firebase Auth JWT, refresh automatique
- **API:** Validation Zod sur toutes les entrées
- **Rate Limiting:** 100 req/min par IP, 10 req/min pour auth
- **CORS:** Whitelist domaines autorisés
- **Firestore Rules:** RBAC strict par rôle
- **Payments:** Webhooks signés (Orange Money + Stripe)

---

## 9. Performance Objectifs

| Action | Target |
|--------|--------|
| Écran d'accueil | < 2.5s |
| Recherche trajets | < 1s |
| Réservation confirmée | < 500ms |
| Push notification | < 3s |

---

## 10. Roadmap Versions

### MVP (Version actuelle)
- Auth (OTP + email)
- Recherche et publication de trajets
- Réservation et gestion
- Paiements (Orange Money + Stripe mock)
- Notifications push
- Dashboard admin

### V1.1
- 🔄 Chat temps réel entre passenger/driver
- 🔄 Partage de position GPS en temps réel
- 🔄 Système de parrainage (code promo)
- 🔄 Codes promotionnels

### V1.2
- 🔄 Application web (React/Next.js)
- 🔄 API publique (documentation)
- 🔄 Intégration Orange Money production
- 🔄 Support multilingue (FR + langues locales)

---

## 11. Environnements

| Env | URL | Usage |
|-----|-----|-------|
| `dev` | localhost:3000 (backend) | Développement local |
| `staging` | staging.fasocovoiturage.bf | Tests avant prod |
| `prod` | api.fasocovoiturage.bf | Production |

---

## 12. Équipe de Développement

- **Lead Developer:** Abdoul Hamid COMPAORÉ (CO Digitale)
- **Contact:** support@fasocovoiturage.bf

---

*Document généré le 16 juin 2026 — v1.0*