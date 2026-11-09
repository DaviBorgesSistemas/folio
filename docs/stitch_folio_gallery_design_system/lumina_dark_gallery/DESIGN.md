---
name: Lumina Dark Gallery
colors:
  surface: '#121318'
  surface-dim: '#121318'
  surface-bright: '#38393e'
  surface-container-lowest: '#0d0e13'
  surface-container-low: '#1a1b20'
  surface-container: '#1e1f25'
  surface-container-high: '#292a2f'
  surface-container-highest: '#34343a'
  on-surface: '#e3e1e9'
  on-surface-variant: '#c7c5d0'
  inverse-surface: '#e3e1e9'
  inverse-on-surface: '#2f3036'
  outline: '#918f9a'
  outline-variant: '#46464f'
  surface-tint: '#bfc2ff'
  primary: '#e1e0ff'
  on-primary: '#282b5e'
  primary-container: '#bfc2ff'
  on-primary-container: '#4a4e83'
  inverse-primary: '#565a8f'
  secondary: '#c2c3ee'
  on-secondary: '#2b2d50'
  secondary-container: '#44466a'
  on-secondary-container: '#b4b5e0'
  tertiary: '#ffdad6'
  on-tertiary: '#51221d'
  tertiary-container: '#ffb4ab'
  on-tertiary-container: '#7a433d'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e0e0ff'
  primary-fixed-dim: '#bfc2ff'
  on-primary-fixed: '#121548'
  on-primary-fixed-variant: '#3e4276'
  secondary-fixed: '#e0e0ff'
  secondary-fixed-dim: '#c2c3ee'
  on-secondary-fixed: '#16183a'
  on-secondary-fixed-variant: '#424468'
  tertiary-fixed: '#ffdad5'
  tertiary-fixed-dim: '#ffb4ab'
  on-tertiary-fixed: '#360e0a'
  on-tertiary-fixed-variant: '#6c3832'
  background: '#121318'
  on-background: '#e3e1e9'
  surface-variant: '#34343a'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 64px
    fontWeight: '800'
    lineHeight: 72px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 34px
    fontWeight: '800'
    lineHeight: 42px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '800'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 26px
    letterSpacing: 0em
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 17px
    fontWeight: '700'
    lineHeight: 24px
    letterSpacing: 0em
  title-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 22px
    letterSpacing: 0em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.01em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: 0.01em
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.25rem
  margin: 0.875rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.875rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system establishes a focused, premium, content-first experience for a native mobile photo gallery, viewer, and editing suite. 

The stylistic direction blends the strict functional architecture of Material Design 3 with an ethereal, optical glassmorphic layer. Chromatic atmospheric glows drift behind deep obsidian stages, casting soft luminosity through frosted glass shells while ensuring photos remain completely unadulterated. 

Key attributes:
- **Atmospheric & Submerged:** UI chrome dissolves into optical glass surfaces with high-diffusion backdrops, prioritizing photographic media above all else.
- **Precision Materiality:** Controls use hairline perimeter specular highlights, subtle ambient occlusion shadows, and distinct tonal states to communicate affordance clearly in dark environments.
- **Locale Fidelity:** Every interaction, microcopy string, label, and dialog follows native Brazilian Portuguese (pt-BR) conventions, utilizing natural, idiomatic terminology for visual asset management and image adjustments.

## Colors

The palette employs a Material 3 dark tonal distribution balanced against optical frosted layers:

### Canvas & Surface Layers
- **Stage Background (`#0A0A0B`):** Pure deep stage reserved exclusively behind active photo viewing and canvas editing surfaces.
- **Base Canvas (`#121318`):** Foundational application canvas beneath atmospheric blurs.
- **Surface (`#1E1F25`):** Level 1 container foundation.
- **Raised Surface (`#292A31`):** Level 2 resting containers and nested utility areas.
- **Outline (`#44454F`):** Structural borders for standard inputs, segmented outlines, and chips.

### Brand & Interactive Accents
- **Primary Accent (`#BFC2FF`):** Luminous blue-violet used for high-emphasis primary actions, focal state icons, and interactive emphasis. Text on primary is `#272A78`.
- **Secondary Container (`#3F4165`):** Selected segment fills, activated filter chips, and pill states. Text on secondary container is `#DFE0FF`.
- **Danger (`#FFB4AB`):** Destructive actions, warnings, and deletion confirmations. Text on danger is `#690005`.
- **Content Neutral (`#E3E1E9`):** Primary typography and high-contrast icons.
- **Muted Neutral (`#C5C5D0`):** Secondary metadata, inactive icons, timestamps, and subtitles.

### Ambient Atmospheric Glows
Fixed behind the base canvas (`#121318`):
- Top-Left: `rgba(122, 128, 255, 0.34)` with 120px blur radius.
- Right (28% viewport height): `rgba(255, 128, 190, 0.20)` with 140px blur radius.
- Bottom-Left: `rgba(60, 200, 210, 0.20)` with 130px blur radius.

### Glass Formulations
- **Standard Glass:** `rgba(255, 255, 255, 0.07)` surface fill, 1px perimeter border `rgba(255, 255, 255, 0.14)`, top-edge specular highlight `rgba(255, 255, 255, 0.11)`. Backdrop filter: `blur(22px) saturate(150%)`.
- **Strong Glass:** `rgba(34, 35, 44, 0.62)` surface fill for floating navigation bars, modal sheets, contextual menus, and system dialogs. Backdrop filter: `blur(22px) saturate(150%)`.
- **Tinted FAB Glass:** `rgba(122, 128, 255, 0.28)` surface fill with 1px `rgba(191, 194, 255, 0.32)` perimeter highlight.

## Typography

The typography relies strictly on **Plus Jakarta Sans** across all hierarchies, balancing geometric clarity with warmth:

- **Metric Counter Display (`display-lg`):** 64px ExtraBold, line-height 72px, tabular numbers. Used for photo counter badges, batch selection quantities, and editor crop ratio indices.
- **Primary Section Header (`headline-lg`):** 34px ExtraBold. Applied to main screen titles ("Fotos", "Álbuns", "Biblioteca").
- **Modal & Sheet Headers (`headline-md`):** 22px ExtraBold. Used for bottom sheets ("Detalhes da Foto", "Exportar Imagem") and modal alerts.
- **Top App Bar Title (`headline-sm`):** 20px Bold. Centered or left-aligned navigation titles.
- **Folder and Asset Titles (`title-sm`):** 16px Bold. Applied to album card labels and filenames.
- **Interactive Action Labels (`title-md`):** 17px Bold. Used exclusively inside the 56px primary button.
- **Body Text (`body-md` / `body-lg`):** 15px to 16px Regular. Used for descriptions, cloud sync statuses, and permissions prompts.
- **Captions & Secondary Data (`label-sm`):** 13px to 14px Medium/Regular in Muted Neutral (`#C5C5D0`). Used for EXIF metadata (aberturas f/stop, ISO, velocidade), timestamps ("Ontem às 18:42"), and byte sizes.

## Layout & Spacing

Designed specifically for the target canvas of **390px × 844px** (standard portrait mobile viewports):

- **Margins:** Standard canvas edge margin is set to `14px` (`0.875rem`), giving content breathing room while maximizing visual media area.
- **Photo Grid Layout:** 3-column strict uniform square tile grid (`1:1`). Gutters between tiles are exactly `4px` (`0.25rem`). Outer margin matches the 4px grid boundary for full bleed or 14px when inset.
- **Floating Overlays:** Floating action bars, detached navigation docks, and snacks respect the `14px` outer canvas margin, floating safely above iOS gesture indicators and home bars with `24px` to `34px` bottom padding.
- **Component Padding Rhythm:**
  - Micro (`space-xs` / 4px): Tight gaps between grid media items and badge insets.
  - Compact (`space-sm` / 8px): Padding inside folder cards surrounding the 2x2 collage.
  - Default (`space-md` / 14px): Horizontal padding for menu rows, chip content insets, and floating docks.
  - Generous (`space-lg` / 16px to `space-xl` / 24px): Padding within modal sheets and edit panels.

## Elevation & Depth

Depth is established via optical transmission, surface luminance, and diffused ambient occlusion rather than harsh drop shadows:

- **Level 0 (Stage/Canvas):** Base background `#121318` and photo viewer stage `#0A0A0B`. Zero elevation.
- **Level 1 (Submerged Cards):** Folder and album cards using standard glass (`rgba(255, 255, 255, 0.07)`), receiving background blur and a 1px border `rgba(255, 255, 255, 0.14)`.
- **Level 2 (Detached Chrome & Floating Bars):** Floating bottom navigation docks, top app toolbars, and contextual editor controls. Constructed with strong glass (`rgba(34, 35, 44, 0.62)`), backdrop blur `22px`, saturation `150%`, an inner top border highlight `rgba(255, 255, 255, 0.11)`, and an ambient occlusion drop shadow: `0 10px 30px rgba(0, 0, 0, 0.35)`.
- **Level 3 (Modals, Overlays & Sheets):** Context menus (236px width), bottom sheets, and dialogs. Enhanced strong glass with elevated ambient drop shadow `0 20px 40px rgba(0, 0, 0, 0.55)` and 1px continuous hairline highlight.
- **Media Invariance Rule:** Image thumbnails, photo tiles, and the editor canvas must **never** be rendered with glass fills, translucency, or backdrop blurs. Photographic content remains visually opaque, sharp, and true to source.

## Shapes

The design system uses a rounded structural language (Level 2 base with hyper-rounded controls) to soften the dark glass aesthetic:

- **Photo Tiles:** `12px` corner radius. Maintains square integrity while eliminating sharp optical edges.
- **Chips & Tag Elements:** `12px` corner radius across a `44px` height container.
- **Folder / Collage Cards:** `28px` corner radius on the parent glass container; nested 2x2 collage quadrants have `20px` internal corner radii.
- **Floating Action Button (FAB):** `20px` corner radius on a `60px × 60px` container.
- **Floating Bottom Bars, Top Bars & Bottom Sheets:** `28px` corner radius. Bottom sheets feature a continuous `28px` radius on the top-left and top-right corners.
- **Context Menus:** `24px` corner radius.
- **Pills & Buttons:** Full pill contours. Primary 56px buttons use `28px` radius; 40px segmented buttons use `20px` radius; snackbars use full pill radius.

## Components

### Buttons
- **Botão Primário (Primary Button):** Height `56px`, full-width, corner radius `28px`. Solid accent fill `#BFC2FF`. Typography: 17px Bold Plus Jakarta Sans in `#272A78`. Active state shifts opacity to `0.9` and scales slightly to `0.98`.
- **Botão Fantasma (Ghost Button):** Height `48px`, transparent background, text in `#C5C5D0` (15px Medium). Pressed state applies a transient `rgba(255, 255, 255, 0.05)` fill.

### Segmented Buttons
- Height `40px`, radius `20px`, 1px border in `#44454F`, standard glass fill.
- Contains 3 segments (e.g., "Dia", "Mês", "Ano" or "Ajustar", "Filtros", "Cortar").
- Inactive segment text: `#C5C5D0` (14px Medium).
- Active segment: Pill fill `#3F4165`, text `#DFE0FF` (14px SemiBold) preceded by a 16px checkmark icon (`✓`).

### Assist Chips
- Height `44px`, radius `12px`, 1px outline in `#44454F`, standard glass fill. 
- Selected state: solid fill `#3F4165`, text `#DFE0FF`, border tint `rgba(191, 194, 255, 0.3)`.
- Inactive state: text `#C5C5D0`. Horizontal scrollable container with 8px gaps. Example labels: "Favoritos", "Vídeos", "Capturas de tela", "Retratos".

### Floating Action Button (FAB)
- Dimensions `60px × 60px`, corner radius `20px`.
- Fill: Tinted blue-violet glass `rgba(122, 128, 255, 0.28)`, backdrop blur `22px`, 1px perimeter border `rgba(191, 194, 255, 0.34)`.
- Icon: 24px Plus icon in `#BFC2FF` (1.8px stroke, rounded ends). Shadow: `0 8px 24px rgba(0, 0, 0, 0.4)`.

### Folder & Album Cards
- Container: Standard glass fill, `28px` radius, `8px` internal padding.
- Cover: 2x2 photo collage grid (`20px` radius on each preview cell).
- Card footer: Folder title in `#E3E1E9` (`title-sm`), photo count string (e.g., "1.240 fotos") in `#C5C5D0` (`label-sm`).

### Photo Tiles
- 3-column responsive square grid with `4px` gaps.
- Corner radius `12px`. Raw opaque image content (no glass effect).
- Multi-selection overlay: Selected state shows a 2px inner ring in `#BFC2FF` and a top-right circular badge (22px pill, `#BFC2FF` fill with `#272A78` checkmark).

### Floating Action Bars (Detached Chrome)
- Floating dock height `68px`, margin `14px` from canvas edges, corner radius `28px`.
- Fill: Strong glass `rgba(34, 35, 44, 0.62)`, backdrop blur `22px`, saturation `1.5`, 1px border highlight `rgba(255, 255, 255, 0.14)`.
- Icon actions: 24px outline icons with 1.8px stroke width and round line caps ("Compartilhar", "Editar", "Favoritar", "Apagar").

### Menus
- Width fixed at `236px`, corner radius `24px`.
- Strong glass fill with ambient shadow `0 20px 40px rgba(0, 0, 0, 0.5)`.
- Item rows: Height `52px`, horizontal padding `16px`. Text in `#E3E1E9` (`body-md`), trailing shortcut or icon in `#C5C5D0`. Destructive item ("Excluir álbum") uses text `#FFB4AB`.

### Bottom Sheets & Dialogs
- Strong glass fill, top-left and top-right corner radius `28px`.
- Header: Centered drag handle (36px × 4px, `#44454F`, 2px radius) with 12px margin. Title in `#E3E1E9` (`headline-md`).
- Primary actions inside sheets follow the standard 56px primary button styling.

### Snackbar
- Floating pill geometry, height `48px`, horizontal margin `14px`, corner radius `24px`.
- Surface: Solid `#E3E1E9` with text in `#121318` (`label-md`, 14px SemiBold).
- Embedded action: Pill button with text in `#272A78` ("Desfazer").

### Iconography Guidelines
- All icons rendered at `24px × 24px` grid box with `1.8px` stroke width, outline style only, with rounded joins and end caps.