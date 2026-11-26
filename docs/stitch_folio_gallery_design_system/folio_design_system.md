---
name: "Folio — Mobile Design System"
description: "Dark-only Material Design 3 and glassmorphism mobile design system (390x844) for Folio, a Brazilian Portuguese photo gallery and built-in image editor."
---

## Overview

**Folio** is a calm, premium, content-first mobile photo gallery app (portrait `390x844`, Brazilian Portuguese UI) that reads images on the phone, groups them by folder, and includes a zoomable viewer and built-in image editor.

The system pairs **Material Design 3** structural clarity—a dark tonal color scheme, generous rounded corners, segmented buttons, a floating action button, and action snackbars—with **glassmorphism** surfaces. Translucent frosted-glass panels float over a softly glowing dark canvas so that photography always remains the hero. The tone is quiet, confident, and never playful.

---

## Colors

Dark UI only. The base canvas (`#121318`) sits over three large, soft blurred ambient glows with no hard edges or patterns:
- **Top-left blue-violet glow:** `rgba(122, 128, 255, 0.34)`
- **Right pink glow (~28% height):** `rgba(255, 128, 190, 0.20)`
- **Bottom-left teal glow:** `rgba(60, 200, 210, 0.20)`

Glassmorphism surfaces use translucent fills with `backdrop-filter: blur(22px) saturate(1.5)`, a `1px` border (`rgba(255, 255, 255, 0.14)`), and a `1px` inner top-edge highlight (`rgba(255, 255, 255, 0.10)`–`0.12`). Glass is used only on cards, floating bars, menus, sheets, dialogs, and inputs—never on individual photos.

- **Normal glass fill:** `rgba(255, 255, 255, 0.07)`
- **Strong glass fill (bars, menus, sheets, dialogs):** `rgba(34, 35, 44, 0.62)`
- **FAB tinted glass fill (folders screen only):** `rgba(122, 128, 255, 0.28)`

```yaml
colors:
  background: "#121318"
  on-background: "#E3E1E9"
  stage: "#0A0A0B"
  page-frame: "#07070A"
  surface: "#1E1F25"
  on-surface: "#E3E1E9"
  surface-raised: "#292A31"
  on-surface-raised: "#E3E1E9"
  on-surface-muted: "#C5C5D0"
  outline: "#44454F"
  primary: "#BFC2FF"
  on-primary: "#272A78"
  secondary-container: "#3F4165"
  on-secondary-container: "#DFE0FF"
  danger: "#FFB4AB"
  on-danger: "#690005"
  snackbar: "#E3E1E9"
  on-snackbar: "#121318"
  snackbar-action: "#E0E0FF"
  on-snackbar-action: "#3B3E8F"
```

---

## Typography

**Plus Jakarta Sans** is the sole typeface across the entire system. Numbers in large counters use tabular numerals (`font-variant-numeric: tabular-nums`).

**Iconography:** Material Symbols Outlined (or matching 1.8px stroke outline icons with round caps and joins), sized `24px` by default and `22px` inside menus and editor tabs. Core icon set: back arrow, forward arrow, search, plus, three vertical dots, heart (outline, or filled in `#BFC2FF` when favorited), info (circle with `i`), share (three connected nodes), lock, trash, magic wand (editor entry), pencil, play, copy, folder, folder with arrow (move), open-with (arrow out of tray), printer, phone, check, close (`X`), crop, filters (three overlapping circles), adjust (two sliders), brush, text (`T`), rotate left/right, flip, undo, loading ring.

```yaml
typography:
  display-num:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 64px
    fontWeight: 800
    lineHeight: 72px
    letterSpacing: -1.92px
    fontFeature: '"tnum"'
  display-num-mobile:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 32px
    fontWeight: 800
    lineHeight: 38px
    letterSpacing: -0.96px
    fontFeature: '"tnum"'
  screen-title:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 34px
    fontWeight: 800
    lineHeight: 40px
    letterSpacing: -1.19px
  screen-title-mobile:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 32px
    fontWeight: 800
    lineHeight: 38px
    letterSpacing: -1.12px
  dialog-title:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 22px
    fontWeight: 800
    lineHeight: 28px
    letterSpacing: -0.44px
  topbar-title:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 20px
    fontWeight: 700
    lineHeight: 26px
    letterSpacing: -0.2px
  button-lg:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 17px
    fontWeight: 700
    lineHeight: 22px
    letterSpacing: 0px
  title-md:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 16px
    fontWeight: 700
    lineHeight: 22px
    letterSpacing: 0px
  menu-label:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 16px
    fontWeight: 600
    lineHeight: 22px
    letterSpacing: 0px
  body-lg:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 16px
    fontWeight: 400
    lineHeight: 24px
    letterSpacing: 0px
  body-md:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 15px
    fontWeight: 400
    lineHeight: 22px
    letterSpacing: 0px
  button-ghost:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 15px
    fontWeight: 600
    lineHeight: 20px
    letterSpacing: 0px
  label-lg:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 14px
    fontWeight: 600
    lineHeight: 20px
    letterSpacing: 0px
  caption-md:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 20px
    letterSpacing: 0px
  label-md:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 13px
    fontWeight: 600
    lineHeight: 18px
    letterSpacing: 0px
  caption-sm:
    fontFamily: "Plus Jakarta Sans"
    fontSize: 13px
    fontWeight: 400
    lineHeight: 18px
    letterSpacing: 0px
```

---

## Layout & Spacing

Designed exclusively for mobile portrait (`390x844`).
- **Folder grid:** 2-column fluid grid with `12px`–`16px` gutters and `14px`–`16px` horizontal screen padding. Folder cards use `8px` internal padding (`12px` bottom) and `6px` side padding under the 2x2 collage cover (`2px` collage gaps).
- **Photo grid:** 3-column fluid grid with `4px` gaps between square tiles and `8px` horizontal screen padding.
- **Floating bars:** Detached from screen edges with `14px` side and bottom margins, `68px` height.
- **Dialogs:** `24px` side margins and `24px` internal padding.
- **Bottom sheets:** `28px` top/bottom and `24px` horizontal padding.

```yaml
spacing:
  collage-gap: 2px
  grid-photo-gap: 4px
  card-text-x: 6px
  screen-photo-x: 8px
  card-pad: 8px
  card-pad-bottom: 12px
  bar-margin: 14px
  chip-pad-x: 16px
  dialog-pad: 24px
  sheet-pad-y: 28px
```

---

## Elevation & Depth

Hierarchy is established through **glassmorphism** over the ambient-glow `#121318` canvas and **tonal dark surface steps** (`#0A0A0B` viewer/editor stage -> `#121318` base -> `#1E1F25` surface -> `#292A31` raised surface):
- **Normal glass:** `background: rgba(255, 255, 255, 0.07); backdrop-filter: blur(22px) saturate(1.5); border: 1px solid rgba(255, 255, 255, 0.14); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.11);`
- **Strong glass (bars, menus, sheets, dialogs):** `background: rgba(34, 35, 44, 0.62); backdrop-filter: blur(22px) saturate(1.5); border: 1px solid rgba(255, 255, 255, 0.14); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.12), 0 10px 30px rgba(0, 0, 0, 0.35);`
- **Photos:** Never apply glass fills, blur, or borders to photo tiles or viewer images. Photos sit crisp and unstyled so their color gradients lead.

---

## Shapes

Generous Material Design 3 corner radii scale with container size:
- **Photo tile:** `12px` radius, square `1:1` crop in grid.
- **Editor assist chip:** `12px` radius, `44px` tall, `16px` horizontal padding.
- **Segmented button & Folder collage cover & FAB:** `20px` radius (`40px` tall segmented control; `60x60px` FAB on folders screen).
- **Menu:** `24px` radius (`236px` wide, `8px` padding, `52px` tall rows).
- **Primary button, Floating action bar, Folder card, Dialog, Bottom sheet (top corners):** `28px` radius (`56px` tall primary button, `68px` tall floating bar).
- **Icon buttons (`44x44px`), Dialog action pills (`48px` tall), Snackbar (`36px` inner action pill):** `9999px` full pill/circle.

```yaml
rounded:
  tile: 12px
  chip: 12px
  segmented: 20px
  cover: 20px
  fab: 20px
  menu: 24px
  card: 28px
  bar: 28px
  button: 28px
  dialog: 28px
  sheet-top: 28px
  full: 9999px
```

---

## Motion & Micro-interaction

Motion is calm, precise, and unhurried—never bouncy or playful. Interactive presses (icon buttons, chips, segmented controls) respond immediately (`100ms`), while glass sheets, menus, and dialogs enter with a smooth Material 3 decelerate curve (`250ms`) and exit cleanly (`150ms`). Photo zoom and pan transitions track finger velocity directly. Respect `prefers-reduced-motion` and animate only `transform` and `opacity` (never blur radius).

```yaml
motion:
  state-change:
    duration: 100ms
    delay: 0ms
    timingFunction: ease-out
  surface-enter:
    duration: 250ms
    delay: 0ms
    timingFunction: cubic-bezier(0.2, 0, 0, 1)
  surface-exit:
    duration: 150ms
    delay: 0ms
    timingFunction: cubic-bezier(0.3, 0, 1, 1)
```

---

## Voice & Content Strategy

- **Language:** All UI copy is in **Brazilian Portuguese** (`pt-BR`).
- **Tone:** Quiet, confident, and direct. Never playful, chatty, or exclamatory.
- **Capitalisation:** Sentence case for all screen titles, buttons, menu items, chips, and snackbars (e.g., *Pastas*, *Todas as fotos*, *Mover para pasta*, *Desfazer*).
- **Terminology:** Use *Pastas* (folders), *Fotos* (photos), *Favoritas* (favorites), *Lixeira* (trash), *Editar* (edit), *Cortar* (crop), *Filtros* (filters), *Ajustar* (adjust).
- **Action labels:** Concise verb phrases naming the outcome (*Salvar cópia*, *Excluir foto*, *Mover*, *Desfazer*), never generic *OK* or *Enviar*.
- **Sample photo content:** Stylized landscapes and abstract scenes in rich gradients—sunset skies (peach to coral), deep blue dusk with a pale moon, golden hour with terracotta hills, soft aqua-pink pastel sky, dark teal night, violet-magenta sky, and teal-to-blue sky—with layered rolling hills, a city skyline with lit windows, or overlapping translucent circles and a thin arc, across mixed aspect ratios (`4:3`, `3:4`, `16:9`, `1:1`, `4:5`, `3:2`).

## Components

Component implementations live as individual HTML sticker sheet files in
`components/`. Each file contains the canonical, styled HTML components with
`<!-- COMPONENT: name -->` comment markers. Read each file before use.

- **Button** → `@components/button.html` — `button-primary`, `button-icon`, `button-with-icon`
- **Card** → `@components/card.html` — `card-elevated`, `card-action`, `card-interactive`, `card-interactive-2`
- **Chip** → `@components/chip.html` — `chip-action`, `chip-input`, `chip-with-icon`
- **Modal** → `@components/modal.html` — `modal-standard`, `modal-alert`, `modal-drawer`
- **Toast** → `@components/toast.html` — `toast-success`
- **Typography** → `@components/typography.html` — `typography-display`, `typography-body`, `typography-label`
