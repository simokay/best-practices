# Understanding Web Application Vulnerabilities

I want to start with a story about Equifax. In 2017, attackers exfiltrated the personal data of 147 million Americans. Names, Social Security numbers, dates of birth, addresses, credit card details. The company paid over 575 million dollars in fines and settlements. It became one of the defining security failures of the decade.

The vulnerability that enabled it was SQL injection. Not a novel, sophisticated technique. Not a zero-day exploit known only to intelligence agencies. SQL injection has been on the OWASP Top Ten list — the industry's catalogue of the most critical web application risks — since that list was first published in 2003. The patch was available. The process for applying it existed. And yet, between the vulnerability being announced and the breach occurring, the patch was not applied.

I tell that story not to apportion blame, but because it captures something important about how web application vulnerabilities actually work in practice. The most dangerous vulnerabilities are rarely the most exotic. They're the ones that are well-understood, well-documented, and still somehow present in production systems.

Understanding these vulnerability classes is not just about writing better code. It's about understanding the gap between code correctness and security — and recognising that a system can be entirely correct in doing what it was designed to do, while still being dangerously exploitable.

---

## The Central Insight: Vulnerabilities Exploit Trust

There is a throughline connecting most web application vulnerabilities that is worth stating explicitly before we get into the specifics.

Vulnerabilities work by exploiting existing trust.

SQL injection exploits the database's trust that the query it receives was written by the application, not by a user. Cross-site request forgery exploits a website's trust that a request carrying a user's session cookie was initiated by that user. Server-side request forgery exploits an internal network's trust that HTTP requests originating from a server are legitimate. Insecure direct object references exploit a system's design assumption that only authorised users would ever think to request a resource.

When you look at vulnerabilities through this lens, the mitigations become clearer. You're not just fixing code — you're identifying assumptions your system makes about trust, and ensuring those assumptions are explicitly verified rather than implicitly relied upon.

---

## Injection: When Data Becomes Instructions

Injection is the vulnerability class where the boundary between data and code breaks down. User-supplied input is interpreted as instructions rather than as data, and the attacker uses that to make the system do something it was never supposed to do.

SQL injection is the canonical example. Imagine a login form. The application takes the username you type and constructs a database query with it. If that construction is done by concatenating your input directly into the query string, a carefully crafted username can change the meaning of the query entirely. You can make it return all users. You can make it bypass the password check. You can make it execute arbitrary database commands.

The fix is always to use parameterised queries — a technique where the query structure is defined separately from the data, and the database engine handles the separation. When you use parameterised queries, there is no string concatenation, and therefore no way for user input to alter the structure of the query. The principle is the same for every injection variant: define the structure separately from the data, and use a mechanism that enforces that separation.

The same logic applies to command injection, where user input reaches a shell command. To template injection, where user input is evaluated by a templating engine. To log injection, where user input ends up in log output and triggers downstream processing. In every case, the root cause is the same: user-supplied data reached an interpreter without its structure being safely separated from the data being supplied.

One variant worth calling out specifically is second-order injection. This is where the payload is stored in the database and executed later, in a different context. The input validation applied at the time of writing may catch direct injection attempts. But if that stored value is later retrieved and used in a new query without the same protection, the injection succeeds at a different point in the application. This is why parameterised queries everywhere is a principle, not a suggestion.

---

## Broken Access Control: The Most Prevalent Failure

Broken access control has been ranked the number one web application security risk for several years running, and for good reason. It is extraordinarily common.

The most important sub-class is what's sometimes called insecure direct object reference — or IDOR. The pattern is simple: an application authenticates that a user is logged in, but fails to verify that the specific resource they're requesting belongs to them.

Peloton, the exercise equipment company, had APIs that leaked private user data because the authorisation model was binary: either you're authenticated or you're not. Once authenticated, you could request data for any user ID. The check was "are you logged in?" and the missing check was "are you allowed to access this specific user's data?"

This pattern is so common because it requires a specific mindset shift. Most developers think about authorisation as a binary condition — the user either has access to this feature or they don't. But the right model is: the user has access to their own data. Every request that retrieves, modifies, or deletes a specific record needs to verify ownership or permission at the record level, not just at the feature level. That check needs to be server-side. Client-side checks are user experience, not security.

A related failure is at the function level — administrative endpoints that have no check verifying the caller actually holds an administrative role. The URL for deleting a user account shouldn't be protected only by obscurity. It needs an explicit server-side check that the requesting user has the necessary privilege.

The principle that addresses both: default deny. Everything is forbidden unless explicitly permitted. Authorisation is granted, not assumed.

---

## Cryptographic Failures: The Wrong Kind of Cleverness

Cryptographic failures cover two distinct problems: failing to encrypt data that should be protected, and using encryption incorrectly.

The failure mode that appears most often in practice is not the absence of encryption — most teams know they need to use HTTPS. The more common failures are subtler. Passwords stored with fast hashing algorithms that are trivially reversible at scale. Encryption modes that are vulnerable to specific attacks — ECB mode leaks patterns, CBC mode without authentication is vulnerable to padding oracle attacks. Initialisation vectors reused with stream ciphers, which is catastrophic. Encryption keys hardcoded in source code.

The guiding principle that practitioners have converged on over decades of painful experience: don't invent your own cryptography. The intuition that a clever custom scheme might be more secure than a standard one is almost always wrong. Standard algorithms have been scrutinised by specialists for decades. A custom scheme designed in a week has not. Use audited libraries, established algorithms, and a proper secrets management system.

---

## CSRF and SSRF: Trust Weaponised

Cross-site request forgery and server-side request forgery are elegant attacks in the sense that they don't exploit bugs in code — they exploit architectural trust assumptions.

Cross-site request forgery works because browsers automatically include cookies with requests to a domain. If you're logged into your bank and you visit a malicious page, that page can cause your browser to make a request to your bank — and your browser will include your authentication cookies. The bank sees a request that appears to come from an authenticated session and processes it. The user never intended to make that request.

Server-side request forgery works because servers are often trusted to make HTTP requests to internal services. An attacker who can cause a server to make requests to an arbitrary URL can target internal services that are not publicly accessible. In cloud environments, this is particularly dangerous because cloud providers expose metadata services on internal IP addresses. An attacker who can reach those endpoints can retrieve credentials that grant access to the entire cloud account.

Both attacks work by making a trusted party — a browser or a server — make requests the user or system administrator never intended. The mitigations enforce that requests are only processed when they genuinely originate from the expected source.

---

## Outdated Components and the Patching Problem

The Equifax story has a sequel worth telling. Log4Shell, the critical vulnerability in the Log4j logging library discovered in late 2021, was present in thousands of applications. Some organisations discovered they were using the affected library by decompiling their own binaries — because there was no patch note released, and no internal inventory of what they depended on.

The organisations that patched quickly had software composition analysis tooling that told them exactly which services used Log4j and which version. The organisations that took weeks had no such inventory. They were flying blind.

This is why software composition analysis — automated tooling that scans your dependencies against databases of known vulnerabilities — is not optional. It needs to run daily, not just at build time. A library that was safe on Monday may have a disclosed critical vulnerability by Friday. You need to know that before your users do.

The same discipline applies to the reverse problem: releasing patches without disclosing vulnerability details. Metabase learned this the hard way. Security researchers decompiled their bytecode, found the fix, and reverse-engineered the vulnerability from it within days of the patch being released. Silence is not a security strategy.

---

## Thinking About Severity

When you find a vulnerability — in a code review, in a penetration test, in your own code — the question is always how serious it is. The answer depends on four things.

How exploitable is it? Does it require authentication? Can it be triggered remotely by any user? Is the attack complex or straightforward?

What is its scope? Does exploitation affect only the attacker's own account, or does it cross privilege boundaries and affect other users?

What is the impact? Does it compromise confidentiality, integrity, or availability — and to what degree?

How widespread is it? Is the vulnerable code path exercised rarely, or is it the main code path in the application?

The CVSS scoring system gives you a structured way to reason about these dimensions. But the most important thing it provides is not a number — it's a vocabulary for having the conversation. A vulnerability with a high CVSS score in a rarely-exercised endpoint may matter less than a moderate-severity issue in your main authentication flow.

---

## The Practical Takeaway

The vulnerability classes described here are not obscure. They are well-documented, well-understood, and consistently present in real applications because the conditions that produce them are easy to create and the mitigations require deliberate, consistent effort to apply.

Injection happens when developers don't think about the data-code boundary. Access control failures happen when the authorisation model is binary rather than resource-level. Cryptographic failures happen when developers reach for the first available implementation rather than the right one. Outdated components become vulnerabilities when there's no process for tracking what you depend on.

The common thread is that security requires asking specific questions at specific points in development. Not as an afterthought. Not as a compliance exercise. As a genuine part of building software that is worthy of the trust users place in it when they hand it their data.
