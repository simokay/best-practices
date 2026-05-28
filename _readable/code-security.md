# Building Security Into Your Code

Let me start with a number. Sixty-two percent. That's the proportion of security breaches that stem from code-level flaws — mistakes made during development that were entirely preventable with the right practices. Not sophisticated nation-state attacks. Not zero-day exploits. Ordinary, documented, well-understood vulnerabilities that shipped in production because security wasn't part of the development process.

Here's the thing that this number should make clear: security is not a specialisation you bolt on at the end. It is a discipline you build into every step. And when you understand that, everything else about how you approach it changes.

---

## The Cost of Getting It Wrong, and When You Pay It

There is a well-established principle in software development that the cost of fixing a defect increases the later it is discovered. A problem found during design costs almost nothing to address — you change a diagram, you reconsider an approach. A problem found in code review costs a bit more — you rewrite a function, you refactor a module. A problem found in testing costs more still. And a problem found in production? You're not just paying in engineering time. You're paying in user data, in regulatory fines, in reputation, in trust.

For security vulnerabilities, this cost curve is even steeper. A vulnerability found after deployment means that data may already be exfiltrated. Users may already be affected. The disclosure process, the incident response, the audit — these are enormously expensive events.

This is why the most important shift you can make in how you think about security is to move it earlier. Not as a gate before deployment. Not as a checklist before launch. Earlier than that. Into the design. Into the pull request. Into the conversation between engineers.

---

## The Postman Problem, and What It Teaches Us

Postman — the API platform — ran into a problem that many engineering teams will recognise. Their security team was a bottleneck. Changes were flowing through development, getting built, getting tested, and then, at the staging gate, security was finally involved. And at that point, architectural decisions were locked in. The cost of addressing a security concern at that stage was enormous — sometimes requiring a full rearchitecture of something already built.

Their solution was elegant in its simplicity. They moved security questions upstream to the pull request stage. Specific, focused questions about implementation details rather than broad design reviews. They started asking: how does this handle authentication? Where does user input flow? What happens if this request is malformed?

The result was that security became part of the conversation during development rather than a verdict delivered after it. And critically — and this surprises people — it actually made things faster. Because a security concern raised at the PR stage takes hours to fix. The same concern raised at the staging gate takes weeks.

---

## Threat Modelling: Think Like an Attacker Before You Write a Line

The most effective security investment you can make is threat modelling — the practice of systematically asking, before you write code, what could go wrong.

The way to do it is to draw a map of your system. Every component. Every place data flows between components. Every trust boundary — every place where data crosses between different privilege levels, different network zones, different processes. Then you work through that map and ask: what could an attacker do here?

There's a useful framework called STRIDE that gives you six categories of threat to work through. Spoofing — can someone pretend to be someone else? Tampering — can someone modify data in transit or at rest? Repudiation — can someone perform an action and then deny it? Information disclosure — can data reach someone it shouldn't? Denial of service — can someone make the system unavailable? And elevation of privilege — can someone access capabilities beyond their authorisation?

Working through these categories systematically surfaces a different class of problem than code review alone. Code review finds implementation bugs. Threat modelling finds design flaws. And design flaws are far more expensive to fix after the fact.

The output of a threat model is a set of mitigations — one for each identified threat. Document them before you begin implementation. This creates a record of your security decisions that is invaluable for future reviews, and it means that the security properties of your design are explicit rather than implicit.

---

## Static Analysis: Reading Code For Vulnerabilities

Once you're writing code, there are two approaches to finding security problems without executing it: manual review and automated tooling.

Manual review should be risk-based. Not every line of code carries the same security risk, and trying to review everything with equal scrutiny is neither feasible nor effective. The places worth focusing your attention are the places where security failures are most consequential. Authentication and authorisation logic. Cryptographic operations. Anywhere user input enters the system. Serialisation and deserialisation handlers. Any place where privilege levels change.

When you review manually, you can come at it from two directions. Working top-down means starting at entry points — every HTTP endpoint, every message queue consumer, every CLI argument — and following data inward, asking at each step whether it's validated before use. Working bottom-up means starting at the most dangerous functions — the places where the code makes database queries, executes shell commands, renders HTML, or deserialises data — and tracing backwards to find where their arguments come from.

One of the most consistent findings across security practitioners is that reviewers confuse authentication with authorisation. Authentication is verifying who someone is. Authorisation is verifying what they're allowed to do. They are separate concerns, and they require separate checks. Teams get authentication right but then assume that any authenticated user can access any resource. This assumption is wrong, and the vulnerabilities it produces are among the most common and most exploited in real applications.

Automated static analysis tools run quickly and catch patterns humans miss — especially when humans are tired, rushed, or distracted. The rules for using them effectively are simple. Integrate them into your CI pipeline so no new findings can be introduced silently. Fix all high-confidence, high-severity findings before merging. And take false positives seriously — if the tool alerts on too many non-issues, engineers learn to ignore it, and then it catches nothing.

---

## The New Problem: AI-Generated Code

There's a dimension to security review that has emerged in the last few years and is worth addressing directly. AI-assisted code generation is now a routine part of how many engineers work. The tools are genuinely useful. And they introduce a new class of security risk.

AI-generated code doesn't consider security implications. It generates plausible, syntactically correct, often functionally correct code. But it may contain SQL injection vulnerabilities. It may contain authentication bypasses. It may handle secrets incorrectly. And because the code looks clean and well-structured, reviewers trained to scan for common patterns may miss problems that a more careful reading would catch.

The practical implication is that AI-generated code needs more scrutiny, not less. Review it with the same rigour you'd apply to code from a junior engineer on their first day. Treat it as output that needs validation, not as a trusted source.

---

## What To Actually Look For: The Practical Checklist

Let me walk through the areas that warrant the most attention in any security review.

For authentication, passwords must be stored using a slow hashing algorithm designed specifically for the purpose — Argon2, bcrypt, or scrypt. Fast hashing algorithms like SHA-256 are intended for data integrity, not password storage. Modern hardware can test billions of SHA-256 hashes per second. Login endpoints must be rate-limited. Session tokens must be invalidated on the server when a user logs out — deleting a cookie is not the same thing.

For authorisation, the check you need is not just "is this user logged in?" but "is this specific user allowed to access this specific resource?" These are different questions. The first is authentication. The second is object-level authorisation, and it's where the majority of access control vulnerabilities occur. Every request that accesses a specific record — an order, an invoice, a user profile — must verify that the requesting user owns or has permission to access that record.

For input handling, the rule is simple: all external input is untrusted, regardless of where it appears to come from. Database queries must use parameterised statements. HTML output must escape user-controlled values. File paths must be validated to prevent directory traversal. Never pass user input directly to a shell command.

For cryptography, use established, audited libraries and algorithms. Don't invent your own cryptographic systems. The principle here is not that custom solutions are necessarily weak — it's that standard solutions have been scrutinised by specialists looking for flaws for decades, and a custom solution designed in an afternoon has not.

For dependencies, run automated scanning as part of your CI pipeline. A vulnerability in a library you depend on is a vulnerability in your application. New vulnerabilities are disclosed continuously. Checking once at build time is not sufficient.

---

## Shifting Security Left: Making It Continuous

The phrase "shifting left" refers to moving security earlier in the development timeline — towards the left of a timeline that runs from design on the left to production on the right. The goal is to catch problems at the point where they're cheapest to fix.

In practice this means: secret detection tools that scan staged changes before every commit. Static analysis that runs automatically on every pull request. Security-sensitive code paths — authentication, payment processing, data export — that require a reviewer with security knowledge as a mandatory approver.

It means dependency vulnerability scanning that runs daily, not just at build time, because new CVEs are published every day.

It means, when something does get through to production, a process for writing a clear vulnerability report — one that includes the exact location in the code, a severity assessment, the specific steps to reproduce it, and a concrete actionable fix. Not "sanitise inputs" as a remediation. Something specific: "use a parameterised query in this function, passing the user ID as a bound parameter rather than concatenating it into the query string."

Security is not a discipline that can be done once and considered complete. It requires continuous attention because the threats evolve, because dependencies change, because new code is written every day. But embedded into your development process — into your pull requests, your pipeline, your review culture — it stops being a burden and becomes part of how good software is built.
