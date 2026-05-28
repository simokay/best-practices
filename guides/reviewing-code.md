---
title: Reviewing Code
parent: Guides
nav_order: 3
---

# Reviewing Code

Use this guide when performing a code review. A thorough review protects the codebase, helps the author grow, and distributes knowledge across the team. The goal is not to find fault — it's to ship correct, maintainable software together.

---

## 1. Understand the context before reading the diff

A reviewer who doesn't understand the goal will give the wrong feedback.

- Read the PR description in full before opening a single file
- Read the linked ticket or issue
- Understand what the author is trying to achieve and why
- Note the scope: what is explicitly in and out of scope for this change?

---

## 2. Evaluate the design

High-level design problems are the most expensive to catch late.

- Is this the right approach to the problem?
- Are there simpler alternatives that would achieve the same outcome?
- Does the change fit the existing architecture, or is it pulling in a new direction?
- Are the right responsibilities in the right places?
- For API changes: is the interface intuitive? Will it age well?

> Refer to [API Design Best Practices](../api-design-best-practices) when reviewing service interfaces, REST endpoints, or library APIs.

---

## 3. Review for security vulnerabilities

Security issues introduced in review are expensive to fix later and potentially catastrophic in production.

Work through the change with these questions:

- **Injection**: Is user input reaching a database query, shell command, or template without proper sanitisation?
- **Authentication and authorisation**: Are new endpoints and operations protected? Is the principle of least privilege applied?
- **Data exposure**: Are sensitive fields (passwords, tokens, PII) being returned, logged, or stored where they shouldn't be?
- **Input validation**: Is data validated at the trust boundary before being processed?
- **Dependency changes**: Do any new dependencies have known vulnerabilities?

> Refer to [Web Application Vulnerabilities](../web-application-vulnerabilities) for the full taxonomy of vulnerability classes to check, and [Code Auditing & Security Review](../code-auditing-security-review) for structured security review techniques.

---

## 4. Review for performance

A change that is correct but slow is still a problem.

- Are there database queries inside loops (N+1)?
- Are expensive operations (network calls, disk I/O) on hot paths that could be moved or cached?
- Are there unnecessary memory allocations in tight loops?
- Does the algorithmic complexity match the expected scale of input?
- For schema changes: are appropriate indexes in place?

> Refer to [Performance Profiling](../performance-profiling) for the mental models and measurement techniques behind performance analysis.

---

## 5. Evaluate test quality

Tests are part of the code. A PR without adequate tests should not be merged.

- Does the test suite cover the happy path?
- Are error cases, boundary conditions, and the edge cases mentioned in the ticket tested?
- Are the assertions meaningful, or do they pass vacuously?
- Are tests independent of implementation details (do they test behaviour, not internals)?
- Would you be confident refactoring this code knowing only these tests protect it?

---

## 6. Check error handling

How code fails is as important as how it succeeds.

- Are errors handled or propagated appropriately at each level?
- Are error messages informative for debugging without leaking sensitive information?
- Is the application left in a consistent state if an operation fails partway through?
- Are timeouts and retries in place for external calls?

---

## 7. Review documentation and comments

- Are public interfaces, non-obvious behaviour, and important constraints documented?
- Have existing docs been updated to reflect the change?
- Are any comments explaining *why*, not just *what*?
- Are there TODOs left in that should be resolved or tracked as separate tickets?

> Refer to [Technical Documentation](../technical-documentation) for principles on what to document and how.

---

## 8. Check consistency with the codebase

Inconsistency compounds maintenance cost over time.

- Does the change follow the existing naming conventions, patterns, and idioms?
- Is the code formatted consistently with the rest of the project?
- Are new abstractions necessary, or could an existing one be extended?
- Does the PR scope creep into unrelated areas in a way that obscures the core change?

---

## 9. Verify CI and automation

Don't approve a PR with a failing pipeline unless there's an explicit, understood reason.

- Are all automated checks passing?
- Are any new tests in CI?
- Are linting and type-checking clean?

---

## 10. Give feedback that is specific and actionable

The quality of your feedback determines whether it improves the code and the author.

- Be specific: point to the exact line, explain the concern, suggest an alternative
- Distinguish blocking issues from suggestions: use a label or prefix ("Blocking:", "Nit:", "Question:")
- Explain your reasoning — "why" makes feedback easier to act on and learn from
- Acknowledge good decisions — code review isn't only about problems
- Don't approve with unresolved blocking comments; don't block over non-issues

---

## Checklist

- [ ] PR description and ticket read; context understood
- [ ] Design is sound; scope is appropriate
- [ ] No injection, auth, or data exposure vulnerabilities introduced
- [ ] No obvious performance regressions
- [ ] Test coverage is adequate and assertions are meaningful
- [ ] Error handling is correct
- [ ] Documentation is updated
- [ ] Change is consistent with existing patterns
- [ ] CI is passing
- [ ] Feedback is specific, labelled, and actionable
