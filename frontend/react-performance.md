---
title: React Performance
parent: Frontend
nav_order: 2
---

# React Performance

Read before adding `React.memo`, `useMemo`, or `useCallback`.

---

## When to use React.memo

`React.memo` prevents a component from re-rendering when its props haven't changed (shallow comparison). It only helps if:

1. The component renders often due to a parent re-rendering
2. The render is non-trivial (sizeable JSX tree, computations, DOM nodes)
3. The props are actually stable between renders (see the inline-object trap below)

**Good candidates:**
- Components that receive many props from a large Redux-connected parent
- Canvas or SVG rendering components where repaints are expensive
- List row components rendered inside `.map()` with stable row data

**Poor candidates:**
- Tiny presentational components (a badge, an icon) — memo overhead exceeds render cost
- Components whose props change on virtually every parent render — memo adds cost with no benefit

**The inline-object trap:**
```tsx
// memo does nothing — new object reference every render
<MemoizedChild config={{ color: "red" }} />

// works — stable reference
const config = useMemo(() => ({ color: "red" }), []);
<MemoizedChild config={config} />
```

---

## When to use useCallback

`useCallback` memoises a function reference. It only matters when passing callbacks to:
- A `React.memo`-wrapped child (otherwise the child re-renders anyway)
- A `useEffect` dependency array (to avoid infinite loops)

Don't wrap every handler. Calling `useCallback` on a handler used only in inline JSX of a non-memoised component adds overhead with no benefit.

```tsx
// Unnecessary — parent re-renders anyway, child isn't memoised
const handleClick = useCallback(() => doThing(), [doThing]);

// Useful — child is memoised and would re-render on new function reference
const handleChange = useCallback((value: string) => {
  dispatch(updateField(value));
}, [dispatch]);

<MemoizedInput onChange={handleChange} />
```

---

## When to use useMemo

`useMemo` is for **expensive computations** or **stable object/array references**.

Use it when:
- The computation takes meaningfully long (sorting/filtering large arrays, building display models)
- The result is passed to a memoised child and needs a stable reference

Do not use it for:
- Simple property access or arithmetic
- Strings or primitives (compared by value already)
- JSX — memoising JSX subtrees defeats React's reconciliation

**Cost of useMemo itself:** Each call adds a comparison on every render. For a component with many `useMemo` calls, audit whether each computation is genuinely expensive or whether the memoisation overhead matches the computation cost.

---

## The render-function-inside-component anti-pattern

```tsx
// BAD — React cannot reconcile this; the subtree unmounts/remounts every render
function Parent() {
  const renderContent = () => <HeavyChild data={data} />;
  return <div>{renderContent()}</div>;
}

// GOOD — define outside or use a proper component
function Content({ data }: { data: Data }) {
  return <HeavyChild data={data} />;
}

function Parent() {
  return <div><Content data={data} /></div>;
}
```

This pattern breaks React's reconciliation because the function identity changes every render, so React cannot match the returned element to a previously-rendered subtree. It forces a full unmount/remount of everything the render function returns.

---

## Virtualisation

Use a virtualised list when rendering more than ~50 rows of variable or fixed height. The two main libraries:

- **`react-window`** — simpler API, fixed or variable size, lower bundle cost
- **`@tanstack/react-virtual`** — more flexible, headless (bring your own markup), better for complex layouts

Common candidates: long data tables, message history, search result lists.

---

## Async effects and cleanup

The `let isActive = true` pattern prevents stale state updates but does not cancel in-flight requests. For fetch-based effects, prefer `AbortController` so the network request itself is cancelled on unmount:

```tsx
useEffect(() => {
  const controller = new AbortController();

  async function load() {
    try {
      const response = await fetch(url, { signal: controller.signal });
      const data = await response.json();
      setState(data);
    } catch (error) {
      if (error instanceof Error && error.name === "AbortError") return;
      console.error(error);
    }
  }

  load();
  return () => controller.abort();
}, [url]);
```
