---
title: Debugging a Problem
parent: Guides
nav_order: 4
---

# Debugging a Problem

Use this guide when investigating a bug, unexpected behaviour, or production incident. Effective debugging is systematic, not lucky. The goal is to understand the root cause precisely enough to fix it correctly and prevent recurrence.

---

## 1. Reproduce the problem reliably

You cannot debug something you can't reproduce consistently.

- Establish a minimal reproduction case: the smallest input or state that triggers the problem
- Document the exact steps, inputs, and environment needed
- Confirm the problem does not occur without those conditions
- If you can't reproduce it locally, get access to the logs and environment where it does occur
- Flaky or intermittent bugs often point to concurrency, timing, or state-sharing issues

---

## 2. Gather information before forming conclusions

Resist the urge to jump straight to a fix. Read first.

- Collect the full stack trace, error message, and surrounding log lines
- Note the timestamp and frequency — is this constant, periodic, or following a pattern?
- Check monitoring and alerting dashboards for correlated signals
- Gather the relevant environment details: version, OS, runtime, config

> Refer to [Performance Profiling](../performance-profiling) for guidance on reading profiler output and traces when the problem is performance-related.

---

## 3. Check recent changes

Most bugs were introduced recently. Start there.

- `git log --oneline` the affected area to find changes in the relevant timeframe
- Use `git bisect` to binary-search commit history if the regression window is large
- Check whether a dependency was updated recently
- Look at deployment logs to correlate the problem onset with a release

---

## 4. Form a hypothesis

Generate a specific, falsifiable explanation before testing anything.

- State the hypothesis explicitly: "I believe X is happening because Y"
- Rank your hypotheses by likelihood given the evidence
- A hypothesis must make a prediction you can test — if it doesn't, it's not specific enough
- Work from the symptoms backwards to the cause, not from a hunch forwards

---

## 5. Test the hypothesis systematically

Eliminate variables one at a time.

- Add targeted logging or breakpoints to confirm or refute the hypothesis
- Change one thing at a time — changing multiple things simultaneously makes it impossible to know what worked
- If the hypothesis is wrong, update your model before forming the next one
- Don't stop at "it works now" without understanding why

---

## 6. Use the right tools for the problem type

| Problem type | Tools |
|---|---|
| Performance regression | Profiler, flame graphs, APM traces |
| Memory leak | Heap dump, allocation profiler |
| Concurrency / race condition | Thread analyser, sanitisers, structured logging with request IDs |
| Unexpected query behaviour | Query explain plan, database slow query log |
| Network / API issues | Request traces, curl reproduction, diff against spec |

> Refer to [Performance Profiling](../performance-profiling) for a detailed guide to profiling tools and interpretation.

---

## 7. Consider the non-obvious causes

When the obvious causes are ruled out, think broader.

- **Concurrency**: race conditions, lock contention, shared mutable state
- **Timing**: clock skew, timeout mismatches, ordering assumptions
- **Environment differences**: config, env vars, OS behaviour, library versions
- **Data edge cases**: nulls, empty collections, encoding issues, large inputs, locale
- **External dependencies**: third-party API behaviour changes, upstream failures
- **Caching**: stale data, cache invalidation bugs, inconsistent reads

---

## 8. Fix the root cause, not the symptom

A fix that masks the problem is worse than no fix — it hides the signal.

- State the root cause in one sentence before writing the fix
- If you can't explain the root cause, you haven't finished debugging
- Fix the mechanism that allowed the bug, not just the specific manifestation
- Consider whether the same class of bug could exist elsewhere and address it systematically

---

## 9. Write a regression test

A bug without a regression test is likely to come back.

- Write a test that fails on the unfixed code and passes on the fixed code
- The test should target the behaviour that was broken, not the implementation detail you changed
- If the bug was hard to reproduce, capture the minimal reproduction as a test fixture

---

## 10. Document the resolution

Debugging knowledge that isn't written down is lost.

- Write a clear commit message: what broke, why, and how it was fixed
- If it was a significant incident, write a post-mortem: timeline, root cause, remediation, prevention
- Update runbooks or FAQs if the same problem could trip up someone else
- If a misleading comment, confusing variable name, or missing documentation contributed to the difficulty of debugging, fix that too

---

## Checklist

- [ ] Problem reproduced reliably with a minimal case
- [ ] Evidence gathered: logs, traces, stack traces, environment details
- [ ] Recent changes reviewed; `git bisect` used if needed
- [ ] Hypothesis formed and stated explicitly
- [ ] Hypothesis tested; variables changed one at a time
- [ ] Appropriate tools used for the problem type
- [ ] Non-obvious causes considered
- [ ] Root cause identified and stated
- [ ] Root cause fixed, not just the symptom
- [ ] Regression test written
- [ ] Commit message or post-mortem documents the resolution
