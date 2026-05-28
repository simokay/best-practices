---
title: React Testing
parent: Frontend
nav_order: 4
---

# Writing Good React Component Tests

Grounded in the [Testing Library guiding principles](https://testing-library.com/docs/guiding-principles) and Kent C. Dodds' [testing philosophy](https://kentcdodds.com/blog/write-tests).

---

## The Guiding Principle

> "The more your tests resemble the way your software is used, the more confidence they can give you."
>
> — Testing Library documentation

Tests exist to give you confidence that your software works. That confidence is only real if tests break when real users would be affected, and survive refactors that don't change behaviour.

---

## What to Test

Test the things a user or developer cares about:

- Can users interact with the rendered elements? (buttons are clickable, form fields accept input)
- Does the component respond correctly to user actions? (click, type, submit)
- Does the component respond correctly to different props? (loading state, empty state, error state)
- Do critical user workflows succeed end-to-end?

Do **not** test:

- Internal state variables or component instance methods
- Which child components are rendered (test the output, not the composition)
- CSS class names or inline styles (use visual regression tools if needed)
- Implementation details that a user would never observe

The test should break when the user experience breaks — not when you rename a variable.

---

## Test Types and Where to Focus

Adopt the **Testing Trophy** model (not the classic pyramid):

```
        /‾‾‾‾‾‾‾‾\
       /  E2E (few) \
      /‾‾‾‾‾‾‾‾‾‾‾‾‾\
     / Integration    \      ← Most tests live here
    /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
   /   Unit (some)      \
  /‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
 /  Static: TS + Lint      \  ← Free coverage
```

**Integration tests** (rendering a component tree with real children, mocked APIs) give the best return. They survive refactors, exercise the actual interaction between pieces, and still run fast in jsdom.

---

## Query Priority

Use queries in this order. The higher on the list, the more it tests what real users see:

| Priority | Query | When to use |
|----------|-------|-------------|
| 1 | `getByRole` | Almost everything — buttons, inputs, headings, lists |
| 2 | `getByLabelText` | Form fields with `<label>` or `aria-label` |
| 3 | `getByPlaceholderText` | Only when no label exists |
| 4 | `getByText` | Non-interactive elements (paragraphs, headings, cells) |
| 5 | `getByDisplayValue` | Currently-filled form fields |
| 6 | `getByAltText` | Images |
| 7 | `getByTitle` | Avoid — title attributes are poorly supported by screen readers |
| 8 | `getByTestId` | **Last resort only.** Dynamic text, non-semantic fallback |

If you need `getByTestId` to find something, consider whether the component is accessible in the first place.

```tsx
// ✗ Fragile — breaks if the label text changes in a non-user-visible way
screen.getByTestId("submit-btn")

// ✗ Couples to CSS — breaks on any styling refactor
container.querySelector(".btn-primary")

// ✓ What a user (or screen reader) sees: "a button labelled Save"
screen.getByRole("button", { name: /save/i })
```

---

## `userEvent` vs `fireEvent`

Prefer `userEvent` for interactions. It simulates the full sequence of events a real browser fires (focus, keydown, input, keyup, blur…), not just a single synthetic event.

```ts
// ✗ fireEvent dispatches a single raw DOM event
fireEvent.click(screen.getByRole("button", { name: /submit/i }))

// ✓ userEvent replicates what a real user typing actually triggers
const user = userEvent.setup()
await user.type(screen.getByLabelText("Name"), "My Value")
await user.click(screen.getByRole("button", { name: /create/i }))
```

Use the `setup()` factory before rendering so the instance shares pointer state across interactions in one test.

`fireEvent` is fine for events that `userEvent` doesn't yet model, or simple cases where you just need to verify a callback was called.

---

## Async Testing

When something appears asynchronously, use `find*` queries — they return a Promise and retry until the element appears or the timeout expires:

```tsx
// ✗ Will fail intermittently — element might not exist yet
expect(screen.getByText("Saved")).toBeInTheDocument()

// ✓ Waits for the element to appear
expect(await screen.findByText("Saved")).toBeInTheDocument()
```

Use `waitFor` when you need to wait for an assertion that doesn't involve finding an element:

```tsx
await waitFor(() => {
  expect(onSave).toHaveBeenCalledWith(expect.objectContaining({ name: "Hazel" }))
})
```

Do not use `waitFor` to just wait a tick — use it to wait for a specific condition.

---

## Mocking

### What to mock

Mock at the boundary of your system — the things you don't own or can't control in tests:

- **Network requests** — use `vi.stubGlobal("fetch", ...)` or Mock Service Worker
- **External libraries with side-effects** — routing hooks, modal setup
- **Browser APIs** — `window.confirm`, `window.matchMedia`
- **Random/time** — `vi.useFakeTimers()`, `vi.spyOn(Math, "random")`

### What not to mock

- Your own child components (render them; test the output)
- Redux state (use a `makeStore` with preloaded state instead)
- Pure utility functions (test them directly)

### Mocking fetch

```ts
const fetchMock = vi
  .fn()
  .mockResolvedValueOnce({ ok: true, json: async () => ({ items: [] }) })
  .mockResolvedValueOnce({ ok: true, json: async () => ({ id: 42, name: "My Item" }) })
vi.stubGlobal("fetch", fetchMock)
```

For larger surfaces, consider [Mock Service Worker (MSW)](https://mswjs.io/) — it intercepts at the network level, works in both Node and browser, and lets you reuse handler definitions across unit, integration, and E2E tests.

### Mocking modules

```ts
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn() }),
}))
```

Always put `vi.mock(...)` calls at the top of the file. Vitest hoists them before imports.

---

## Redux: use preloaded state, not mocked selectors

Render with a real store seeded with the state you need. Mocking individual selectors couples tests to implementation.

```tsx
// ✗ Mocking internals — breaks if the selector is renamed
vi.mock("../../slices/itemSlice", () => ({ selectItem: vi.fn(() => mockItem) }))

// ✓ Seeding the store — works regardless of how selectors are structured
renderWithProviders(<MyComponent />, {
  preloadedState: { items: { id: 1, name: "Example", role: "admin" } },
})
```

Your project's `renderWithProviders` helper should wrap the component in a `<Provider>` and return the store alongside all Testing Library queries.

---

## Structuring a Test File

```tsx
import { afterEach, beforeAll, describe, expect, it, vi } from "vitest"
import { cleanup, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"

import { renderWithProviders } from "../../helpers/test-utils"
import MyComponent from "./MyComponent"

beforeAll(() => {
  // one-time setup: browser API stubs, modal app element, etc.
})

afterEach(() => {
  cleanup()
  vi.restoreAllMocks()
})

function renderComponent(props = {}) {
  const user = userEvent.setup()
  const onSave = vi.fn()

  const result = renderWithProviders(
    <MyComponent onSave={onSave} {...props} />,
    { preloadedState: { items: { id: 1, role: "admin" } } },
  )

  return { user, onSave, ...result }
}

describe("MyComponent", () => {
  it("calls onSave with the entered name", async () => {
    const { user, onSave } = renderComponent()

    await user.type(screen.getByLabelText("Name"), "Hazel")
    await user.click(screen.getByRole("button", { name: /save/i }))

    expect(onSave).toHaveBeenCalledWith(expect.objectContaining({ name: "Hazel" }))
  })

  it("disables the save button while loading", () => {
    renderComponent({ isLoading: true })
    expect(screen.getByRole("button", { name: /save/i })).toBeDisabled()
  })

  it("shows an error message when save fails", async () => {
    const { user, onSave } = renderComponent()
    onSave.mockRejectedValue(new Error("Network error"))

    await user.click(screen.getByRole("button", { name: /save/i }))

    expect(await screen.findByRole("alert")).toHaveTextContent("Network error")
  })
})
```

---

## Assertion Matchers

Use `@testing-library/jest-dom` matchers — they produce far clearer failure messages:

```ts
// ✗ Generic — failure says "expected false to be true"
expect(button.disabled).toBe(true)

// ✓ Semantic — failure says "expected element to be disabled"
expect(button).toBeDisabled()
```

Key matchers:

| Matcher | Use for |
|---------|---------|
| `toBeInTheDocument()` | Element exists in the DOM |
| `toBeVisible()` | Element is visible (not `display:none`, not `hidden`) |
| `toBeDisabled()` / `toBeEnabled()` | Form controls |
| `toHaveTextContent(text)` | Element contains text |
| `toHaveValue(val)` | Input has a specific value |
| `toHaveFocus()` | Element is focused |
| `toHaveAttribute(attr, val)` | Element has an HTML attribute |
| `toBeChecked()` | Checkbox or radio is checked |

---

## `query*` vs `get*` vs `find*`

| Variant | Throws if missing? | Returns | Use when |
|---------|-------------------|---------|----------|
| `get*` | Yes | Element | You expect the element to be present now |
| `query*` | No | Element or null | You're asserting the element is **absent** |
| `find*` | Yes (after timeout) | Promise<Element> | Element appears asynchronously |

```ts
// ✓ Use query* only to assert non-existence
expect(screen.queryByText("Error")).not.toBeInTheDocument()

// ✓ Use get* to assert presence
expect(screen.getByRole("button", { name: /submit/i })).toBeInTheDocument()

// ✓ Use find* for async appearance
const alert = await screen.findByRole("alert")
```

---

## Common Mistakes to Avoid

**1. Testing with `getByTestId` instead of semantic queries** — `data-testid` is invisible to users and screen readers.

**2. Asserting absence with `get*`** — `get*` throws before your assertion runs; use `query*` to assert absence.

**3. Wrapping in `act` unnecessarily** — Testing Library wraps `render`, `fireEvent`, and `userEvent` in `act` for you. Only add explicit `act` calls for imperative state updates outside Testing Library's control.

**4. Hardcoding IDs in assertions** — Look up IDs from the same source the component uses rather than tying tests to data shape internals.

**5. One giant test doing everything** — Each `it` block should test one user-observable behaviour. Share setup via a render helper.

---

## Checklist

Before committing a component test:

- [ ] Queries use role/label/text — no `querySelector`, `getByTestId`, or class selectors
- [ ] User interactions use `userEvent` (or `fireEvent` with a documented reason)
- [ ] Async elements use `find*` or `waitFor`
- [ ] Assertions use `jest-dom` matchers (`toBeDisabled`, `toBeInTheDocument`, etc.)
- [ ] `query*` is only used to assert element **absence**
- [ ] Mocks are reset in `afterEach` (`vi.restoreAllMocks()` + `cleanup()`)
- [ ] Redux state is seeded via store preloaded state, not by mocking selectors
- [ ] Each test exercises one user-observable behaviour

---

## Further Reading

- [Testing Library — Guiding Principles](https://testing-library.com/docs/guiding-principles)
- [Testing Library — Query Priority](https://testing-library.com/docs/queries/about/#priority)
- [Testing Library — User Event](https://testing-library.com/docs/user-event/intro/)
- [Kent C. Dodds — Write tests. Not too many. Mostly integration.](https://kentcdodds.com/blog/write-tests)
- [Kent C. Dodds — Testing Implementation Details](https://kentcdodds.com/blog/testing-implementation-details)
- [Kent C. Dodds — Common Mistakes with React Testing Library](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
- [Kent C. Dodds — The Testing Trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)
- [Mock Service Worker](https://mswjs.io/)
