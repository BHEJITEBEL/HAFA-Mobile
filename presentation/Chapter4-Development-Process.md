# HAFA — Development Process (Presentation Script)

Prepared from: *FYP 1 Progress Report (HAFA)*, Chapters 1–3, checked against the `HAFA-Mobile` repository (commit `2f425fc`).

---

## Part A — Does the project tally with the report?

### A1. What MATCHES the report

| Report says | Project has | Where |
|---|---|---|
| Mobile app built with **Flutter** (Scope 1.4 iii) | Flutter/Dart app, 38 `.dart` files, Android target | `hafa_mobile/` |
| Backend **Node.js / Express.js** (Fig 3.4.3) | Express REST API | `hafa-backend/app.js`, `server.js` |
| A **Database** for users & crafts (Fig 3.4.3) | MongoDB with `User` and `Product` collections | `hafa-backend/models/` |
| 3 actors: **Consumer, Artisan, Admin** (Fig 3.4.1) | `UserRole.consumer / artisan / administrator` | `models/app_user.dart`, `models/User.js` |
| **QR + NFC** verification, NTAG213 tags (2.3.1, 2.3.3.1) | Camera QR scan (`mobile_scanner`), NFC read **and write** (`nfc_manager`) | `qr_scan_screen.dart`, `nfc_verify_screen.dart`, `services/nfc_service.dart` |
| Login / Register (Fig 3.6.1) | Real server accounts — bcrypt password hash + JWT token | `routes/auth.js`, `login_screen.dart`, `register_screen.dart` |
| Home, Explore, Verify, Heritage Locations, Profile (Fig 3.6.2–3.6.4) | All present, with bottom navigation | `home_`, `explore_`, `verify_`, `heritage_map_`, `profile_screen.dart`, `main_shell.dart` |
| Craft certificate + blockchain record page (Fig 3.6.5) | Heritage Passport (with QR + PDF certificate) and Blockchain screen | `heritage_passport_screen.dart`, `blockchain_screen.dart`, `services/pdf_service.dart` |
| Craft registration (Fig 3.6.7) | 6-step registration wizard → status *Pending Verification* | `product_registration_screen.dart` |
| Admin analysis + security dashboards (Fig 3.6.8–3.6.9) | Admin Dashboard + Cybersecurity screens | `admin_dashboard_screen.dart`, `cybersecurity_screen.dart` |
| Agile, iterative development (3.2) | Git history shows iterations: web prototype → mobile app → server login → online hosting | `git log` |

### A2. What DOES NOT match (be honest about these in the presentation)

| # | Report says | Actual project | What to do |
|---|---|---|---|
| 1 | **Blockchain** network, **smart contracts** (Solidity), Hyperledger Fabric chosen (2.3.3.2) | **No blockchain yet.** `blockchainHash` is a random 32-byte value made by the server (`crypto.randomBytes`) in `routes/products.js`. The "Smart contract executed" line in `blockchain_screen.dart` is fixed text. | Say: *"blockchain layer is simulated in FYP 1; real integration is planned for FYP 2."* |
| 2 | Report itself is inconsistent: Scope 1.4 says **Ethereum-compatible**, 2.3.3.2 says **Hyperledger Fabric** chosen, 2.3.2 lists **Solidity** (Ethereum language; Fabric uses Go/JS chaincode) | — | Pick one and fix the report before FYP 2. |
| 3 | **IPFS** stores images/certificates (2.3.3.3, Fig 3.4.3) | Images are saved on the **server's disk** (`/uploads`, Docker volume `hafa_uploads`). `ipfsCid` is a random fake string. | Say IPFS is planned; images are currently on the API server. |
| 4 | Frontend **React + Web3.js** (2.3.2, 2.4); prototype in **HTML/CSS/JS**, live at Netlify (2.3.4, 3.5) | Final app is **Flutter**. No React, no Web3.js. HTTP calls use Dart's `http` package. | Explain: React web version was the **prototype** (wireframes), then **migrated to Flutter** for native camera/NFC. The code comments even say "replaces axios / React Context / react-router". |
| 5 | Database stores **Users, Crafts, Logs, Records** (Fig 3.4.3) | Only **Users** and **Products**. Scan counts are fields inside Product; no separate logs collection. | Minor — update diagram. |
| 6 | 2.3.3.3 argues a **centralized DB is weak**, yet the project uses MongoDB (centralized) | MongoDB is the main store | Justify: MongoDB holds app data; blockchain/IPFS will hold the tamper-proof proof (hybrid design). |
| 7 | Admin **reviews → approves/rejects** craft (Fig 3.4.2) | `Review` button only shows details; it says approve/reject needs an admin API "not part of this prototype yet". | Mark as FYP 2 work. |
| 8 | Certificate & blockchain record generated **after approval** (Fig 3.4.2) | Hash, CID and passport number are generated **at registration time**, before any approval. | Either change the flow or the code later. |
| 9 | User logs in **as** consumer/artisan/admin | After login, user picks a role on the **Role Selection** screen (client-side). Any user can pick *Administrator* in the app; the server only allows self-register as consumer/artisan. | Extra screen not in flow diagram; also a security gap to mention. |
| 10 | Admin dashboards show analysis/security data | Figures are **static sample numbers** (`AdminStats`, cybersecurity constants). | Say "dashboard UI done; live data FYP 2". |
| 11 | Artisan sees **own** product history | Artisan dashboard lists **all** products (products not linked to user account). `POST /api/products` has **no login check**. | FYP 2: link product to artisan ID + protect endpoint. |

### A3. Things in the project that are NOT in the report (add them — they are strengths)

- **Docker + docker-compose** (MongoDB + API run with one command)
- **Online hosting**: API reachable at `https://api.hafamobilefyp.site` via **Cloudflare Tunnel** to the local PC; **Render + MongoDB Atlas** as backup (`render.yaml`)
- **Security** features: bcrypt hashing, JWT (30-day token), login rate-limit (10 fails / 15 min), Helmet headers, image "magic-byte" check on uploads, password hash never returned
- **Offline cache** of products + offline **Demo / Guest** login
- **PDF certificate** generation & sharing
- **NFC tag writing** (artisan writes `hafa://verify/<ID>` into an NTAG213/215 tag)
- **Heritage map** using OpenStreetMap (`flutter_map`)
- **Server Settings** screen in Profile (switch API URL without rebuilding)

### A4. Housekeeping
- Root folder has untracked `package.json`, `package-lock.json`, `node_modules/` (bcryptjs, jsonwebtoken) — an `npm install` was run in the wrong folder. The real ones are inside `hafa-backend/`. Safe to delete the root copies.

---

## Part B — Chapter 4: Development Process (what to say)

### B1. Development stack (one slide)

```
 ┌──────────────────────┐   HTTPS / JSON    ┌─────────────────────────┐      ┌──────────────────────┐
 │  Flutter mobile app  │ ───────────────▶  │  Node.js + Express API   │ ───▶ │  MongoDB (users,     │
 │  (Android, Dart)     │ ◀───────────────  │  (Docker container,     │      │  products)           │
 │  QR camera · NFC     │                   │   port 8001)            │ ───▶ │  /uploads (images)   │
 └──────────────────────┘                   └─────────────────────────┘      └──────────────────────┘
            │                                         ▲
            │      api.hafamobilefyp.site             │  Cloudflare Tunnel (public HTTPS → local PC)
            └─────────────────────────────────────────┘  Backup: Render.com + MongoDB Atlas
```

| Layer | Technology |
|---|---|
| Mobile frontend | Flutter 3 / Dart, Provider (state), go_router (navigation) |
| Hardware access | `mobile_scanner` (QR), `nfc_manager` (NFC), `image_picker` (camera/gallery) |
| Backend | Node.js 22, Express 4, Mongoose 8 |
| Database | MongoDB 7 (Docker) or MongoDB Atlas (cloud) |
| Security | bcryptjs, jsonwebtoken (JWT), helmet |
| Deployment | Docker Compose, Cloudflare Tunnel, Render (backup) |
| Blockchain / IPFS | **Simulated** in FYP 1 (planned FYP 2) |

### B2. What is an API? (explain simply)

> **API = Application Programming Interface.** It is the "waiter" between the app and the database.
> The phone never talks to the database directly. It sends a **request** (e.g. *"give me product HAFA-2024-TRG-001"*) to a URL, the API checks it, fetches/saves data in MongoDB, and sends back a **response** in JSON.

HAFA uses a **REST API**: every action is an HTTP method + URL.

| Method & URL | Purpose | Used by screen |
|---|---|---|
| `GET /api/health` | Is server alive? → `{ok:true}` | Profile ▸ Server Settings "Test" |
| `POST /api/auth/register` | Create account (name, email, password, role) → token | Register |
| `POST /api/auth/login` | Check email + password → JWT token | Login |
| `GET /api/auth/me` | Check token still valid | App start-up |
| `GET /api/products` | List all crafts (filter by category/status/search) | Home, Explore, Map, Dashboards |
| `GET /api/products/:id` | One craft by ID (`HP001`) or verification ID | Verify result, Passport, Blockchain |
| `POST /api/products` | Register new craft → *Pending Verification* | Product Registration |
| `POST /api/products/:id/scan` | Count a QR/NFC/manual scan | Verification result |
| `POST /api/uploads` | Upload a craft photo → `/uploads/xxx.jpg` | Product Registration |
| `GET /uploads/<file>` | Download a photo | Any product image |

**Example to show live:** open `https://api.hafamobilefyp.site/api/products/HAFA-2024-TRG-001` in a browser → JSON of the Royal Songket.

### B3. Where is the API, and where is the data stored?

| Thing | Location |
|---|---|
| API **source code** | `hafa-backend/` folder in the GitHub repo |
| API **running** | Docker container `hafa-api` on the developer PC, port **8001** |
| API **public address** | `https://api.hafamobilefyp.site` (Cloudflare Tunnel → PC). Backup: `hafa-api.onrender.com` |
| **User accounts & products** | MongoDB database `hafa` — Docker container `hafa-mongo`, data kept in volume `hafa_mongo_data` (or MongoDB Atlas cloud if `MONGO_URI` is set) |
| **Uploaded photos** | Docker volume `hafa_uploads` (folder `/app/uploads`) |
| **Secrets** (JWT secret, Mongo password) | `.env` file — **not** uploaded to GitHub |
| **On the phone** | `SharedPreferences`: login token, user, chosen role, server URL, cached product list |
| Blockchain hash / IPFS CID | Currently just text fields inside each Product document (simulated) |

### B4. How each file operates

#### Backend — `hafa-backend/`

| File | Role |
|---|---|
| `server.js` | **Entry point.** Loads `.env`, checks JWT secret, connects to MongoDB, auto-seeds 4 sample crafts if DB empty, starts listening on port 8001. |
| `app.js` | **Express setup.** Adds security headers (Helmet), CORS, JSON parser, and plugs in the routes (`/api/auth`, `/api/products`, `/api/uploads`, `/uploads`). Handles 404 and errors. |
| `routes/auth.js` | Register / login / me. Validates email & password, hashes password with **bcrypt**, issues **JWT**, blocks brute-force (10 failed tries → 15-min lock). |
| `routes/products.js` | List, get, register craft, count scans. On register it creates ID `HP00x`, verification ID `HAFA-YYYY-NEW-00x`, passport no., **simulated** blockchain hash + IPFS CID, first ownership & provenance entries. |
| `routes/uploads.js` | Receives raw image bytes, checks they are really JPEG/PNG/WEBP (magic bytes), saves to disk, returns the path. Max 8 MB. |
| `models/User.js` | MongoDB schema: name, email (unique), passwordHash, role. Never sends hash back to the app. |
| `models/Product.js` | MongoDB schema for a craft: details, artisan, materials, images, verificationId, blockchainHash, ipfsCid, status, ownershipHistory, provenanceTimeline, scan counters. |
| `middleware/auth.js` | Signs and verifies JWT tokens (`Authorization: Bearer …`). |
| `seed/mockData.js`, `seed/seed.js` | 4 sample heritage crafts (Songket, Batik, etc.) and a script to reload them. |
| `Dockerfile`, `../docker-compose.yml` | Build the API image; run API + MongoDB together. |
| `../render.yaml` | Blueprint for hosting on Render (backup). |

#### Mobile app — `hafa_mobile/lib/`

| Folder / file | Role |
|---|---|
| `main.dart` | App start: locks portrait, loads saved session, creates `AppState`, runs the app. |
| `app.dart` | Builds `MaterialApp` with theme and router. |
| `router.dart` | All page routes (`/login`, `/home`, `/verify`, `/qr-verify/:id`, …). Blocks private pages if not logged in. |
| `core/config.dart` | Default server URL (`api.hafamobilefyp.site`). |
| `core/theme.dart`, `constants.dart`, `utils.dart` | Colours/fonts, static sample stats, date helpers. |
| `models/product.dart`, `app_user.dart` | Dart classes that convert API JSON ↔ objects; `UserRole` enum. |
| `services/api_service.dart` | **The only file that talks to the API** — login, register, products, upload, scan; friendly error messages; 60 s timeout. |
| `services/nfc_service.dart` | Read/write NDEF records on NFC tags (`hafa://verify/<ID>`). |
| `services/pdf_service.dart` | Generates PDF Heritage certificate & blockchain report. |
| `state/app_state.dart` | **App "brain"**: current user, role, product list, offline cache, sign-in/out, server URL. Screens listen to it (Provider). |
| `widgets/` | Re-usable UI pieces: cards, batik patterns, NFC write dialog. |
| `screens/` (22) | One file per page — see mapping in B5. |

### B5. Screen ↔ report figure mapping

| Report figure | Screen file(s) |
|---|---|
| 3.6.1 Home / Login / Register | `splash_`, `welcome_`, `login_`, `register_`, `role_selection_screen.dart` |
| 3.6.2 Main / Explore / Verify | `home_`, `explore_`, `product_detail_`, `verify_screen.dart` |
| 3.6.3 Heritage Locations | `heritage_map_screen.dart` |
| 3.6.4 Profile | `profile_screen.dart` |
| 3.6.5 Certificate & Blockchain Record | `heritage_passport_`, `passport_list_`, `blockchain_screen.dart` |
| 3.6.6 QR/NFC Verification | `qr_scan_`, `nfc_verify_`, `verification_result_screen.dart` |
| 3.6.7 Craft Registration | `product_registration_screen.dart` (+ `artisan_dashboard_screen.dart`) |
| 3.6.8 Admin Analysis | `admin_dashboard_screen.dart` |
| 3.6.9 Admin Security | `cybersecurity_screen.dart` |

### B6. One request end-to-end (good demo story)

**Consumer scans a Songket tag:**
1. `verify_screen` → opens `qr_scan_screen` (camera) or `nfc_verify_screen` (tap tag).
2. Tag text `hafa://verify/HAFA-2024-TRG-001` → ID extracted.
3. `AppState.resolveProduct()` → `ApiService.getProduct()` → **`GET /api/products/HAFA-2024-TRG-001`**.
4. `routes/products.js` finds it in MongoDB → returns JSON.
5. `verification_result_screen` shows **VERIFIED** (green) / pending / NOT VERIFIED (red) and calls **`POST /scan`** to count it.
6. User opens Heritage Passport (certificate, QR, PDF) and Blockchain record.

**Artisan registers a craft:** 6-step form → photos sent to `POST /api/uploads` → details sent to `POST /api/products` → saved in MongoDB as *Pending Verification* → artisan can print QR or write NFC tag.

---

## Part C — Use Case Diagram vs. the App

| Actor | Use case (Fig 3.4.1) | In app? | Notes |
|---|---|---|---|
| Artisan | Login | ✅ | Server account (JWT) |
| Artisan | Register Product | ✅ | 6-step wizard |
| Artisan | Upload images / documentation | ✅ images / ❌ documents | Photos only |
| Artisan | Upload product metadata | ✅ | Materials, method, date, price… |
| Artisan | Generate QR/NFC Tag | ✅ | QR on passport; NFC write dialog |
| Artisan | View Product History | ⚠️ | Dashboard shows **all** products, not only own |
| Artisan | View Verification Logs | ⚠️ | Only counts (scans / requests), not a log list |
| Consumer | Scan QR/NFC Tag | ✅ | Camera + NFC + manual lookup |
| Consumer | Verify Product Authenticity | ✅ | Verification result screen |
| Consumer | View Product Provenance | ✅ | Provenance timeline |
| Consumer | View Artisan Information | ✅ | Product detail / passport |
| Consumer | View Production Location | ✅ | Heritage map |
| Consumer | View Ownership History | ✅ | Passport / blockchain screen |
| Admin | Monitor Blockchain Records | ⚠️ | UI with sample data |
| Admin | Manage Verification Requests | ⚠️ | Review shows details; no approve/reject |
| Admin | Audit Product Transactions | ⚠️ | Static dashboard |
| Admin | Manage Artisan Accounts | ❌ | No user-management screen/API |
| Admin | Manage Smart Contract Permissions | ❌ | No smart contract |
| System | Store data on IPFS | ❌ | Simulated CID; images on server disk |
| System | Record provenance hash on blockchain / Validate smart contract / Record ownership transfer | ❌ | Simulated hash; no ownership-transfer function |
| System | Retrieve data / verification records | ✅ (from MongoDB) | Not from blockchain |

**Verdict:** The **Consumer** side tallies fully. The **Artisan** side mostly tallies. The **Admin** side and all the **blockchain/IPFS (purple)** use cases are UI-only or simulated — this is the FYP 2 scope.

Suggested sentence for the slides:
> "In FYP 1 we completed the full mobile application, backend API, database, authentication and QR/NFC verification. The blockchain and IPFS layer is currently simulated using generated hashes so the full user flow can be demonstrated; real smart-contract and IPFS integration, plus admin approval, are planned for FYP 2."
