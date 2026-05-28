---
title: State Management
parent: Frontend
nav_order: 5
---

# Context vs Redux — When to Use Each

The rule is simple:

- **Context** for non-serialisable values and state that stays inside one component subtree.
- **Redux** for serialisable application state that needs to survive unmounts, be read across the tree, or be synced with the server.

---

## Use Context when…

### The value cannot go in Redux

Redux state must be serialisable (plain objects, arrays, primitives). Anything that isn't belongs in Context.

| Common example | What it holds | Why not Redux |
|---|---|---|
| Canvas/stage context | `React.MutableRefObject<CanvasInstance>` | Class instance with DOM references |
| Event emitter context | `EventEmitter` | Not serialisable |
| Drag-and-drop context | dnd-kit state, overlay rect | DOM geometry, library internal state |

### The value is derived / computed, not primary state

If a context computes display values (pixel sizes, offsets, formatted strings) from a Redux source of truth, the source lives in Redux and the context is a cache of derived geometry. Putting it in Redux would mean storing both the raw config and its computed form, creating a sync problem.

### The state never leaves its subtree

Filter or selection state that is entirely local to one panel or interaction zone adds noise to the Redux store for no benefit. Use Context (or local `useState`) instead.

---

## Use Redux when…

### The state is persisted or synced with the server

Any state that gets written to a database or synced in real-time belongs in Redux so a persistence layer can read a snapshot and write it.

### The state needs to survive component unmount

If a panel closes and reopens, its state should be where it was. Redux state persists across the React component lifecycle; context state is destroyed when the provider unmounts.

### Distant components need to read the same value

If a sidebar component and a canvas component both need the same value, threading it through context providers or prop chains to both locations is impractical. Use Redux.

### The state has a loading or error condition tied to a network call

Redux Toolkit's `createAsyncThunk` handles `pending`/`fulfilled`/`rejected` transitions cleanly. Use it for any state that comes from a fetch, not `useState` inside a context provider.

---

## Categorising existing state

When auditing a Redux store, apply this taxonomy:

| Category | Description | Example |
|---|---|---|
| **Server state** | Source of truth is the server; slice mirrors it | User data, items fetched from API |
| **UI state** | Purely client-side; never persisted | Tool selection, viewport zoom, modal open/closed |
| **Mixed** | Some fields are server-fetched, some are local | Session + connection status |

Only truly shared, serialisable UI state belongs in Redux. Transient per-component UI state belongs in `useState` or Context.

---

## Decision checklist

When adding new state, work through these questions:

1. **Is the value serialisable?** — If no (ref, class instance, function, emitter), use Context.
2. **Does anything outside the current component subtree need it?** — If yes, use Redux.
3. **Does it need to persist when the component unmounts?** — If yes, use Redux.
4. **Is it written to or read from the server?** — If yes, use Redux.
5. **Is it derived from Redux state?** — If yes, compute it in a selector or a hook; don't duplicate it in Redux or Context.
6. **Is it transient interaction state scoped to one area?** — If yes, Context (or local `useState`) is fine.

If you are still unsure after these questions, prefer Redux. It is easier to move state out of Redux into a context later than to discover that context state needs to be read somewhere it can't reach.
