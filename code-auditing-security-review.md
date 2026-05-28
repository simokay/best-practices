---
title: Code Auditing & Security Review
nav_order: 3
---

# Code Auditing Techniques and Security Review Practices

> Synthesized from the work of **Gary McGraw** (Software Security: Building Security In), **Michael Howard & David LeBlanc** (Writing Secure Code, Microsoft SDL), **Bruce Schneier** (Secrets & Lies, Cryptography Engineering), **John Viega** (Building Secure Software), and the **OWASP** project contributors.

---

## Why Security Must Be Built In, Not Bolted On

Gary McGraw's foundational insight from decades of software security consulting: **most vulnerabilities are introduced at the design and implementation phases**, not discovered and patched post-deployment. The Security Development Lifecycle (SDL), formalized by Michael Howard at Microsoft, quantifies this — fixing a defect found in requirements costs 1x; found in testing costs 10x; found in production costs 100x.

Security review is not a gate at the end of the SDLC. It is a continuous practice embedded in every phase.

---

## The Three Pillars of Code Security Review

### 1. Design Review (Threat Modeling)

Before a single line of code is audited, you need a threat model. The industry standard approach, from Adam Shostack's *Threat Modeling: Designing for Security*, uses the **STRIDE** framework:

| Threat | Property Violated | Example |
|---|---|---|
| **S**poofing | Authentication | Forging a session token |
| **T**ampering | Integrity | Modifying a request payload |
| **R**epudiation | Non-repudiation | Denying an action was taken |
| **I**nformation Disclosure | Confidentiality | Leaking a user's PII |
| **D**enial of Service | Availability | Exhausting connection pools |
| **E**levation of Privilege | Authorization | Accessing admin endpoints as a regular user |

**How to do it:**
1. Draw a data flow diagram (DFD) covering all trust boundaries — where data crosses between processes, networks, or privilege levels.
2. Apply STRIDE to each element (processes, data stores, data flows, external entities).
3. Rate threats using **DREAD** (Damage, Reproducibility, Exploitability, Affected users, Discoverability) or CVSS for severity.
4. Document mitigations per threat before implementation begins.

### 2. Static Analysis

Reading code without executing it. Divided into manual and automated approaches.

**Manual Code Review Techniques (Gary McGraw's approach):**

- **Top-down review**: Start from entry points (HTTP handlers, CLI argument parsers, message queue consumers) and trace data as it flows inward. Ask: is this input validated before it's used?
- **Bottom-up review**: Identify dangerous functions first (`exec`, `eval`, `query`, `innerHTML`, `deserialize`), then trace backward to find where their arguments come from.
- **Risk-based targeting**: Not all code warrants equal scrutiny. Focus on: authentication/authorization logic, cryptographic operations, input parsing, serialization/deserialization, IPC and RPC handlers, privilege transitions.

**Automated Static Analysis Tools:**

| Language | Tool | Focus |
|---|---|---|
| Any | Semgrep | Custom rule-based pattern matching |
| C/C++ | Coverity, Clang Static Analyzer | Memory safety, null dereference |
| Java | SpotBugs + FindSecBugs, Checkmarx | Injection, crypto misuse |
| Python | Bandit, Pysa | Injection, SSRF, taint analysis |
| JavaScript/TS | ESLint (security plugins), CodeQL | XSS, prototype pollution |
| Go | gosec, staticcheck | Security-specific Go patterns |
| Ruby | Brakeman | Rails-specific vulnerabilities |

**Rules for automated tools (from the SDL):**
- Fix all high-confidence, high-severity findings before merging. No exceptions without documented risk acceptance.
- Integrate into CI/CD so no new findings can be introduced on the main branch.
- Treat false positives seriously — high false-positive rates cause developers to ignore all warnings.

### 3. Dynamic Analysis

Testing running code.

**Fuzzing:** Bruce Schneier and the broader security community consistently flag fuzzing as one of the highest ROI techniques. Feed malformed, random, or boundary-value inputs to parsers, APIs, and protocol implementations.

- **dumb fuzzing**: random mutation of valid inputs (AFL, libFuzzer)
- **smart/grammar-based fuzzing**: structured inputs respecting format (Boofuzz for protocols, RESTler for APIs)
- **coverage-guided fuzzing**: AFL++ and libFuzzer instrument binaries to guide input generation toward unexplored code paths

**Penetration Testing vs. Security Auditing:**

Michael Howard draws a sharp distinction: pen testing tells you *what* is broken; a security audit tells you *why* it is broken and how to fix the class of defect. Both are necessary. Neither replaces the other.

---

## The Code Review Checklist

Derived from the OWASP Code Review Guide and Microsoft SDL practices.

### Authentication
- [ ] Passwords hashed with bcrypt, scrypt, or Argon2 (never MD5, SHA1, or unsalted SHA2)
- [ ] Password reset tokens are cryptographically random, single-use, and expire quickly
- [ ] Multi-factor authentication cannot be bypassed by manipulating client-side state
- [ ] Session tokens are invalidated on logout (server-side invalidation, not just cookie deletion)
- [ ] Account lockout or rate limiting exists on login endpoints

### Authorization
- [ ] Every privileged operation checks permissions server-side, not just in the UI
- [ ] Object-level authorization: verify the requesting user owns the resource (Broken Object Level Authorization — OWASP API #1)
- [ ] No authorization decisions based on user-supplied role fields without server-side verification
- [ ] Principle of least privilege: service accounts and DB users have only the permissions they need

### Input Validation & Injection Prevention
- [ ] All external input is treated as untrusted regardless of source
- [ ] SQL: parameterized queries or ORM-level binding — no string concatenation into queries
- [ ] OS commands: avoid `exec(user_input)` entirely; if unavoidable, use allowlists not blocklists
- [ ] HTML output: all user-controlled values HTML-escaped (or use a safe templating engine that auto-escapes)
- [ ] File paths: validate and canonicalize before use; prevent path traversal (`../`)
- [ ] XML: external entity processing disabled (XXE prevention)

### Cryptography (from Schneier's and Viega's writing)
- [ ] No custom cryptographic algorithms (use well-audited libraries: libsodium, BouncyCastle, Go's `crypto/*`)
- [ ] AES-GCM or ChaCha20-Poly1305 for symmetric encryption (not AES-CBC without authentication)
- [ ] RSA-OAEP or ECDH for asymmetric operations (not raw RSA)
- [ ] Secrets (API keys, tokens, private keys) never hardcoded; loaded from environment or secrets manager
- [ ] TLS 1.2+ enforced; older protocols disabled
- [ ] Random number generation uses a CSPRNG (not `Math.random()`, `rand()`)

### Error Handling & Logging
- [ ] Stack traces and internal errors never returned to clients
- [ ] Security events logged: failed logins, privilege escalations, sensitive data access
- [ ] Logs do not contain passwords, tokens, or full credit card numbers
- [ ] Logging is tamper-evident (append-only log stores, or SIEM pipelines)

### Dependency Management
- [ ] Dependency versions pinned; automated scanning for known CVEs (Dependabot, Snyk, OWASP Dependency-Check)
- [ ] Minimal dependency surface: don't import a 500KB library for one utility function
- [ ] Supply chain: verify checksums/hashes for downloaded packages in CI

---

## Conducting a Formal Security Review

### Pre-Review Setup
1. Scope the review: what modules, what threat actors, what impact level?
2. Obtain architecture diagrams, data flow diagrams, and the threat model if they exist.
3. Set up a local build environment to run and debug the code.

### Review Execution

**Pass 1 — Structural**: Run all automated scanners. Triage findings. Dismiss confirmed false positives with written justification.

**Pass 2 — Entry point enumeration**: List every way data enters the system. For a web application this means every route/endpoint. For a library it means every public API. For a CLI it means every argument and environment variable. This is your attack surface.

**Pass 3 — Data flow tracing**: For each entry point, trace data through the system asking: is it validated? Sanitized? Encoded correctly before output? Are trust boundaries enforced?

**Pass 4 — Sensitive operations audit**: Enumerate all cryptographic operations, all authentication/authorization checks, all calls to exec/eval/deserialize/query, and review each in detail.

**Pass 5 — Business logic review**: Automated tools miss this entirely. Think like an attacker: what sequences of legitimate operations produce an illegitimate outcome? (Race conditions, price manipulation, workflow bypass.)

### Reporting Findings

A good security finding contains:
- **Location**: file, function, line number
- **Severity**: Critical / High / Medium / Low / Informational (use CVSS scoring)
- **Description**: what the vulnerability is and why it matters
- **Reproduction**: exact steps to reproduce or a proof-of-concept
- **Remediation**: specific, actionable fix — not just "sanitize inputs"
- **References**: CWE ID, OWASP category, CVE if applicable

---

## Continuous Security: Shifting Left

From Jez Humble's *Continuous Delivery* and the DevSecOps movement:

- **Pre-commit hooks**: Run secret detection (git-secrets, truffleHog) and fast linters before every commit.
- **Pull request gates**: SAST tools must pass before merge. Security reviewers are required approvers on security-sensitive paths.
- **Dependency scanning**: Run daily, not just at build time. CVEs are disclosed continuously.
- **DAST in staging**: Run automated scanners (OWASP ZAP, Burp Suite Pro automation) against staging deployments before production promotion.
- **Bug bounty / red team**: External adversarial testing that internal teams cannot replicate due to familiarity.

---

## Key References

- McGraw, G. (2006). *Software Security: Building Security In*. Addison-Wesley.
- Howard, M. & LeBlanc, D. (2002). *Writing Secure Code* (2nd ed.). Microsoft Press.
- Shostack, A. (2014). *Threat Modeling: Designing for Security*. Wiley.
- Viega, J. & McGraw, G. (2001). *Building Secure Software*. Addison-Wesley.
- Schneier, B. (2000). *Secrets and Lies*. Wiley.
- OWASP Code Review Guide v2: https://owasp.org/www-project-code-review-guide/
- NIST SP 800-115: Technical Guide to Information Security Testing and Assessment
