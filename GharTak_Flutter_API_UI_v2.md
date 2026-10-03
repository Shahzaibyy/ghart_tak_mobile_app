# GharTak — Flutter UI v2 ↔ live API contract

**Audience:** Flutter app (Bhook Lagi customer + rider).  
**Index:** [`GharTak_Flutter_Integration_Index.md`](./GharTak_Flutter_Integration_Index.md)  
**HTTP shapes:** backend `cmd/api/openapi.yaml`  
**Status board:** [`BACKEND_REQUIREMENTS.md`](./BACKEND_REQUIREMENTS.md)

This file maps **screens → endpoints → response fields the UI already consumes**. Cart stays on device until `POST /orders`. Never send `distance_km`. Money arrives as decimal **strings**.

---

## Feature flags (`AppConfig`)

| Flag | Dart define | Default | Effect |
|---|---|---|---|
| Demo mode | `DEMO` | `true` | Seed chips, demo merchant advance |
| Dev OTP autofill | `USE_DEV_OTP_AUTOFILL` | follows `DEMO` | Fills `dev_otp` from OTP request |
| Google sign-in | `ENABLE_GOOGLE_SIGN_IN` | `false` | Hides Google CTA until Firebase ready |
| Backend geo | `ENABLE_MAPBOX_GEO` | `true` | When `false`, `/geo/*` uses local sample fallback |

Also: `API_BASE_URL`, `WS_BASE_URL`, `ACCESS_TOKEN` / `MAP_API_KEY`.

---

## Must-fix wiring (happy path)

| Step | Screen | Call | Flutter status |
|---|---|---|---|
| 1 | Phone / OTP | `POST /auth/otp/request` + `/verify` | Wired (`dev_otp` autofill) |
| 2 | Home / map | `GET /zones?active=true` | Wired (onboarding + `Zone` DTO) |
| 3 | Home feed | `GET /merchants?zone_id=` | Wired (Fateh Jang default `…111104`) |
| 4 | Menu | `GET /merchants/{id}/catalog` | Wired (live item UUIDs) |
| 5 | Checkout | `POST /orders/quote` | **Wired** — `checkoutQuoteProvider` |
| 6 | Checkout confirm | `POST /orders` + `client_request_id` | Wired |
| 7 | Tracking | `GET /orders/{id}` poll | Wired (`delivery_otp`) |
| 8 | Rider offers | `GET /riders/offers` after dispatch | Wired (needs BE dispatch 200) |

---

## Screen → API field map

### Auth / profile

| UI | Endpoint | Keys used |
|---|---|---|
| OTP request | `POST /auth/otp/request` | `phone`, `role` → `data.dev_otp` |
| OTP verify | `POST /auth/otp/verify` | → `access_token`, `refresh_token`, `role` |
| Refresh | `POST /auth/refresh` | interceptor, one retry on 401 |
| Profile / wallet | `GET /users/me` | `name`, `phone`, `wallet_balance` |
| Rider me | `GET /riders/me` | rider profile (not `/users/me`) |

Envelope: success `{ "data": … }`, error `{ "error": { "code", "message" } }`.  
Mapped codes: `unauthorized`, `rate_limited`, `phone_required`, `unavailable`, `invalid_input`, `conflict`.

### Catalog / menu / checkout

| UI | Endpoint | Keys used |
|---|---|---|
| Zones | `GET /zones?active=true` | `id`, `city_name`, `center_lat/lng`, `service_radius_km`, `is_active` |
| Merchants | `GET /merchants?zone_id=` | `id`, `name`, `category`, `address_text`, `lat/lng`, optional `photo_url` / `cover_image_url` |
| Menu | `GET /merchants/{id}/catalog` | `id`, `name`, `description`, `price` (string), optional `photo_url` / `image_url` |
| Quote | `POST /orders/quote` | → `item_total`, `delivery_fee`, `total`, `distance_km`, `duration_min`, `approximate`, `route`, `commission_amount`, `rider_earning`, `surge_multiplier` |
| Place | `POST /orders` | quote body + `client_request_id` (8–64), prefer `payment_method: "cod"` |

Missing media URLs → client `DemoMedia` Unsplash fallbacks.

### Rider

| UI | Endpoint | Keys |
|---|---|---|
| Online | `POST /riders/availability` | `is_online` |
| Position | `POST /riders/position` | `lat`, `lng` |
| Offers | `GET /riders/offers` | empty until dispatch succeeds |
| Accept / pickup / enroute / deliver | `POST /riders/tasks/{id}/…` | deliver body **`delivery_otp`** (4 digits) |

### Tracking

| UI | Endpoint | Keys |
|---|---|---|
| Status + door code | `GET /orders/{id}` | `status`, `delivery_otp`, `delivery_fee`, `items` |
| Live map (optional) | `WS /ws/location/{order_id}` | token auth |

Status map: `placed`/`preparing`/`ready*` → Placed; `offered`/`accepted` → Accepted; `picked_up`/`enroute` → PickedUp; `delivered` / `cancelled`.

---

## New endpoint backlog (UI ready, API soft/missing)

| UI need | Ask backend |
|---|---|
| Merchant / item photos | Prefer `photo_url` on list + catalog |
| Order history tabs | `GET /orders` list |
| Voucher `BHOOKFREE` | list + redeem |
| Wallet top-up | JazzCash / Easypaisa |
| Rider earnings / cashout | earnings APIs |
| Auto-dispatch on ready | skip manual `POST …/dispatch` |
| FCM offers | `POST /notifications/devices` |

---

## Seed IDs (development)

| Resource | Value |
|---|---|
| Fateh Jang zone (demo default) | `11111111-1111-4111-8111-111111111104` |
| Attock City | `…111101` |
| Hasan Abdal | `…111102` |
| Customers | `03001111001`–`005` |
| Riders | `03002222001`–`005` |
| Merchants | `03003333001`–`008` |
| Catalog item IDs | **Not fixed** — always from catalog GET |

---

## Acceptance (Flutter)

- [x] One Dio client + Bearer + 401 refresh once  
- [x] Envelope + money-as-string parsers  
- [x] Cart local until place  
- [x] Quote drives checkout totals (`approximate` chip)  
- [x] Feature flags for OTP / Google / geo  
- [x] Photo URL preferred over DemoMedia  
- [ ] Dispatch 200 on Render (backend deploy)  
- [ ] Order list + vouchers when endpoints land  
