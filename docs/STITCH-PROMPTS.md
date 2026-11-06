# Folio — Prompts Stitch

Prompts em inglês para o Google Stitch, escritos para reproduzir o protótipo [folio.html](folio.html) o mais fiel possível: mesmas cores, fonte, medidas, textos e estados. O visual é **Material Design 3 com vidro fosco (glassmorphism)**. Todos os textos da interface ficam em português do Brasil, exatamente como no protótipo.

**Como usar:** cole primeiro o **Design System** em um projeto novo do Stitch, depois gere uma tela por vez. Cada prompt de tela repete as medidas essenciais para funcionar isolado. Gere em **mobile**, tema **escuro**.

**O que mudou nesta versão:** paleta Material 3 (azul-violeta) no lugar do verde-água; fundo com manchas de cor e superfícies de vidro; botão segmentado e botão flutuante (FAB); pasta virtual **Favoritas**; visualizador em tela cheia com barra de ações flutuante e zoom; excluir sem diálogo, com aviso "Desfazer".

**Telas do protótipo (7) e camadas (5):**

| # | Tela | Camadas que abrem nela |
|---|---|---|
| 0 | Splash | — |
| 1 | Boas-vindas | — |
| 2 | Leitura | — |
| 3 | Pastas | Campo de busca |
| 4 | Dentro da pasta | Modo de seleção, menu da pasta, aviso "Desfazer" |
| 5 | Visualizador | Menu "Mais", informações, copiar/mover, renomear, slideshow, zoom |
| 6 | Editor | 5 abas de ferramentas, diálogo de descartar |

---

## Design System (colar primeiro)

```
Create a mobile design system for "Folio", a photo gallery app that reads the images on the phone and groups them by folder. It has a viewer with zoom and a built-in image editor. Dark UI only. Portrait 390x844. All UI text in Brazilian Portuguese.

LOOK & FEEL: Material Design 3 structure combined with glassmorphism. Material 3 gives the system: tonal dark color scheme, large rounded shapes, a segmented button, a floating action button, snackbars with an action. Glassmorphism gives the surface: translucent frosted-glass panels (backdrop blur) floating over a softly colored gradient background. Photos stay the hero; the glass steps back and lets them lead. Calm, premium, content-first.

BACKGROUND (important, glass needs something behind it): base #121318 with three large soft blurred color glows: a blue-violet glow (rgba(122,128,255,.34)) in the top-left corner, a pink glow (rgba(255,128,190,.20)) on the right at about 28% height, and a teal glow (rgba(60,200,210,.20)) at the bottom-left. No hard edges, no patterns.

COLORS (Material 3 dark tonal scheme, use exactly)
- Base background: #121318 (plus the glows above). Viewer stage and editor stage (behind the photo): #0A0A0B. Page outside the phone: #07070A.
- Surface: #1E1F25. Raised surface: #292A31. Outline: #44454F.
- Text: #E3E1E9. Muted text: #C5C5D0.
- Primary (accent, blue-violet): #BFC2FF. Text/icon ON primary: #272A78.
- Secondary container (selected segment, selected chip): #3F4165. Text ON it: #DFE0FF.
- Danger: #FFB4AB for destructive text and icons; destructive button background #FFB4AB with text #690005.
- GLASS: normal glass fill rgba(255,255,255,0.07); strong glass (bars, menus, sheets, dialogs) fill rgba(34,35,44,0.62); glass border 1px rgba(255,255,255,0.14); background blur 22px with saturation 1.5; a 1px inner highlight along the top edge (rgba(255,255,255,0.10-0.12)); floating bars also get a soft shadow (0 10px 30px rgba(0,0,0,.35)).

TYPOGRAPHY: Plus Jakarta Sans only. Screen titles 34px extra-bold (800), letter-spacing -0.035em. Top-bar titles 20px bold (700). Big numbers 64px extra-bold, tabular numerals. Body 15-16px; folder/file names 16px bold; counts and captions 13-14px muted. Buttons 17px bold. Dialog and sheet titles 22px extra-bold.

SHAPES
- Primary button: full width, 56px tall, fully rounded (28px), solid primary #BFC2FF, text #272A78, 17px bold. Ghost button: transparent, 48px tall, muted text, 15px semibold.
- Segmented button (Material 3): full width, 40px tall, 20px radius, 1px outline #44454F, glass fill, three equal segments separated by 1px dividers, 13px semibold labels. The active segment has a check mark before its label, fill #3F4165 and text #DFE0FF; inactive text is muted.
- Chips (assist chips, used in the editor): 44px tall, 16px padding, 12px radius, 1px outline #44454F, glass fill, text #E3E1E9, 14px semibold. Selected chip: fill #3F4165, no border, text #DFE0FF.
- Floating action button (Material 3): 60x60, 20px radius, glass fill tinted blue-violet (rgba(122,128,255,.28)), glass border, primary-colored plus icon, soft shadow. Only on the folders screen.
- Icon buttons: 44x44 circles, transparent; pressed state fills glass.
- Folder card: a glass card, 28px radius, 8px padding (12px at the bottom), containing a square cover with 20px radius (2x2 collage of photos with 2px gaps) and, under it, the folder name and count with 6px side padding.
- Photo tile: square, 12px radius, 4px gaps in a 3-column grid, 8px side padding. Photos are NOT glass.
- Floating action bars (viewer and selection): detached from the screen edges, 14px side and bottom margin, 68px tall, 28px radius, strong glass.
- Menus: 236px wide, strong glass, 24px radius, 8px padding, 52px tall rows with a 22px icon, 16px gap and 16px semibold label.
- Bottom sheet: strong glass, 28px top radius, 28/24px padding. Dialog: strong glass, 28px radius, 24px padding, 24px side margin, actions right-aligned as 48px pills (neutral rgba(255,255,255,.10), primary #BFC2FF, danger #FFB4AB).
- Snackbar (Material 3): pill, fill #E3E1E9, text #121318, 14px semibold, centered above the bottom bar. Optional action button inside, right side: 36px pill, bold 14px text #3B3E8F on a light violet tint, e.g. "Desfazer".

ICONS: outline, 1.8px stroke, round caps and joins, 24px (22px in menus and editor tabs). Set used: back arrow, forward arrow, search, plus, three vertical dots, heart (outline, or filled in the accent when favorited), info (circle with i), share (three connected nodes), lock, trash, magic wand (editor entry), pencil, play, copy, folder, folder with arrow (move), open-with (arrow out of tray), printer, phone, check, close (X), crop, filters (three overlapping circles), adjust (two sliders), brush, text (T), rotate left/right, flip, undo, loading ring.

PHOTO CONTENT: the sample photos are stylized landscapes and abstract scenes in rich gradients: sunset skies (peach to coral), deep blue dusk with a pale moon, golden hour with terracotta hills, soft aqua-pink pastel sky, dark teal night, violet-magenta sky, and teal-to-blue sky; with layered rolling hills, a city skyline with lit windows, or overlapping translucent circles and a thin arc. Mixed aspect ratios (4:3, 3:4, 16:9, 1:1, 4:5, 3:2).

TONE: quiet and confident, never playful. Use glass only where specified (cards, bars, menus, sheets, dialogs, inputs), never on individual photos.
```

---

## 0. Splash

```
Design the SPLASH screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), following the Folio design system (Material 3 + glassmorphism): background #121318 with soft blurred glows (blue-violet top-left, pink on the right, teal bottom-left), text #E3E1E9, muted #C5C5D0, primary #BFC2FF (text on primary #272A78), font Plus Jakarta Sans. This is the first thing the user sees; it disappears by itself after about 2 seconds, or on tap, and goes to the welcome screen. No buttons, no navigation, no status text.

Layout: everything centered both horizontally and vertically, with 24px side padding.
1. App logo, a glass tile holding the Folio mark (NOT a bright app-icon square, it must belong to the dark glass UI): a 120px rounded square (36px radius) in frosted dark glass: fill a diagonal gradient from rgba(255,255,255,.16) to rgba(255,255,255,.05), 1px border rgba(255,255,255,.14), backdrop blur, a 1px inner highlight on the top edge, and a soft blue-violet glow beneath it (0 18px 50px rgba(122,128,255,.38)). Inside, filling about 90% of the tile, the Folio mark: a fan of three photo cards. Two translucent lavender cards (#BFC2FF at 30% and 55% opacity) behind, tilted about -16 and +11 degrees, and a front card, pale white-lavender (#F7F7FF to #D4D7FF), rounded about 23%, with a violet glow shadow, showing a minimalist landscape: a small coral-to-peach sun at the top right, a lighter violet mountain range (#9AA0FF) and a darker navy-indigo range (#272A78) in front. The mark has no background of its own.
2. 20px below: the wordmark "Folio" at 38px extra-bold (800), letter-spacing -0.04em, color #E3E1E9.
3. 12px below: tagline "Sua galeria, organizada" in 15px regular muted #C5C5D0.
4. At the bottom, 56px above the screen edge, centered: three small 8px dots with 8px gaps, #2C2C32, the middle one in primary #BFC2FF (a quiet loading indicator).

Motion notes (for the description only): logo scales in from 70% with a soft ease; the wordmark and tagline fade up 10px one after the other; the three dots blink to the accent in sequence. Respect reduced motion by showing it static.
```

---

## 1. Boas-vindas

```
Design the WELCOME screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), following the Folio design system (Material 3 + glassmorphism): base #121318 with soft blurred glows (blue-violet top-left, pink right, teal bottom-left), text #E3E1E9, muted #C5C5D0, primary #BFC2FF (text on primary #272A78), glass fill rgba(255,255,255,.07) with 1px border rgba(255,255,255,.14) and 22px backdrop blur, font Plus Jakarta Sans.

Layout, top to bottom, with 24px side padding and 28px top padding:
1. Brand row: the same Folio mark on a 36px frosted dark-glass tile (12px radius, glass border), exactly as described in the splash prompt, then the word "Folio" 20px extra-bold, letter-spacing -0.02em.
2. Hero, centered in the free space: a frosted-glass card 300px wide (glass fill, 1px glass border, 28px radius, 16px padding, inner top highlight). Its header row has a small primary-colored folder icon, the bold name "WhatsApp" and the muted count "1.335" on the right. Under it a 3-column mosaic of 6 square photos (12px radius, 6px gaps) with the stylized landscape gradients from the design system. Overlapping the card's bottom-right corner (offset about -10px right and -16px down) a primary pill badge, dark text, 13px bold: "8 pastas encontradas".
3. Heading "Suas fotos, separadas por pasta" at 31px, extra-bold, line-height 1.1, balanced wrapping, letter-spacing -0.03em.
4. Lead text, 16px muted, line-height 1.5: "O Folio lê as imagens do seu celular e mostra cada pasta em um só lugar."
5. Checklist of 3 rows, each with a primary-colored check icon (20px) and 15px text, 10px gap: "Encontra todas as pastas com imagens", "Mostra quantas imagens há em cada uma", "Não apaga nem move nada sem você pedir".
6. Primary button, full width, 56px, fully rounded (28px): "Permitir acesso às fotos".
7. Ghost button below, 48px, muted text: "Agora não".

No bottom navigation on this screen.
```

---

## 2. Leitura

```
Design the SCANNING screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system (Material 3 + glassmorphism): base #121318 with soft blurred color glows, primary #BFC2FF, glass fill rgba(255,255,255,.07), glass border rgba(255,255,255,.14), Plus Jakarta Sans. 24px side and 28px top padding. Show the screen mid-scan.

Top to bottom:
1. Small primary-colored eyebrow, 14px bold: "Lendo seu celular".
2. Huge number, 64px extra-bold, tabular numerals, letter-spacing -0.04em, 8px below: "1.698".
3. Muted 16px line: "imagens encontradas em 5 pastas".
4. Progress bar, 20px below: 8px tall, fully rounded, track #27272D, fill primary at about 43%. Under it a muted 13px caption: "43% concluído".
5. A tall frosted-glass card (28px radius, glass fill, 1px glass border, backdrop blur, 4px/16px padding, 20px vertical margin) listing the folders as they are read, newest at the bottom. Each row is at least 50px tall, 12px gap, 1px divider rgba(255,255,255,.08): a 22px primary check icon, the folder name 16px semibold, and the count on the right in muted 15px tabular numerals. Completed rows, in order: WhatsApp 1.335, Screenshots 187, Ux 91, Pins 64. The current row (Downloads) shows a spinning ring icon (a faint circle with a primary quarter arc), the name, and a primary-colored count with ellipsis: "21…".
6. Primary button, full width, disabled state (55% opacity): "Lendo…".

Also provide the completed variant: number "10.917", "imagens encontradas em 8 pastas", bar at 100%, "100% concluído", all 8 rows with check icons (WhatsApp 1.335, Screenshots 187, Ux 91, Pins 64, Downloads 38, Thing 12, WhatsApp Documents 2, Camera 9.188), and the button enabled: "Ver pastas encontradas".
```

---

## 3. Pastas

```
Design the FOLDERS screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system (Material 3 + glassmorphism): base #121318 with soft blurred glows (blue-violet top-left, pink on the right, teal bottom-left), text #E3E1E9, muted #C5C5D0, primary #BFC2FF, secondary container #3F4165 with text #DFE0FF, outline #44454F, glass fill rgba(255,255,255,.07), glass border rgba(255,255,255,.14), 22px backdrop blur, Plus Jakarta Sans.

Top to bottom:
1. Top bar, 64px: title "Pastas" at 34px extra-bold (letter-spacing -0.035em, 16px left padding) and, on the right, one 44px circular search icon button. (There is no plus button here; it is the floating button below.)
2. Muted 15px line under the title, 24px side padding: "10.917 imagens · 8 pastas".
3. Material 3 segmented button, full width (20px side margin, 14px top, 40px tall, 20px radius, 1px outline, glass fill): "Mais imagens" (active: check mark, fill #3F4165, text #DFE0FF), "A–Z", "Recentes".
4. Two-column grid of frosted-glass folder cards (20px side padding, 12px gaps). Each card: glass fill, 1px glass border, 28px radius, 8px padding, inner top highlight; inside, a square cover with 20px radius showing a 2x2 collage of four photos with 2px gaps; below it the folder name 16px bold (single line, ellipsis) and the count in muted 14px, "N imagens". The FIRST card is always "Favoritas": its cover is a collage of 4 favorite photos with a small round glass badge at the bottom-left holding a filled primary heart; "3 imagens". (Variant with no favorites: empty cover with a large centered filled primary heart, "0 imagens".) Then, in this order: Camera 9.188 imagens, WhatsApp 1.335 imagens, Screenshots 187 imagens, Ux 91 imagens, Pins 64 imagens, Downloads 38 imagens, Thing 12 imagens, WhatsApp Documents 2 imagens. Use the stylized landscape gradients for the photos.
5. A floating action button at the bottom-right (20px from the right, 24px from the bottom): 60x60, 20px radius, blue-violet tinted glass, primary plus icon, soft shadow. At the bottom of the scroll, muted 13px helper text: "Toque no botão + para testar o editor com fotos do seu aparelho. Elas aparecem na pasta Importadas."

No bottom navigation.

Also design the SEARCH state as a second frame: the search icon toggled, and under the top bar a 48px fully rounded glass input (1px glass border, 18px padding, 16px text) with placeholder "Buscar pasta"; the grid filtered to folders matching "what" showing only WhatsApp and WhatsApp Documents. Empty state variant: centered muted text "Nenhuma pasta encontrada."
```

---

## 4. Dentro da pasta

```
Design the FOLDER CONTENTS screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system (Material 3 + glassmorphism): base #121318 with soft blurred color glows, primary #BFC2FF, glass fill rgba(255,255,255,.07), strong glass rgba(34,35,44,.62), glass border rgba(255,255,255,.14), 22px backdrop blur. Show FOUR frames.

FRAME A — normal:
- Top bar 64px: 44px circular back arrow button; a two-line title: folder name "WhatsApp" 20px bold with "1.335 imagens" under it in 13px muted; on the right a 44px circular three-dots button.
- Photo grid: 3 columns, square tiles with 12px radius, 4px gaps, 8px side padding. 18 stylized landscape/abstract photos with varied palettes. Three tiles show a small primary filled heart at the bottom-right corner (favorites) with a subtle dark shadow for legibility. The photos themselves are not glass.

FRAME B — menu open: same screen with a transparent scrim and a 236px strong-glass menu (24px radius, 8px padding) anchored at the top-right under the three-dots button, with two rows (52px tall, 22px icon, 16px label): check icon "Selecionar" and back-arrow icon "Mais antigas primeiro".

FRAME C — selection mode:
- Top bar: 44px close (X) button and the title "3 selecionadas" (20px bold).
- Grid as before; each tile shows a 24px circle at the top-left: unselected = 2px white border with 35% black fill; selected = solid primary fill with a dark check. Selected tiles have their photo dimmed to 60% opacity. Show 3 selected tiles and 2 favorites.
- A FLOATING glass action bar, detached from the edges (14px side and bottom margin), 68px tall, 28px radius, strong glass with a glass border and soft shadow, two equal columns, each an icon above an 11px label: heart "Favoritar" and trash "Excluir" in danger #FFB4AB. The grid scrolls underneath it, visible through the blur.

FRAME D — after deleting (no confirmation dialog is used): the grid without the 3 deleted photos and, above the bottom, a Material 3 snackbar pill (fill #E3E1E9, text #121318, 14px semibold): "3 imagens excluídas" with a "Desfazer" action button on its right (36px pill, bold 14px text #3B3E8F on a light violet tint).

Empty state variant: centered muted text "Esta pasta está vazia."

FAVORITAS variant (same screen, title "Favoritas", "3 imagens"): same grid showing favorites from different folders; empty state text: "Toque no coração de uma imagem para ela aparecer aqui."
```

---

## 5. Visualizador

```
Design the PHOTO VIEWER screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system (Material 3 + glassmorphism). It is a FULL-SCREEN viewer: the photo fills the whole screen on a near-black #0A0A0B stage, and the top bar and the action bar float over it. Show FIVE frames.

FRAME A — viewer:
- Top bar 72px, overlaid on the photo with a dark gradient fading from rgba(10,10,11,.8) to transparent (no solid background): 44px circular back arrow; two-line title: "Hoje 14:32" in 20px bold and "3 de 48" under it in 13px muted; then two 44px circular icon buttons: heart (outlined, or filled primary when favorited) and info.
- Stage: one large photo (a 16:9 stylized sunset landscape, peach-to-coral sky, pale sun, layered purple hills) contained and centered, never cropped, filling the screen between the bars. At the vertical middle, two 44px circular frosted-glass buttons (strong glass, glass border) at the edges (8px from the sides) with white arrows (back and forward).
- A FLOATING glass action bar at the bottom, detached from the edges (14px side and bottom margin), 68px tall, 28px radius, strong glass (rgba(34,35,44,.62), 22px blur, 1px border rgba(255,255,255,.14), inner top highlight, soft shadow), five equal columns, each an icon over an 11px medium label: share "Compartilhar", lock "Bloquear", trash "Excluir" (danger #FFB4AB), magic wand "Editar", three-dots "Mais". The photo shows through the blur.

FRAME B — "Mais" menu: scrim transparent, a 236px strong-glass menu (24px radius) anchored bottom-right above the action bar (16px from the right, 96px from the bottom) with 7 rows: pencil "Renomear", play "Slideshow", copy "Copiar para", folder-arrow "Mover para", open-with "Abrir com", printer "Imprimir", phone "Definir como".

FRAME C — "Informações" bottom sheet over a dimmed viewer (scrim rgba(0,0,0,.62)): strong-glass sheet, 28px top radius, padding 28/24, title "Informações" 22px extra-bold, then 6 rows, label bold 15px in a 104px column and muted value: "Nome" IMG_4821.jpg; "Caminho" /storage/emulated/0/Pictures/WhatsApp; "Tamanho" 412,5 KB; "Resolução" 1200 × 675 (0,8 MP); "Última modificação" 04/11/2026 14:32; "Data de criação" 18/03/2025 09:14. A full-width primary button "OK" closes it.

FRAME D — slideshow running: same as frame A but a primary pill button centered below the top bar (about 80px from the top), 44px tall, dark bold text 14px: "Parar slideshow".

FRAME E — zoomed: the same photo magnified about 2.5x, cropped by the screen edges, the two side arrow buttons hidden, the top bar and the floating action bar unchanged. No zoom controls: zoom is by pinch or double tap.

DELETE: there is no confirmation dialog. After tapping "Excluir", the next photo is shown and a snackbar pill (fill #E3E1E9, text #121318) appears above the action bar: "Imagem excluída" with a "Desfazer" action (36px pill, bold 14px text #3B3E8F on a light violet tint).
```

---

## 5b. Visualizador — copiar, mover e renomear

```
Design two overlays for the photo viewer of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system (Material 3 + glassmorphism), over the dimmed viewer (scrim rgba(0,0,0,.62)).

FRAME A — "Mover para" bottom sheet: strong glass (rgba(34,35,44,.62), 22px blur, 1px top border rgba(255,255,255,.14)), 28px top radius, padding 28/24, title "Mover para" 22px extra-bold. List of folder rows, each at least 56px tall with a 1px divider #44454F: a 24px folder icon, the folder name 16px semibold, and on the right the count in muted 13px: Camera 9.188, Screenshots 187, Ux 91, Pins 64, Downloads 38, Thing 12, WhatsApp Documents 2 (the photo's current folder, WhatsApp, is not listed). (The "Copiar para" variant is identical with the title "Copiar para".)

FRAME B — "Renomear" dialog: centered, strong glass, 28px radius, 24px padding, 24px side margins. Title "Renomear" 22px extra-bold; a 48px fully rounded glass text input (1px glass border, text 16px) holding "IMG_4821.jpg" with a primary focus ring; right-aligned pills "Cancelar" (neutral rgba(255,255,255,.10)) and "OK" (primary, dark text).

Add a snackbar at the bottom of a third small frame: pill #E3E1E9, dark text 14px semibold: "Movida para WhatsApp".
```

---

## 6. Editor

```
Design the IMAGE EDITOR screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system (Material 3). The editor uses a SOLID #121318 background (no glow, no glass on the main layout; only dialogs are glass). Layout from top to bottom: top bar (64px), image stage (flexible), tool panel (168px tall, 1px top border rgba(255,255,255,.08), 16px side padding, 12px top padding), tab bar (72px tall, 1px top border rgba(255,255,255,.08), five equal tabs). Show FIVE frames, one per tool, all editing the same photo (a stylized dusk skyline with lit windows, deep blue sky, pale moon).

Common top bar: 44px circular close (X) button; title "Editar" 20px bold; a 44px outlined chip "Restaurar" (12px radius); and a primary pill "Salvar" (44px tall, 20px padding, text #272A78 bold 15px).
Common stage: near-black #0A0A0B, the photo centered with a 6px radius, 12px side padding.
Common tab bar: icon (22px) over a 12px semibold label; selected tab in primary #BFC2FF, others muted #C5C5D0: crop "Cortar", filters "Filtros", adjust "Ajustes", brush "Desenhar", text "Texto".

FRAME 1 — "Cortar" selected: panel row 1 of chips (44px, 12px radius): "Original" (selected: fill #3F4165, text #DFE0FF), "1:1", "4:5", "3:4", "16:9", "9:16". Row 2 of chips with icons: rotate-left "Esquerda", rotate-right "Direita", flip "Espelhar". Under them a 12px muted note: "O corte é centralizado na imagem." The photo preview is cropped to 4:5 in a variant.

FRAME 2 — "Filtros" selected: a horizontally scrolling row of filter thumbnails, each 76px square with a 14px radius, 2px transparent border (primary border when selected), label under it 12px semibold (primary when selected, muted otherwise): Original (selected), Vívido, Quente, Frio, P&B, Sépia, Fade, Noir. Each thumbnail shows the same photo with its own look (vivid saturated, warm sepia tint, cool bluish, black-and-white, sepia, faded low-contrast, high-contrast noir). The stage photo shows the selected filter.

FRAME 3 — "Ajustes" selected: row of chips "Brilho" (selected), "Contraste", "Saturação", "Calor", "Desfoque". Below it a slider row (44px): a track with primary thumb and fill, value output on the right in white tabular numerals, "35".

FRAME 4 — "Desenhar" selected: a row of 7 color swatches (28px circles with a 2px #3A404C border, 44px touch targets): white #FFFFFF (selected, with a white outline ring and 2px offset), #111111, #FF5A5F, #FFC145, #BFC2FF, #4C8DFF, #C86BFA, followed by an undo icon button. Below: a slider row labeled "Espessura" (muted 14px) with a primary slider. The stage photo shows two hand-drawn rounded strokes (one coral, one white) over the skyline.

FRAME 5 — "Texto" selected: a row with a 44px rounded input (placeholder "Digite o texto", value "Boa noite") and a primary chip "Adicionar" (primary fill, dark text); a swatch row like in Desenhar ending with a red-tinted trash icon button (danger #FFB4AB); a slider row "Tamanho". The stage photo shows the text "Boa noite" centered in extra-bold white with a soft shadow and a dashed primary selection rectangle around it.

Also design the DISCARD dialog over the dimmed editor (scrim rgba(0,0,0,.62)): strong-glass dialog, title "Descartar alterações?", muted text "As edições feitas nesta imagem serão perdidas.", pills "Cancelar" (neutral) and "Descartar" (danger #FFB4AB, text #690005).
```

---

## Notas de fidelidade

- **Sem navegação inferior.** O Folio não tem tab bar global; a navegação é por pilha (voltar) e pelas barras de ação de cada tela. Não deixe o Stitch adicionar uma. O único botão flutuante é o "+" da tela Pastas.
- **O fundo precisa ter cor.** O vidro só aparece se houver algo colorido atrás. Se o Stitch gerar um fundo liso, peça de novo reforçando as três manchas de cor (azul-violeta, rosa e turquesa).
- **Vidro só onde está dito:** cards de pasta, barras flutuantes, menus, folhas, diálogos, campo de busca e botões de navegação do visualizador. Nunca nas fotos.
- **Um só acento.** Azul-violeta `#BFC2FF` em tudo que é ação, seleção ou estado ativo; `#3F4165` para itens selecionados. Vermelho `#FFB4AB` só para excluir e descartar.
- **Excluir não tem diálogo.** O Stitch tende a desenhar uma confirmação; no Folio a exclusão é imediata e o aviso "Desfazer" aparece por 5 s. O único diálogo de confirmação que sobrou é o de "Descartar alterações?" do editor.
- **Os rótulos "Camera", "Screenshots", "Ux", "Pins", "Thing", "WhatsApp Documents"** estão em inglês de propósito: são nomes de pastas reais do Android, não texto da interface.
- **A pasta "Favoritas"** é virtual (junta as favoritas de todas as pastas) e fica sempre em primeiro lugar na lista.
- **Dois desenhos do logo.** Dentro do app (splash e boas-vindas) vale a **marca** [folio-mark.svg](folio-mark.svg) sobre uma peça de vidro escura, para combinar com o resto da interface. O **ícone claro de lançador** [folio-icon.svg](folio-icon.svg) (gradiente azul-violeta) é só para a tela inicial do celular, e não deve aparecer nas telas. Se o Stitch desenhar outro logo, anexe [folio-mark-ref.png](folio-mark-ref.png) (a marca já sobre a peça de vidro) como imagem de referência e peça "use this exact logo tile".
- **Fotos de exemplo:** o protótipo gera paisagens estilizadas por código. No Stitch, peça imagens com essas mesmas paletas, sem pessoas.
- **Itens simulados no protótipo** (Compartilhar, Bloquear, Abrir com, Imprimir, Definir como) aparecem normalmente nos menus; o Stitch só desenha, não precisa de comportamento.
