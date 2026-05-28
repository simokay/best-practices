---
title: React Patterns
parent: Frontend
nav_order: 1
---

# React / Redux / Next.js Patterns

## 1) Architecture and Boundaries

- Keep UI components focused on rendering and interaction; move business rules into pure helpers/services.
- Prefer feature-based folder boundaries (`features/<domain>`) with explicit public entry points.
- Keep API route handlers thin: validate input, call domain logic, return typed outputs.
- Avoid cross-feature imports of internals; expose stable types/selectors/actions from index files.

## 2) State Management (Redux)

- Store canonical state once; derive view state with memoised selectors.
- Keep Redux state serialisable and normalised where relationships exist.
- Use slice reducers for deterministic state changes; avoid side effects in reducers.
- Encapsulate permission/role logic in selectors (single source of truth for auth checks).
- Prefer event-style action names (`itemUpdated`, `pageSelected`) over setter-style names.

## 3) React Component Patterns

- Keep components small and compose by concern (data, layout, controls, modal flows).
- Use local state for transient UI only; persist domain state in Redux/server as needed.
- Extract repeated modal/list/form patterns into reusable components/hooks.
- Use stable keys derived from IDs, not index-based keys.
- Avoid duplicate computed work in render/memo blocks.

## 4) Next.js App Practices

- Use server routes for privileged or validated operations; avoid duplicating auth logic in clients.
- Return consistent API response envelopes (`{ data, error }` or equivalent).
- Validate route input and fail with clear 4xx errors for bad requests.
- Keep client bundles lean: avoid importing large datasets in components unless required.
- Split server-only and client-only utilities clearly.

## 5) Performance

- Measure before optimising, then optimise hot paths with profiling evidence.
- Memoize expensive derivations and normalise data structures for fast lookups.
- Avoid repeated parsing/transforms for static datasets; pre-index once.
- Debounce/throttle high-frequency updates where user experience allows.
- Batch related state updates and avoid unnecessary network refetches.

See [react-performance.md](./react-performance.md) for `memo`/`useMemo`/`useCallback` criteria.

## 6) Testing Strategy

- Prioritise affirmative tests that describe user value (e.g. "clicking apply updates state").
- Keep tests small and concrete; one behaviour expectation per test where practical.
- Prefer integration-style tests for feature flows (UI + state + API boundary mocks).
- Use unit tests for pure rules/selectors/transforms (especially dataset-driven logic).
- Add regression tests for every bug fix.

## 7) Test Pyramid (Practical)

- **Unit**: rules engine, helpers, selectors, normalisers, parsers.
- **Integration**: slice + component interaction, modal workflows, API handler behaviour.
- **Contract**: API response/shape and validation tests.
- **E2E** (critical paths only): authentication, core create/read/update flows, real-time sync.

See [react-testing.md](./react-testing.md) for Testing Library patterns.

## 8) TypeScript Quality

- Model domain types once and reuse across UI, slices, and API handlers.
- Avoid `any`; prefer narrow unions and guards for external/JSON data.
- Use explicit return types for key helpers and selectors.
- Keep test utility types realistic so tests catch real integration problems.

## 9) Maintainability and Refactoring

- Remove dead code promptly and keep TODOs actionable with scope and outcome.
- Prefer renaming for intent clarity over adding comments to unclear code.
- Introduce utility helpers when logic repeats 2+ times.
- Keep files manageable by extracting subcomponents when flows grow.

## 10) Reliability and Observability

- Handle expected failures gracefully with user-facing feedback.
- Log with context (entity IDs, operation name) to speed incident debugging.
- Add guardrails for race conditions in async flows (in-flight flags, request ordering).
- Prefer idempotent writes for persistence paths where possible.

## 11) Security and Data Integrity

- Enforce permissions server-side; client-side checks are UX only.
- Validate all external input and sanitise unsafe text rendering.
- Keep database policies aligned with app role rules and test policy-dependent flows.

## 12) Delivery Workflow

For each feature/change:
1. Add/adjust failing tests for intended behaviour.
2. Implement the smallest safe change.
3. Verify with targeted test suite + `tsc`.
4. Document follow-ups if scope is larger.
