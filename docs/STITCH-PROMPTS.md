# Folio — Prompts Stitch

Prompts em inglês para o Google Stitch, escritos para reproduzir o protótipo [folio.html](folio.html) o mais fiel possível: mesmas cores, fonte, medidas, textos e estados. Todos os textos da interface ficam em português do Brasil, exatamente como no protótipo.

**Como usar:** cole primeiro o **Design System** em um projeto novo do Stitch, depois gere uma tela por vez. Cada prompt de tela repete as medidas essenciais para funcionar isolado. Gere em **mobile**, tema **escuro**.

**Telas do protótipo (7) e camadas (5):**

| # | Tela | Camadas que abrem nela |
|---|---|---|
| 0 | Splash | — |
| 1 | Boas-vindas | — |
| 2 | Leitura | — |
| 3 | Pastas | Campo de busca |
| 4 | Dentro da pasta | Modo de seleção, menu da pasta, diálogo de excluir |
| 5 | Visualizador | Menu "Mais", informações, copiar/mover, renomear, slideshow |
| 6 | Editor | 5 abas de ferramentas, diálogo de descartar |

---

## Design System (colar primeiro)

```
Create a mobile design system for "Folio", a photo gallery app that reads the images on the phone and groups them by folder. It has a viewer and a built-in image editor. Dark UI only. Portrait 390x844. All UI text in Brazilian Portuguese.

LOOK & FEEL: dark, calm, premium, content-first. Photos are the color; the UI is neutral charcoal with ONE mint/teal accent. Generous 24px side padding on list screens, soft rounded shapes everywhere (pills and 24-28px cards), thin 1px hairline borders instead of shadows. No gradients, no glow, no drop shadows on cards.

COLORS (use exactly)
- Background: #0F1115. Viewer/editor stage (behind the photo): #0A0A0B. Page outside the phone: #050608.
- Surface (cards, chips, inputs): #1A1D24. Raised surface (menus, sheets, dialogs): #23262D.
- Hairline / border: #2A2F3A. Row divider: #262A33. Bar top border: #1E2128.
- Text: #F2F4F7. Muted text: #A9B0BC. Secondary chip text: #D5D9E0.
- Accent (mint): #5EEAD4. Text/icon ON accent: #04211D.
- Danger: #FF9A94 for destructive text and icons; destructive button background #FF9A94 with text #3A0A07.

TYPOGRAPHY: Plus Jakarta Sans only. Screen titles 30-31px extra-bold (800), letter-spacing -0.03em. Top-bar titles 20px bold (700). Big numbers 64px extra-bold, tabular numerals. Body 15-16px; folder/file names 16px bold; counts and captions 13-14px muted. Buttons 17px bold. Dialog and sheet titles 22px extra-bold.

SHAPES
- Primary button: full width, 56px tall, fully rounded (28px), solid mint #5EEAD4, dark text #04211D, 17px bold. Ghost button: transparent, 48px tall, muted text, 15px semibold.
- Chips: 44px tall, 16px horizontal padding, fully rounded, 1px border #2A2F3A, fill #1A1D24, text #D5D9E0, 14px semibold. Selected chip: fill #5EEAD4, border #5EEAD4, text #04211D.
- Icon buttons: 44x44 circles, transparent; pressed state fills #1A1D24.
- Folder cover: square, 24px radius, 2x2 collage of photos with 3px gaps.
- Photo tile: square, 10px radius, 6px gaps in a 3-column grid.
- Menus: 236px wide, #23262D, 24px radius, 8px padding, 52px tall rows with a 22px icon, 16px gap and 16px semibold label.
- Bottom sheet: #23262D, 28px top radius, 28/24px padding. Dialog: #23262D, 28px radius, 24px padding, 24px side margin, actions right-aligned as 48px pills (neutral #2A2F3A, primary mint, danger #FF9A94).
- Toast: pill, fill #F2F4F7, text #0F1115, 14px semibold, centered above the bottom bar.

ICONS: outline, 1.8px stroke, round caps and joins, 24px (22px in menus and editor tabs). Set used: back arrow, forward arrow, search, plus, three vertical dots, heart, info (circle with i), share (three connected nodes), lock, trash, magic wand (editor entry), pencil, play, copy, folder, folder with arrow (move), open-with (arrow out of tray), printer, phone, check, close (X), crop, filters (three overlapping circles), adjust (two sliders), brush, text (T), rotate left/right, flip, undo, loading ring.

PHOTO CONTENT: the sample photos are stylized landscapes and abstract scenes in rich gradients: sunset skies (peach to coral), deep blue dusk with a pale moon, golden hour with terracotta hills, soft aqua-pink pastel sky, dark teal night, violet-magenta sky, and teal-to-blue sky; with layered rolling hills, a city skyline with lit windows, or overlapping translucent circles and a thin arc. Mixed aspect ratios (4:3, 3:4, 16:9, 1:1, 4:5, 3:2).

TONE: quiet and confident, never playful; the interface steps back and lets the photos lead.
```

---

## 0. Splash

```
Design the SPLASH screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), following the Folio design system: background #0F1115, text #F2F4F7, muted #A9B0BC, single accent mint #5EEAD4 (dark text on accent #04211D), font Plus Jakarta Sans. This is the first thing the user sees; it disappears by itself after about 2 seconds, or on tap, and goes to the welcome screen. No buttons, no navigation, no status text.

Layout: everything centered both horizontally and vertically on a flat #0F1115 background, with 24px side padding and no gradients, glow or shadows.
1. App logo: a 92px rounded square (30px radius), solid mint #5EEAD4, with a 46px dark #04211D outline folder icon centered inside (1.8px stroke, round caps and joins; a folder with a small tab on the top left).
2. 20px below: the wordmark "Folio" at 38px extra-bold (800), letter-spacing -0.04em, color #F2F4F7.
3. 12px below: tagline "Sua galeria, organizada" in 15px regular muted #A9B0BC.
4. At the bottom, 56px above the screen edge, centered: three small 8px dots with 8px gaps, #2A2F3A, the middle one in mint #5EEAD4 (a quiet loading indicator).

Motion notes (for the description only): logo scales in from 70% with a soft ease; the wordmark and tagline fade up 10px one after the other; the three dots blink to mint in sequence. Respect reduced motion by showing it static.
```

---

## 1. Boas-vindas

```
Design the WELCOME screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), following the Folio design system: background #0F1115, surface #1A1D24, border #2A2F3A, text #F2F4F7, muted #A9B0BC, single accent mint #5EEAD4 (text on accent #04211D), font Plus Jakarta Sans.

Layout, top to bottom, with 24px side padding and 28px top padding:
1. Brand row: a 36px rounded-square logo (12px radius, solid mint) with a dark folder icon inside, then the word "Folio" 20px extra-bold, letter-spacing -0.02em.
2. Hero, centered in the free space: a card 300px wide (#1A1D24, 1px border #2A2F3A, 28px radius, 16px padding). Its header row has a small mint folder icon, the bold name "WhatsApp" and the muted count "1.335" on the right. Under it a 3-column mosaic of 6 square photos (12px radius, 6px gaps) with the stylized landscape gradients described in the design system. Overlapping the card's bottom-right corner (offset about -10px right and -16px down) a mint pill badge, dark text, 13px bold: "8 pastas encontradas".
3. Heading "Suas fotos, separadas por pasta" at 31px, extra-bold, line-height 1.1, balanced wrapping, letter-spacing -0.03em.
4. Lead text, 16px muted, line-height 1.5: "O Folio lê as imagens do seu celular e mostra cada pasta em um só lugar."
5. Checklist of 3 rows, each with a mint check icon (20px) and 15px text #D5D9E0, 10px gap: "Encontra todas as pastas com imagens", "Mostra quantas imagens há em cada uma", "Não apaga nem move nada sem você pedir".
6. Primary mint button, full width, 56px, fully rounded: "Permitir acesso às fotos".
7. Ghost button below, 48px, muted text: "Agora não".

No bottom navigation on this screen.
```

---

## 2. Leitura

```
Design the SCANNING screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system: background #0F1115, surface #1A1D24, border #2A2F3A, accent mint #5EEAD4, Plus Jakarta Sans. 24px side and 28px top padding. Show the screen mid-scan.

Top to bottom:
1. Small mint eyebrow, 14px bold: "Lendo seu celular".
2. Huge number, 64px extra-bold, tabular numerals, letter-spacing -0.04em, 8px below: "1.698".
3. Muted 16px line: "imagens encontradas em 5 pastas".
4. Progress bar, 20px below: 8px tall, fully rounded, track #262A33, fill mint at about 43%. Under it a muted 13px caption: "43% concluído".
5. A tall rounded card (24px radius, #1A1D24, 1px border #2A2F3A, 4px/16px padding, 20px vertical margin) listing the folders as they are read, newest at the bottom. Each row is at least 50px tall, 12px gap, 1px divider #262A33: a 22px mint check icon, the folder name 16px semibold, and the count on the right in muted 15px tabular numerals. Completed rows, in order: WhatsApp 1.335, Screenshots 187, Ux 91, Pins 64. The current row (Downloads) shows a spinning ring icon (a faint circle with a mint quarter arc), the name, and a mint count with ellipsis: "21…".
6. Primary button, full width, disabled state (55% opacity): "Lendo…".

Also provide the completed variant: number "10.917", "imagens encontradas em 8 pastas", bar at 100%, "100% concluído", all 8 rows with check icons (WhatsApp 1.335, Screenshots 187, Ux 91, Pins 64, Downloads 38, Thing 12, WhatsApp Documents 2, Camera 9.188), and the button enabled in mint: "Ver pastas encontradas".
```

---

## 3. Pastas

```
Design the FOLDERS screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system: background #0F1115, surface #1A1D24, border #2A2F3A, text #F2F4F7, muted #A9B0BC, accent mint #5EEAD4, Plus Jakarta Sans.

Top to bottom:
1. Top bar, 64px: title "Pastas" at 30px extra-bold (letter-spacing -0.03em, 16px left padding), and on the right two 44px circular icon buttons: search and plus.
2. Muted 15px line under the title, 24px side padding: "10.917 imagens · 8 pastas".
3. Sort chips in a horizontal row (24px side padding, 14px top): "Mais imagens" (selected: mint fill, dark text), "A–Z", "Recentes". Chips 44px tall, fully rounded, border #2A2F3A, fill #1A1D24.
4. Two-column grid of folder cards (24px side padding, 16px column gap, 20px row gap). Each card: a square cover with 24px radius showing a 2x2 collage of four photos separated by 3px gaps; below it the folder name 16px bold (single line, ellipsis) and the count in muted 14px, "N imagens". Folders in this order: Camera 9.188 imagens, WhatsApp 1.335 imagens, Screenshots 187 imagens, Ux 91 imagens, Pins 64 imagens, Downloads 38 imagens, Thing 12 imagens, WhatsApp Documents 2 imagens. Use the stylized landscape gradients for the photos (sunsets, dusk skyline, teal night, pastel aqua-pink, violet-magenta).
5. At the bottom of the scroll, muted 13px helper text: "Toque em + para testar o editor com fotos do seu aparelho. Elas aparecem na pasta Importadas."

No bottom navigation.

Also design the SEARCH state as a second frame: the search icon button toggled, and under the top bar a 48px fully rounded input (#1A1D24, 1px border #2A2F3A, 18px padding, 16px text) with placeholder "Buscar pasta"; the grid filtered to folders matching "what" showing only WhatsApp and WhatsApp Documents. Empty state variant: centered muted text "Nenhuma pasta encontrada."
```

---

## 4. Dentro da pasta

```
Design the FOLDER CONTENTS screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system. Show THREE frames.

FRAME A — normal:
- Top bar 64px: 44px circular back arrow button; a two-line title: folder name "WhatsApp" 20px bold with "1.335 imagens" under it in 13px muted; on the right a 44px circular three-dots button.
- Photo grid: 3 columns, square tiles with 10px radius, 6px gaps, 8px side padding. 18 stylized landscape/abstract photos with varied palettes. Three tiles show a small mint filled heart at the bottom-right corner (favorites) with a subtle dark shadow for legibility.

FRAME B — menu open: same screen with a transparent scrim and a 236px menu (#23262D, 24px radius, 8px padding) anchored at the top-right under the three-dots button, with two rows (52px tall, 22px icon, 16px label): check icon "Selecionar" and back-arrow icon "Mais antigas primeiro".

FRAME C — selection mode:
- Top bar: 44px close (X) button and the title "3 selecionadas" (20px bold).
- Grid as before; each tile shows a 24px circle at the top-left: unselected = 2px white border with 35% black fill; selected = solid mint fill with a dark check. Selected tiles have their photo dimmed to 60% opacity. Show 3 selected tiles and 2 favorites.
- Bottom action bar, 72px tall, 1px top border #1E2128, two equal columns, each an icon above a 12px label: heart "Favoritar" and trash "Excluir" in danger color #FF9A94.
- Optionally overlay the confirmation dialog: scrim rgba(0,0,0,.62); centered dialog (#23262D, 28px radius, 24px padding, 24px side margins) with title "Excluir 3 imagens?" (22px extra-bold), muted text "Elas serão removidas da pasta WhatsApp.", and right-aligned pills "Cancelar" (neutral #2A2F3A) and "Excluir" (#FF9A94 background, text #3A0A07).

Empty state variant: centered muted text "Esta pasta está vazia."
```

---

## 5. Visualizador

```
Design the PHOTO VIEWER screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system. Stage background is near-black #0A0A0B. Show FOUR frames.

FRAME A — viewer:
- Top bar 64px: 44px circular back arrow; two-line title: "Hoje 14:32" in 20px bold and "3 de 48" under it in 13px muted; then two 44px circular icon buttons: heart (outlined, or filled mint when favorited) and info.
- Stage: one large photo (a 16:9 stylized sunset landscape, peach-to-coral sky, pale sun, layered purple hills) contained and centered, never cropped. At the vertical middle, two 44px circular buttons overlay the edges (left 8px, right 8px) with 60% dark fill #0F1115 and white arrows (back and forward).
- Action bar, 80px tall, 1px top border #1E2128, five equal columns, each an icon over a 12px medium label: share "Compartilhar", lock "Bloquear", trash "Excluir" (danger #FF9A94), magic wand "Editar", three-dots "Mais".

FRAME B — "Mais" menu: scrim transparent, a 236px menu (#23262D, 24px radius) anchored bottom-right above the action bar (16px from the right, 92px from the bottom) with 7 rows: pencil "Renomear", play "Slideshow", copy "Copiar para", folder-arrow "Mover para", open-with "Abrir com", printer "Imprimir", phone "Definir como".

FRAME C — "Informações" bottom sheet over a dimmed viewer (scrim rgba(0,0,0,.62)): sheet #23262D, 28px top radius, padding 28/24, title "Informações" 22px extra-bold, then 6 rows, label bold 15px in a 104px column and muted value: "Nome" IMG_4821.jpg; "Caminho" /storage/emulated/0/Pictures/WhatsApp; "Tamanho" 412,5 KB; "Resolução" 1200 × 675 (0,8 MP); "Última modificação" 04/11/2026 14:32; "Data de criação" 18/03/2025 09:14. A full-width mint button "OK" closes it.

FRAME D — slideshow running: same as frame A but a mint pill button centered 12px from the top of the stage, 44px tall, dark bold text 14px: "Parar slideshow".
```

---

## 5b. Visualizador — copiar, mover e renomear

```
Design two overlays for the photo viewer of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system, over the dimmed viewer (scrim rgba(0,0,0,.62)).

FRAME A — "Mover para" bottom sheet: #23262D, 28px top radius, padding 28/24, title "Mover para" 22px extra-bold. List of folder rows, each at least 56px tall with a 1px divider #2A2F3A: a 24px folder icon, the folder name 16px semibold, and on the right the count in muted 13px: Camera 9.188, Screenshots 187, Ux 91, Pins 64, Downloads 38, Thing 12, WhatsApp Documents 2 (the current folder, WhatsApp, is not listed). (The "Copiar para" variant is identical with the title "Copiar para".)

FRAME B — "Renomear" dialog: centered, #23262D, 28px radius, 24px padding, 24px side margins. Title "Renomear" 22px extra-bold; a 48px fully rounded text input (#1A1D24, 1px border #2A2F3A, text 16px) holding "IMG_4821.jpg" with a mint focus ring; right-aligned pills "Cancelar" (neutral) and "OK" (mint, dark text).

Add a toast at the bottom of a third small frame: pill #F2F4F7, dark text 14px semibold: "Movida para WhatsApp".
```

---

## 6. Editor

```
Design the IMAGE EDITOR screen of "Folio" (mobile 390x844, dark, Brazilian Portuguese), same design system. Layout from top to bottom: top bar (64px), image stage (flexible), tool panel (168px tall, 1px top border #1E2128, 16px side padding, 12px top padding), tab bar (72px tall, 1px top border #1E2128, five equal tabs). Show FIVE frames, one per tool, all editing the same photo (a stylized dusk skyline with lit windows, deep blue sky, pale moon).

Common top bar: 44px circular close (X) button; title "Editar" 20px bold; a 44px outlined chip "Restaurar"; and a mint pill "Salvar" (44px tall, 20px padding, dark bold 15px).
Common stage: near-black #0A0A0B, the photo centered with a 6px radius, 12px side padding.
Common tab bar: icon (22px) over a 12px semibold label; selected tab in mint, others muted #A9B0BC: crop "Cortar", filters "Filtros", adjust "Ajustes", brush "Desenhar", text "Texto".

FRAME 1 — "Cortar" selected: panel row 1 of chips (44px): "Original" (selected, mint), "1:1", "4:5", "3:4", "16:9", "9:16". Row 2 of chips with icons: rotate-left "Esquerda", rotate-right "Direita", flip "Espelhar". Under them a 12px muted note: "O corte é centralizado na imagem." The photo preview is cropped to 4:5 in a variant.

FRAME 2 — "Filtros" selected: a horizontally scrolling row of filter thumbnails, each 76px square with a 14px radius, 2px transparent border (mint border when selected), label under it 12px semibold (mint when selected, muted otherwise): Original (selected), Vívido, Quente, Frio, P&B, Sépia, Fade, Noir. Each thumbnail shows the same photo with its own look (vivid saturated, warm sepia tint, cool bluish, black-and-white, sepia, faded low-contrast, high-contrast noir). The stage photo shows the selected filter.

FRAME 3 — "Ajustes" selected: row of chips "Brilho" (selected), "Contraste", "Saturação", "Calor", "Desfoque". Below it a slider row (44px): a track with mint thumb and fill, value output on the right in white tabular numerals, "35".

FRAME 4 — "Desenhar" selected: a row of 7 color swatches (28px circles with a 2px #3A404C border, 44px touch targets): white #FFFFFF (selected, with a white outline ring and 2px offset), #111111, #FF5A5F, #FFC145, #5EEAD4, #4C8DFF, #C86BFA, followed by an undo icon button. Below: a slider row labeled "Espessura" (muted 14px) with a mint slider. The stage photo shows two hand-drawn rounded strokes (one coral, one white) over the skyline.

FRAME 5 — "Texto" selected: a row with a 44px rounded input (placeholder "Digite o texto", value "Boa noite") and a mint chip "Adicionar"; a swatch row like in Desenhar ending with a red-tinted trash icon button (danger #FF9A94); a slider row "Tamanho". The stage photo shows the text "Boa noite" centered in extra-bold white with a soft shadow and a dashed mint selection rectangle around it.

Also design the DISCARD dialog over the dimmed editor: title "Descartar alterações?", muted text "As edições feitas nesta imagem serão perdidas.", pills "Cancelar" (neutral) and "Descartar" (danger #FF9A94, dark text).
```

---

## Notas de fidelidade

- **Sem navegação inferior.** O Folio não tem tab bar global; a navegação é por pilha (voltar) e pelas barras de ação de cada tela. Não deixe o Stitch adicionar uma.
- **Um só acento.** Mint `#5EEAD4` em tudo que é ação, seleção ou estado ativo. Vermelho `#FF9A94` só para excluir e descartar. Sem degradês.
- **Os rótulos "Camera", "Screenshots", "Ux", "Pins", "Thing", "WhatsApp Documents"** estão em inglês de propósito: são nomes de pastas reais do Android, não texto da interface.
- **Fotos de exemplo:** o protótipo gera paisagens estilizadas por código. No Stitch, peça imagens com essas mesmas paletas, sem pessoas.
- **Itens simulados no protótipo** (Compartilhar, Bloquear, Abrir com, Imprimir, Definir como) aparecem normalmente nos menus; o Stitch só desenha, não precisa de comportamento.
