---
title: React Component Review Checklist
parent: Frontend
nav_order: 3
---

# React Component Review Checklist

Work top-to-bottom when reviewing any component. Flag anything that applies.

---

## Size and responsibility

- [ ] Is the component over ~300 lines? If so, is the extra length justified (large prop interface, unavoidable render branching) or should logic be extracted to a hook?
- [ ] Does the component do more than one thing? (e.g. owns Redux state AND renders a complex UI) — consider a `use<Name>()` hook for the logic.
- [ ] Are there render helper functions (`renderX`, `const renderX = () =>`) defined inside the component body? These break reconciliation — move them outside as proper sub-components.

## Props

- [ ] Does the component receive more than ~10 props? Could some be grouped into an object, replaced with context, or eliminated by moving logic closer to where it's used?
- [ ] Are any props passed through 3+ levels without being used at intermediate levels? This is prop drilling — consider a context.
- [ ] Are inline object or array literals passed as props (e.g. `style={{}}`, `options={[]}`, `config={{x: 1}}`)? These create new references every render. Extract to `useMemo` or a stable constant, especially if the child is or should be memoised.

## State

- [ ] Is any state derivable from props or other state? Derived state should be `useMemo`, not `useState`.
- [ ] Are multiple `useState` calls tracking related things? Consider a single `useReducer` or a consolidated object.
- [ ] Is state reset in a `useEffect` when a prop changes? This is almost always a bug — derive the value or use a `key` to remount.

## Effects

- [ ] Does every `useEffect` have a dependency array?
- [ ] Are all values used inside the effect listed in the dependency array? (ESLint `react-hooks/exhaustive-deps` catches this.)
- [ ] Does any `useEffect` fire async work without cleanup? Use `AbortController` for fetch calls or an `isActive` flag at minimum. See [react-performance.md](./react-performance.md).
- [ ] Does any `useEffect` set state unconditionally in a way that could loop (e.g. setState → re-render → effect fires again)?
- [ ] Is there a `useEffect` with an empty `[]` dep array that does more than one-time initialisation? If it reads props or state, it likely has missing deps.

## Performance

- [ ] Is the component wrapped in `React.memo`? Should it be? (See [react-performance.md](./react-performance.md) for criteria.)
- [ ] Are callbacks passed to memoised children stable? If not, `useCallback` is needed for memo to be effective.
- [ ] Is `useMemo` used for genuinely expensive computations, or for cheap operations where memo overhead exceeds computation cost?
- [ ] Are there lists with more than ~50 items rendered without virtualisation?

## Deprecated patterns

- [ ] `Component.defaultProps` — use destructuring defaults in the function signature instead.
- [ ] `key={index}` on list items that can be reordered or filtered — use a stable identifier from the data.
- [ ] Class components (`extends React.Component`) — should be function components.

## Correctness

- [ ] Do any event handlers reference stale closure values? (Common in `useEffect` with missing deps, or in `setTimeout`/`setInterval`.)
- [ ] Is `ref.current` read inside render (outside effects/handlers)? Refs are mutable and reading them in render is not safe for concurrent mode.
- [ ] Are there conditional hook calls? (Hooks cannot be called inside conditions, loops, or early returns.)
- [ ] Is state mutated directly instead of via the setter? (`array.push()`, `object.key = value` without spreading.)

## Accessibility

- [ ] Do interactive elements that aren't `<button>` or `<a>` have `role`, `tabIndex`, and keyboard handlers?
- [ ] Do images and icon buttons have `aria-label` or `alt` text?
- [ ] Are form inputs associated with labels (`htmlFor` / `aria-labelledby`)?

---

## Quick red flags (grep these before reviewing)

```bash
# Render functions inside components
grep -n "const render[A-Z]\|function render[A-Z]" src/**/*.tsx

# defaultProps (deprecated)
grep -rn "defaultProps" src/

# Index keys
grep -rn "key={index}" src/

# Inline object props (high false-positive rate — use judgment)
grep -rn "style={{" src/

# Missing cleanup in async effects
grep -n -A5 "useEffect" file.tsx | grep -v "AbortController\|isActive"
```
