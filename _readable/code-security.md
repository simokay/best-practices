# Building Security Into Your Code

Security vulnerabilities are almost always cheaper to prevent than to fix. The further a defect travels through the development process — from design, to testing, to production — the more it costs to address. A vulnerability found during design costs a fraction of one found after deployment. When discovered by an attacker in production, the cost includes user harm, reputational damage, and potential legal liability.

This means security cannot be a gate at the end of development. It must be woven into every phase.

---

## Threat Modeling: Think Like an Attacker Before Writing Code

The most effective time to address a security problem is before any code exists. Threat modeling is the practice of systematically asking: what could go wrong, and how bad would it be?

Start by drawing a diagram of your system — every component, every place data flows between them, and every trust boundary where data crosses between different privilege levels or network zones. Then work through each component and ask what an attacker could do to it.

A useful framework for this is STRIDE, which categorises threats into six types: Spoofing (pretending to be someone else), Tampering (modifying data in transit or at rest), Repudiation (denying an action was taken), Information Disclosure (leaking data to unauthorised parties), Denial of Service (making the system unavailable), and Elevation of Privilege (accessing capabilities beyond your authorisation).

For each threat you identify, decide on a mitigation before implementation begins. Documenting this creates a record of your security decisions that is invaluable for future reviews.

---

## Static Analysis: Reading Code for Vulnerabilities

Static analysis means examining code without running it. It has two forms: manual review and automated tooling. Both are necessary — they find different things.

**Manual review** should be risk-based. Not all code warrants equal scrutiny. Focus your attention on the places where security failures are most consequential: authentication and authorisation logic, cryptographic operations, input parsing, serialisation and deserialisation handlers, and any place where privilege levels change.

When reviewing manually, you can approach from two directions. Working top-down means starting at every entry point — every HTTP endpoint, every CLI argument, every message queue consumer — and following data inward, asking at each step whether it is validated before use. Working bottom-up means starting at the most dangerous functions — database query construction, shell command execution, HTML template rendering — and tracing backward to find where their arguments originate.

**Automated tools** run quickly and consistently, and they catch patterns that humans miss when fatigued. The key rules for using them effectively: fix all high-severity, high-confidence findings before merging; integrate them into your CI pipeline so new findings cannot be introduced silently; and take false positives seriously — if the tool cries wolf too often, developers will stop listening to it entirely.

---

## Dynamic Analysis: Testing Running Code

Dynamic analysis tests the application while it is executing.

**Fuzzing** is the practice of feeding malformed, random, or boundary-value inputs to parsers, APIs, and protocol handlers to find inputs that cause crashes or unexpected behaviour. It is one of the highest return-on-investment security techniques available. A parser that handles all well-formed inputs correctly may still fail catastrophically on a single malformed byte.

**Penetration testing** simulates an attacker's approach — it tells you what is broken. A **security audit** is a more thorough examination — it tells you why something is broken and what class of defect to address systematically. Both are valuable and neither replaces the other.

---

## What to Look For: The Security Checklist

**Authentication:** Passwords must be hashed using a slow, purpose-built algorithm — bcrypt, scrypt, or Argon2. Fast hashing algorithms like MD5 or SHA1 are trivially reversible with modern hardware. Password reset tokens must be cryptographically random, single-use, and short-lived. Session tokens must be invalidated server-side on logout — deleting a cookie is not enough. Login endpoints must be rate-limited.

**Authorisation:** Every privileged operation must verify permissions on the server, not just in the interface. Object-level authorisation is a distinct concern from function-level authorisation: the fact that a user can access invoices in general does not mean they can access any specific invoice. Check ownership on every request. Apply the principle of least privilege — accounts and services should have exactly the permissions they need and no more.

**Input validation:** All external input is untrusted, regardless of its apparent source. SQL queries must use parameterised statements, never string concatenation. HTML output must escape user-controlled values. File paths must be validated and canonicalised to prevent path traversal. Never pass user input directly to a shell command.

**Cryptography:** Do not invent your own cryptographic algorithms. Use well-audited, widely-deployed libraries. For symmetric encryption, use AES-GCM or ChaCha20-Poly1305. For passwords, use a slow hashing algorithm. Never store secrets in source code — load them from environment variables or a secrets manager at runtime. Enforce TLS for all data in transit.

**Error handling:** Stack traces and internal error details must never be returned to clients. Security events — failed logins, privilege escalations, access to sensitive data — must be logged. Logs must not contain passwords, tokens, or payment card numbers.

**Dependencies:** Pin your dependency versions. Run automated scanning for known vulnerabilities as part of your CI pipeline. A vulnerability in a library you depend on is a vulnerability in your application.

---

## Shifting Security Left: Making It Continuous

The goal is to catch problems as early and automatically as possible.

Before a commit is made, secret detection tools can scan staged changes for accidentally included credentials and API keys. This is cheap insurance against one of the most common and damaging mistakes.

In the pull request pipeline, static analysis tools should run automatically and block merging if they find high-severity issues. Security-sensitive code paths — authentication, authorisation, payment flows — should require a security-aware reviewer.

Dependency vulnerability scanning should run daily, not just at build time. New vulnerabilities are disclosed every day, and a library that was safe yesterday may not be safe today.

Against staging environments, automated dynamic scanners can probe for common vulnerabilities before code reaches production. This catches a class of issues that static analysis misses entirely.

---

## Reporting a Finding

When you find a vulnerability, a good report contains: the exact location in the code, a severity assessment, a clear description of what the vulnerability is and why it matters, the exact steps to reproduce it or a proof of concept, and a specific actionable fix. Referencing the relevant Common Weakness Enumeration identifier gives the finding precision and connects it to the broader industry knowledge base.
