---
title: Working on a Ticket
parent: Guides
nav_order: 2
---

# Working on a Ticket

Use this guide when picking up a development task — a feature, bug fix, or improvement. It covers the full lifecycle from first reading the ticket to opening a pull request ready for review.

---

## 1. Understand the requirement before writing code

Time spent on clarity here saves multiples in rework later.

- Read the ticket fully, including comments — context is often buried there
- Identify the acceptance criteria: how will you know when this is done?
- Surface ambiguities before starting: edge cases, error states, scope boundaries
- Understand why this work is being done — the motivation shapes the right solution
- If the ticket is vague, write down your assumptions and get them confirmed

---

## 2. Understand the blast radius

Before touching anything, know what you might affect.

- Find the code you'll be changing and read it in full
- Identify what calls it, what it calls, and what depends on its behaviour
- Search for other usages of the functions, types, or APIs you'll be modifying
- Check whether the area has existing tests that will tell you if you break something

---

## 3. Consider security implications upfront

Security is harder to retrofit than to design in.

- Identify whether this change involves user input — validate and sanitise at the boundary
- Check whether new data is exposed in responses — apply the principle of least privilege
- Consider whether new functionality requires authorisation checks
- If touching auth, session handling, or payment flows: apply extra scrutiny

> Refer to [Web Application Vulnerabilities](../web-application-vulnerabilities) for the vulnerability classes most likely to be introduced during development, and [Code Auditing & Security Review](../code-auditing-security-review) for a systematic approach.

---

## 4. Design before coding

For anything non-trivial, think before you type.

- Sketch the approach: what changes, in what order, at what boundaries
- Consider alternative approaches and why you're choosing this one
- For significant changes, write up a short design note or discuss with a teammate
- Identify the riskiest part of the implementation and think it through first

---

## 5. Write tests before or alongside implementation

Tests are a specification as much as a safety net.

- Define what the correct behaviour is before you implement it
- Write a failing test first where practical (TDD) — it forces precision about requirements
- At minimum, write tests as you implement rather than after
- Cover the happy path, error paths, and the edge cases surfaced in step 1
- Avoid tests that are tightly coupled to implementation details — test behaviour

---

## 6. Implement in small, focused commits

Small commits are easier to review, easier to revert, and easier to understand in future.

- Each commit should represent a single coherent change
- Write commit messages that explain why, not just what
- Keep refactoring separate from behaviour changes — mixing them obscures both
- Push regularly — avoid long-lived local-only branches

---

## 7. Review your own diff before requesting review

Be your own first reviewer.

- Read every line you've changed as if you were the reviewer
- Check for debug statements, commented-out code, and TODOs left in
- Verify all tests pass locally
- Re-read the acceptance criteria — does your implementation satisfy them?
- Consider what questions a reviewer will ask and answer them preemptively

---

## 8. Check performance implications

Don't introduce regressions that only appear under load.

- Look for database queries inside loops (N+1)
- Check whether new dependencies or computations are called on hot paths
- Avoid allocating unnecessarily in tight loops
- If the change affects a performance-sensitive area, profile it

> Refer to [Performance Profiling](../performance-profiling) for how to identify and measure performance issues.

---

## 9. Update documentation

Documentation that's out of sync is worse than no documentation.

- Update the README if setup steps, environment variables, or architecture has changed
- Update inline documentation for any public API or interface you've changed
- Add a note to the ticket or PR about anything that affects runbooks or operational docs

> Refer to [Technical Documentation](../technical-documentation) for what to document and how.

---

## 10. Write a clear pull request description

The PR description is the primary communication channel with your reviewers.

- Summarise what the change does and why
- Link to the ticket and any relevant design discussions
- Describe how to test or verify the change
- Call out areas where you'd particularly like feedback
- Note any known limitations, follow-up work, or deliberate trade-offs

---

## Checklist

- [ ] Requirement and acceptance criteria understood; ambiguities resolved
- [ ] Blast radius mapped; dependents identified
- [ ] Security implications considered
- [ ] Approach designed; alternatives considered
- [ ] Tests written alongside implementation
- [ ] Commits are small and well-described
- [ ] Own diff reviewed; tests passing locally
- [ ] Performance implications checked
- [ ] Documentation updated
- [ ] PR description written with context for reviewers
