# Understanding Web Application Vulnerabilities

Web applications are attacked constantly. Understanding the most common ways they fail is essential for building them correctly, reviewing others' code, and responding effectively when something goes wrong.

The security industry maintains standardised catalogues of vulnerability classes. The most widely used is the OWASP Top 10, which ranks the most critical web application security risks based on data from real-world assessments. Alongside it is the Common Weakness Enumeration, a taxonomy of the underlying root causes of software weaknesses. When you identify a vulnerability, referencing its Common Weakness Enumeration identifier gives it precision and connects your finding to an established body of knowledge.

---

## Injection

Injection is the vulnerability class where user-supplied data is interpreted as code rather than as data. The application fails to maintain the boundary between instructions and input.

SQL injection is the classic example. A login form that constructs a database query by concatenating the user's input directly into the query string can be manipulated to make the query mean something entirely different from what was intended. A carefully crafted username can cause the query to return all users, bypass the password check, or execute arbitrary database operations.

The fix is always to use parameterised queries or prepared statements, where the query structure is defined separately from the data. The same principle applies to other injection contexts: OS command injection (user input passed to a shell), template injection (user input evaluated by a templating engine), and LDAP injection.

A particularly important variant is second-order injection, where a payload is stored in the database and executed later — sometimes in a different part of the application, bypassing input filters applied at the time of writing.

---

## Broken Authentication

Authentication weaknesses allow attackers to assume other users' identities. The most prevalent real-world attack is credential stuffing: automated use of username and password pairs leaked from other services' breaches. Because people reuse passwords across services, credentials stolen from one breach are tried systematically against others.

Other common failures include: login endpoints with no rate limiting or account lockout, allowing brute-force attacks; password reset flows with predictable or reusable tokens; session fixation, where an attacker pre-sets a session identifier that a victim then authenticates under; and long-lived "remember me" tokens derived from predictable values.

The mitigations: use a slow hashing algorithm designed for passwords. Apply rate limiting to login and password reset endpoints. Issue cryptographically random session tokens with sufficient entropy. Issue a new session identifier whenever the user's privilege level changes. Consider checking submitted passwords against known breach databases at registration and login.

---

## Broken Access Control

Access control failures are consistently the most prevalent finding in real-world web application assessments.

The most important sub-class is Broken Object Level Authorisation, sometimes called Insecure Direct Object Reference. The vulnerability is simple: an application checks whether a user is allowed to access a type of resource, but fails to check whether they are allowed to access a specific instance of that resource. A user who can access their own invoice at a given URL may be able to access any invoice simply by changing the identifier in the URL.

The fix is equally simple in principle: every request that accesses a specific object must verify that the requesting user has permission to access that specific object, not just that object type in general.

Beyond object-level authorisation, access control failures include: function-level authorisation failures, where administrative endpoints are accessible without admin privileges; path traversal, where file paths constructed from user input can be manipulated to reach files outside the intended directory; and privilege escalation, both horizontal (accessing a peer's data) and vertical (accessing functionality reserved for higher-privilege roles).

All authorisation logic must run on the server. Client-side checks are not authorisation — they are user experience.

---

## Cryptographic Failures

This class covers both failing to encrypt data that should be protected and using encryption incorrectly.

Common failures include: transmitting sensitive data over unencrypted connections; storing passwords with fast hashing algorithms that are trivially reversible; using cryptographic modes that are vulnerable to specific attacks (ECB mode leaks patterns; CBC without authentication is vulnerable to padding oracle attacks); reusing initialisation vectors with stream ciphers or authenticated encryption modes, which is catastrophic for confidentiality; and hardcoding encryption keys in source code.

The guiding principle is not to invent cryptographic systems, however clever they seem. Standard, audited, widely-deployed algorithms are not just easier to implement — they have been scrutinised by specialists looking for flaws for decades. A custom algorithm designed in an afternoon has not. Use well-audited libraries, apply established algorithms, and use a secrets management system to handle keys.

---

## Security Misconfiguration

A large proportion of critical vulnerabilities in production systems are not code bugs — they are configuration problems. Default credentials left unchanged. Detailed error messages and stack traces returned to end users. Directory listings enabled. Security headers absent. Cloud storage buckets unintentionally made public. CORS configured to allow any origin on APIs that require authentication.

These are all preventable with consistent practices: use infrastructure-as-code so all configuration is version-controlled and audited; treat the default-deny principle as the baseline; run automated configuration scanning as part of your pipeline; and never rely on any single layer of configuration as your only defence.

---

## Vulnerable and Outdated Components

Running software with known, unpatched vulnerabilities is a systemic problem. Several of the highest-profile security breaches in recent years — affecting tens or hundreds of millions of records — were caused not by novel attack techniques but by organisations failing to apply patches for known vulnerabilities that had been public for weeks or months.

The mitigation is automation: use software composition analysis tools that scan your dependencies against databases of known vulnerabilities. Maintain an inventory of what you depend on. Automate dependency update pull requests. Subscribe to security advisories for your most critical dependencies. Pin versions in production so you know exactly what is running.

---

## Cross-Site Scripting

Cross-site scripting allows attacker-controlled JavaScript to execute in another user's browser in the context of the vulnerable application. This gives an attacker access to anything the user can do or see in that application: their session cookies, their data, the ability to take actions on their behalf.

There are three variants. Reflected cross-site scripting returns a payload from the request directly in the response. Stored cross-site scripting persists the payload in the database and serves it to anyone who views the affected page — no social engineering required. DOM-based cross-site scripting processes the payload entirely in the browser via JavaScript, without the server ever seeing it.

Modern frontend frameworks escape HTML output by default, which eliminates most reflected and stored cross-site scripting. The remaining risk comes from explicitly bypassing that escaping. A Content Security Policy prevents inline script execution as a defence in depth. HttpOnly cookies prevent session tokens from being accessible via JavaScript, limiting the impact of an exploit.

---

## Cross-Site Request Forgery

Cross-site request forgery tricks an authenticated user's browser into making a request to a target application without the user's knowledge. A malicious page can cause a user's browser to send a request to their bank, their email provider, or any other service they are logged into — including modifying data or initiating transactions.

Modern browsers address this substantially through the SameSite cookie attribute, which prevents cookies from being sent on cross-site requests. Combined with CSRF tokens — unpredictable per-session values that must be included in state-changing requests — this vulnerability is well understood and straightforward to mitigate.

---

## Server-Side Request Forgery

Server-side request forgery causes the server to make HTTP requests to attacker-controlled destinations. In cloud environments this is particularly dangerous: an attacker who can cause the server to make requests to the cloud provider's internal metadata service can retrieve credentials that grant access to the entire cloud account.

The mitigation is strict allowlisting of permitted URL schemes and destinations rather than attempting to blocklist dangerous ones. Blocklists are always incomplete. Network segmentation ensures that application servers cannot reach internal management interfaces directly.

---

## Insecure Deserialisation

Deserialising untrusted data using language-native serialisation formats can execute arbitrary code, depending on which objects and methods are available in the runtime. This has been exploited in Java, Python, PHP, and Ruby applications.

Prefer standard data interchange formats — JSON or Protocol Buffers — over language-native serialisation for any data crossing a trust boundary. If native serialisation is unavoidable, use integrity checks to verify the data has not been tampered with before deserialising it.

---

## Assessing Severity

When evaluating a vulnerability, consider four dimensions: how easy it is to exploit (does it require authentication? can it be triggered remotely?); what its scope is (does it cross privilege boundaries or affect other users?); what its impact is on confidentiality, integrity, and availability; and how widespread the vulnerable code path is. The CVSS scoring system provides a starting point, but context always matters more than a formula.
