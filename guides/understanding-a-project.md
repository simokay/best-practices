---
title: Understanding a Project
parent: Guides
nav_order: 1
---

# Understanding a Project

Use this guide when joining a new codebase, picking up an unfamiliar service, or preparing to make significant changes to a system you don't yet know well. The goal is to build an accurate mental model before touching anything.

---

## 1. Read all available documentation first

Before looking at code, exhaust what's already written down.

- Read the README end-to-end — setup steps, architecture overview, contribution guidelines
- Find and read any architecture decision records (ADRs), wikis, or runbooks
- Check for a `docs/` directory, Confluence space, or Notion pages
- Note gaps and contradictions — documentation rot is itself a signal

> Refer to [Technical Documentation](../technical-documentation) for what well-structured documentation looks like and what to expect from each documentation type (tutorials, how-tos, references, explanations).

---

## 2. Understand how the project is built and deployed

The CI/CD pipeline tells you the team's quality bar and operational model.

- Identify what runs on every commit (lint, tests, security scans)
- Understand the branch and merge strategy
- Trace a change from commit to production — where are the gates?
- Find the deployment targets: environments, regions, cloud provider
- Look for infrastructure-as-code (Terraform, Pulumi, CDK) alongside the application code

> Refer to [CI/CD Fundamentals](../cicd-fundamentals) for the principles behind pipeline design and what a healthy pipeline looks like.

---

## 3. Run it locally

Nothing replaces actually running the project. Do this early, before you've formed too many assumptions.

- Follow the setup instructions exactly — note anything that doesn't work or is missing
- Run the full test suite and observe the pass rate and speed
- Start the application and use its primary flows
- Introduce a trivial change and verify the feedback loop works end-to-end

---

## 4. Map the architecture

Build a component map — even a rough one on paper.

- Identify the major services, modules, or layers and their responsibilities
- Trace the primary data flows: where does data enter, transform, and exit?
- Identify external dependencies: databases, caches, queues, third-party APIs
- Note synchronous vs asynchronous boundaries
- Look for the places where failure is most likely to propagate

> Refer to [API Design Best Practices](../api-design-best-practices) when the project involves service-to-service or client-facing APIs.

---

## 5. Review recent history

The git log is a record of the team's decisions and recurring problems.

- `git log --oneline -50` — get a sense of commit rhythm and message quality
- Look at recently merged PRs for context on in-progress work and conventions
- Check open issues and bug trackers for known problems
- Note files that change frequently — they're high-churn and high-risk

---

## 6. Audit the security posture

Understanding how the project handles security helps you avoid inadvertently breaking it.

- Identify how authentication and authorisation are implemented
- Find where user input enters the system and how it's validated or sanitised
- Locate where secrets and credentials are managed — are they in environment variables, a vault, or (badly) in code?
- Check for dependency vulnerability scanning in CI

> Refer to [Code Auditing & Security Review](../code-auditing-security-review) and [Web Application Vulnerabilities](../web-application-vulnerabilities) for a structured security audit approach.

---

## 7. Understand the testing strategy

Test coverage and quality give you confidence about what you can safely change.

- Identify the types of tests present: unit, integration, end-to-end, contract
- Note what is and isn't tested — the gaps tell you where implicit assumptions live
- Understand what the team considers an acceptable coverage level
- Look for flaky tests — they erode trust in the whole suite

---

## 8. Establish a performance baseline

Know the system's normal before you change it.

- Look for existing dashboards, Grafana boards, or APM tooling
- Note key latency and throughput figures for the primary flows
- Identify any documented SLOs or SLAs

> Refer to [Performance Profiling](../performance-profiling) for how to measure and interpret performance characteristics.

---

## 9. Talk to the team

No document captures everything. Time with the people who built the system is irreplaceable.

- Ask about non-obvious architectural decisions — "why did you do it this way?"
- Ask what the known technical debt is and what's been deliberately deferred
- Ask what breaks most often and what's currently fragile
- Ask what the team wishes newcomers knew

---

## Checklist

- [ ] Documentation read; gaps noted
- [ ] Build, test, and deploy pipeline understood
- [ ] Project runs locally; trivial change verified
- [ ] Component map sketched
- [ ] Git history and open issues reviewed
- [ ] Auth, input handling, and secrets management understood
- [ ] Test strategy and coverage gaps identified
- [ ] Performance baseline noted
- [ ] Key questions asked of the team
