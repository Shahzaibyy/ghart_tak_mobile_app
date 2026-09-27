# GharTak — Design System (for Google Stitch)

This is the persistent design brain for GharTak — one file, reused across every surface (Customer app, Rider app, Merchant web panel, Admin web panel). It replaces the short "Design System Brief" embedded in `GharTak_Design_Prompts.md` with a fuller, more premium-leaning system. The per-screen prompts in that file still work — when generating any of them in Stitch, paste the **Paste-Ready Token Block** below first (or at the top of each screen prompt, since Stitch doesn't reliably carry style memory between separate generations).

Direction: **premium minimalism** — the difference between "clean" and "cheap-template clean" is almost entirely in typography choice, image treatment, and a handful of small motion/depth details. This file exists to lock those in so nothing drifts screen to screen.

---

## Paste-Ready Token Block (paste this into every Stitch prompt)

```
Design system: GharTak — premium minimalist.

COLORS (light mode):
- Background: #FAF8F5 (warm off-white, not pure white)
- Surface/card: #FFFFFF
- Primary brand: #D96B41 (warm terracotta)
- Primary pressed/dark accent: #C25A32
- Text primary: #1C1917 (warm near-black charcoal)
- Text secondary: #78716C (warm gray)
- Border/divider: #EDE7E0
- Success: #2F9E5B
- Error: #B8452B
- Premium/rating accent: #C9A063 (muted gold — used only for ratings, badges, "top rated" — never as a primary UI color)

COLORS (dark mode):
- Background: #17140F (deep warm charcoal, never pure black)
- Surface/card: #211D17
- Primary brand: #E37A52 (brightened terracotta for dark contrast)
- Text primary: #F5F1EB
- Text secondary: #A39A8E
- Border/divider: #332C22

TYPOGRAPHY: "General Sans" throughout (fallback: Inter). Semibold for
headings, Medium for labels/buttons, Regular for body. No second typeface,
no decorative fonts.

ICONS: Phosphor Icons, Regular weight, outline style. Duotone weight only
for empty-state illustrations, never for functional UI icons.

SHAPE: 16px corner radius on cards, 12px on buttons/inputs, 8px on chips.

SHADOWS: flat by default. Floating elements only: soft diffused shadow,
0 8px 24px rgba(28,25,23,0.08) — never a hard drop shadow.

IMAGERY: real photography, warm/slightly desaturated color grade, 4:3 for
merchant cards, 1:1 for catalog items, always masked to the card's 16px
radius. No generic stock-icon illustrations — empty states use simple
terracotta monoline line art instead.

AVATARS: circular, thin 1.5px neutral ring. No photo → initials on a
soft terracotta-to-peach gradient background, never flat gray. Online
status = small green dot, bottom-right, with a background-colored cutout
ring so it doesn't look pasted on top.

Overall feel: Linear / Arc Browser / Airbnb — confident, warm,
restrained. Not a food-delivery-app cliché of loud red and cartoon icons.
```

---

## 1. Typography — the single biggest lever for "premium"

**Primary typeface: General Sans** (free, Fontshare). It has more character than the ubiquitous Inter — a lot of "clean" apps default to Inter and end up looking like every other clean app. General Sans keeps the same legibility while reading as a deliberate choice.

If a tool can't source General Sans, fall back to **Inter** — never to a generic system font, never to a second typeface for "variety." One family, weight does all the work.

| Style | Weight | Size / Line height | Use |
|---|---|---|---|
| Display | Semibold | 32/40 | Splash, hero numbers (earnings, GMV) |
| H1 | Semibold | 24/32 | Screen titles |
| H2 | Semibold | 20/28 | Section headers, card titles |
| Body | Regular | 16/24 | Default text — never smaller than this on mobile |
| Label | Medium | 14/20 | Buttons, form labels, chips |
| Caption | Regular | 13/18 | Timestamps, metadata, fine print |

---

## 2. Color — restrained, with one earned accent

Terracotta stays the single brand color — the temptation with "premium" is to add more colors; resist it. The one addition here is the muted gold (#C9A063), and it's reserved *exclusively* for rating stars, "top rated" badges, and loyalty/achievement moments. If gold starts appearing on regular buttons or icons, it's been overused — pull it back.

Dark mode is not optional polish here — supporting it well is itself a premium signal (compare how much more "designed" apps with a considered dark mode feel versus ones that just invert colors). Background is warm near-black (#17140F), never pure `#000000` — pure black against white text is harsh and reads as unfinished, not premium.

---

## 3. Imagery & Photography

- Real photography for food, stores, and catalog items — never illustration for anything a customer is about to order.
- Apply a consistent, subtle color grade across all sourced/stock photography (slightly warm, slightly desaturated) so images from different merchants don't clash — this single detail does more for "premium" than almost anything else, because inconsistent photo treatment is the fastest way an app reads as assembled rather than designed.
- Fixed aspect ratios, always: 4:3 for merchant/restaurant cards, 1:1 for individual catalog items, 16:9 only for any editorial/promotional banner.
- Every image is masked to the card's corner radius — no square photo inside a rounded card.

## 4. Avatars & Identity

- Photo avatar when available: circular, thin 1.5px neutral border (`#EDE7E0` light / `#332C22` dark) — not colored, so it never clashes with a status ring.
- No photo: initials on a soft gradient background generated from the brand palette (terracotta → warm peach), not a flat gray circle — this is a small, cheap-to-implement detail that reads as considered rather than default.
- Status dot (online/available): small, bottom-right, with a background-colored cutout ring around it so it reads as sitting *on* the avatar, not floating beside it.

## 5. Motion & Delight Moments

Use **Lottie** animations, not GIFs, for anything in-app — Lottie is vector-based (crisp at any size, tiny file size, themeable to match light/dark mode); a GIF is a fixed-size raster loop that can't adapt and looks dated by comparison. Reserve them for a small number of genuine moments, not everywhere:
- Order placed confirmation (a single clean checkmark animation)
- Delivery complete celebration (brief, subtle — not a confetti explosion)
- A quiet idle animation for true empty states ("no orders yet")

Other motion rules:
- Loading state = **skeleton screens** (shimmering placeholder shapes matching the eventual layout), never a bare spinner — this is the detail that most separates a considered app from a template one.
- Button press = subtle scale to 0.97 plus a slight opacity dip, not a hard color flash.
- Where two screens share an element (a merchant card photo expanding into the merchant detail hero image), use a shared-element transition rather than a hard cut — cheap to describe, expensive-looking in practice.

## 6. Depth & Elevation

Stay flat everywhere except two deliberate exceptions:
- **Bottom sheets and modals**: a soft backdrop blur (~20px) with a light dark scrim behind them, not a flat semi-transparent overlay — this single change is most of what makes a sheet feel "native premium" versus "web modal."
- **Floating elements** (an active-order tracking card over the map, a FAB): a soft, large-radius, low-opacity shadow — `0 8px 24px rgba(28,25,23,0.08)` — never a hard, small-radius drop shadow.

Everything else — regular cards, list rows, buttons — stays flat. Shadows used everywhere stop meaning anything; used in exactly two places, they do real work.

## 7. Empty States & Illustration

When a screen needs an illustration (empty order history, no riders nearby, etc.), use simple **monoline line art in terracotta**, not a generic stock-illustration pack (the kind with a cartoon person and floating UI elements — this is the single fastest way to make an app look like a template). Keep it to a single subject, minimal detail, consistent stroke weight matching the icon set.

## 8. Accessibility (don't let "warm and muted" become "hard to read")

Warm off-whites and muted secondary text grays are a premium look — they're also easy to accidentally push under readable contrast. Check every text/background pairing against **WCAG AA (4.5:1 for body text, 3:1 for large text)** before finalizing a screen, especially `#78716C` secondary text on `#FAF8F5` background — verify it, don't assume it from the hex values alone.

---

## Using this file in Stitch

- If your Stitch project has a persistent instructions/context field, paste the whole file there once.
- If not — Stitch, like most single-shot design generators, often doesn't carry style memory between separate screen generations — paste the **Paste-Ready Token Block** at the top of every individual screen prompt from `GharTak_Design_Prompts.md`, replacing the shorter brief that file currently opens with.
- If a generated screen drifts (adds a second typeface, a generic stock illustration, a hard drop shadow, an extra color), don't hand-fix it — re-paste the token block and regenerate. Drift compounds silently across screens if you patch instead of regenerating.
