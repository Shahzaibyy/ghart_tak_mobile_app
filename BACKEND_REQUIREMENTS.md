# Backend requirements (Flutter ↔ GharTak API)

What the customer + rider apps need from the backend for the current UI and flows to work end-to-end. Based on live Render testing and the OpenAPI surface.

**API base (demo):** `https://ghartak-backend-j3g5.onrender.com`  
**Env:** `APP_ENV=development` so OTP returns `dev_otp` / demo login works.  
**Flutter contract:** [`GharTak_Flutter_API_UI_v2.md`](./GharTak_Flutter_API_UI_v2.md)

---

## Flutter implemented (client)

| Area | Status |
|---|---|
| Auth OTP + refresh interceptor | Done |
| Zones / merchants / catalog | Done — Fateh Jang default zone |
| `POST /orders/quote` at checkout | Done — live totals + approximate chip |
| `POST /orders` + `client_request_id` | Done |
| Tracking poll + `delivery_otp` | Done |
| Rider offers / accept / pickup / deliver | Done (deliver sends `delivery_otp`) |
| Feature flags (`USE_DEV_OTP_AUTOFILL`, `ENABLE_GOOGLE_SIGN_IN`, `ENABLE_MAPBOX_GEO`) | Done |
| Prefer API `photo_url` / `image_url` | Done — DemoMedia fallback |

---

## 1. Blockers for live rider offers

| Need | Endpoint | Notes |
|---|---|---|
| **Dispatch must succeed** | `POST /orders/{id}/dispatch` | After merchant marks `ready` / `ready_for_pickup`, this must create a rider offer. Previously returned **500**. Must be **deployed** to Render. |
| Offers list | `GET /riders/offers` | Empty until dispatch succeeds for an online rider in the **same zone**. |
| Accept | `POST /riders/tasks/{id}/accept` | Body: none. `{id}` = order id from the offer. |

**Auth for dispatch:** merchant token that **owns** the order. Seeded Fateh Jang merchants: `03003333001`–`03003333008`.

---

## 2. Order lifecycle (customer + kitchen + rider)

| Step | Who | Method / path | Body / keys |
|---|---|---|---|
| Quote | Customer | `POST /orders/quote` | `type`, `zone_id`, `merchant_id`, `drop_lat`, `drop_lng`, `drop_address`, `items[]`, `payment_method` |
| Place | Customer | `POST /orders` | Same as quote + **`client_request_id`**. Prefer `cod`. |
| Get | Customer | `GET /orders/{id}` | **`status`**, **`delivery_otp`** (4 digits), items, fees |
| Accept → preparing → ready | Merchant | `POST /merchants/orders/{id}/…` | none |
| Dispatch | Merchant | `POST /orders/{id}/dispatch` | none (must 200) |
| Offer → accept → pickup → enroute | Rider | `GET/POST /riders/…` | — |
| Deliver | Rider | `POST /riders/tasks/{id}/deliver` | **`{"delivery_otp":"1234"}`** |

---

## 3. Remaining backend gaps

| Need | Notes |
|---|---|
| Merchant / item photos | Prefer `photo_url` / `cover_image_url` / `image_url` |
| `GET /orders` list | Active / Past tabs |
| Vouchers | `BHOOKFREE` redeem |
| Wallet top-up | JazzCash / Easypaisa |
| Rider earnings / cashout | Not wired |
| Auto-dispatch on ready | Optional skip of manual dispatch |
| FCM | `POST /notifications/devices` |

---

## 4. Seed IDs

Fateh Jang zone `…111104` · customers `03001111001`–`005` · riders `03002222001`–`005` · merchants `03003333001`–`008`.
