---
title: UI Design System
parent: Frontend
nav_order: 6
---

# UI Design System

A practical spec for consistent, scalable, maintainable styles. Combines Tailwind theming, component-level conventions, design tokens, and governance.

**Key assumptions:**
- Single shared UI folder: `/components/ui`
- Tailwind + CSS variables for runtime theming
- Tokens as lightweight TypeScript (not JSON) for type safety and easy imports
- No Storybook, no heavy CI visual-regression pipeline

---

## 1) Folder structure

```
/components/ui          ← all shared components (primitives → composed)
  Box.tsx, Text.tsx, Button.tsx, Input.tsx, Card.tsx, Header.tsx, Layout.tsx
  index.ts
/styles
  globals.css           (Tailwind base + CSS variable definitions)
  themes.ts             (light/dark CSS var values exported as plain objects)
tailwind.config.js
/lib
  cva.ts                (tiny class-variance helper or classNames merge utility)
  theme.ts              (toggle-theme helper)
```

---

## 2) Design tokens (lightweight TypeScript)

Create `styles/tokens.ts`:

```ts
export const tokens = {
  color: {
    primary: '#0ea5e9',
    surface: '#ffffff',
    onSurface: '#111827',
  },
  radius: { sm: '4px', md: '8px' },
  spacing: { 1: '4px', 2: '8px' },
  fontSize: { sm: '0.875rem', md: '1rem' },
}
```

Single small TS object you can import in components or use to generate CSS variables. Easier than JSON and no build step.

---

## 3) Tailwind integration

Extend the Tailwind theme using only the scales you actually need. Reference CSS variables for runtime-themeable values:

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        surface: 'var(--color-surface)',
        'on-surface': 'var(--color-on-surface)',
      },
    },
  },
}
```

Use Tailwind JIT mode; purge unused classes in production.

---

## 4) Runtime theming

Define CSS variable placeholders in `globals.css`:

```css
:root {
  --color-primary: #0ea5e9;
  --color-surface: #fff;
  --color-on-surface: #111827;
  --radius-md: 8px;
}

.theme-dark {
  --color-primary: #38bdf8;
  --color-surface: #0b1220;
  --color-on-surface: #f8fafc;
}
```

Toggle `.theme-dark` on `<html>` or `<body>` from a small hook in `lib/theme.ts`. Persist preference in `localStorage` and respect `prefers-color-scheme` on first load.

---

## 5) Component conventions

- **Primitives**: `Box` (div wrapper with className merge), `Text` (p/span with semantic props).
- Components accept minimal, consistent props: `variant`, `size`, `className`.
- Use Tailwind classes composed with simple helpers; avoid inline styles except for dynamic CSS variable values when necessary.

Example Button API:

```tsx
<Button variant="primary" size="md" className="w-full">Save</Button>
```

Implementation maps variants to class strings:

```ts
const VARIANT: Record<string, string> = {
  primary: 'bg-primary text-white hover:opacity-90',
  ghost:   'bg-transparent border border-on-surface',
}
```

---

## 6) CSS variables vs hardcoded classes

- Prefer **Tailwind classes** for layout and spacing.
- Prefer **CSS variables** for colors you might toggle at runtime (theme changes). Tailwind colors can reference CSS vars: `bg-primary` maps to `var(--color-primary)`.
- Keep hardcoded hex values out of components — import from `tokens.ts` if needed.

---

## 7) Utilities

- `classNames` (or `clsx`) — merge class strings safely.
- Optional small CVA-like helper — map variants to class strings without an external dependency.

---

## 8) Accessibility and consistency

- Define shared focus and disabled utility classes in `globals.css`.
- All interactive components must include keyboard and `aria` props where relevant.
- Check color contrast for primary vs background values in tokens manually at least once; document the ratios.
