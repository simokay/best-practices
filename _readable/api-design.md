# Designing APIs That Last

An API is a promise. It's a commitment you make to every developer who builds on top of it — that the interface they learn today will still work tomorrow, that the contracts they rely on are stable, that the effort they invest in integrating with your system won't be wasted.

And like all promises, the worst thing you can do is break one without warning.

I want to spend some time on what that commitment actually means in practice, because API design is one of those disciplines where the decisions you make early have consequences that compound over years. Get it right and you build an ecosystem around your platform. Get it wrong and you face a choice between maintaining something broken indefinitely and breaking the trust of everyone who depends on you.

---

## What Stripe Understood That Most Teams Don't

Stripe is widely considered to have the best-designed payments API available. If you've worked with it, you probably have a sense of why. Things work the way you expect them to. Error messages tell you what went wrong and what to do about it. The documentation actually reflects the implementation.

But there's something specific about how Stripe operates that's worth understanding. They maintain a twenty-page internal API design document that every new endpoint must follow. They have cross-functional review teams for any proposed changes. And they've built several patterns into their API that look like small details but turn out to be enormously valuable.

Take their resource identifiers. A charge object has an ID that starts with "ch underscore." A customer has one starting with "cus underscore." An invoice with "in underscore." When you're debugging a production issue and you're looking at logs, you can tell at a glance what kind of object you're dealing with without looking anything up. This is a tiny design decision. Over the lifetime of a system that processes millions of transactions, it saves an enormous amount of time.

Or take idempotency keys. For operations like creating a charge, Stripe allows you to supply an idempotency key with your request. If your request times out — which happens — you can safely retry it with the same key, and Stripe will return the result of the original operation rather than charging the customer twice. The server deduplicates the request. This is not a complicated concept, but building it into the API from the start means that retry logic is safe by design.

These aren't incidental features. They reflect a design philosophy: the API is a product, and its users are developers, and everything flows from thinking deeply about their experience.

---

## The Pagination Trap

Let me give you a concrete example of what happens when you don't think about this.

You're building a new endpoint that returns a list of results. You test it with a handful of records during development. It's fast. It looks great. You ship it.

Six months later, you have real users. The largest of them has accumulated ten thousand records. Some of them have a hundred thousand. Your endpoint is now returning a hundred thousand records in a single response. Requests are timing out. Cloud bills are spiking. Users are seeing loading indicators that never resolve.

You now need to add pagination. But adding pagination to a live API endpoint is a breaking change. Clients that assumed they'd get all the records in one response will break when they only get a page. You have to version the endpoint, communicate the change to every consumer, and accept that some of them won't update for months.

This could have been avoided entirely by designing pagination in from day one, even when you only had five records. The cost of adding it early is minimal. The cost of adding it after the fact is enormous.

This is why experienced API designers think about the future state of their data from the beginning. What happens when there are ten times as many records? What happens when there are a thousand times as many? Design for that state, not for the state you're in today.

---

## REST: What the Constraints Actually Mean

REST — Representational State Transfer — is often talked about as a set of conventions for URLs and HTTP methods. But the original concept is more interesting than that. It's an architectural style derived from the principles that make the web itself scalable and resilient.

The constraint that matters most for everyday API design is statelessness. Every request must contain all the information needed to process it. The server holds no session state between requests. This sounds like a limitation, but it's actually the thing that makes horizontal scaling possible — any server can handle any request, because the request carries its own context. It's what makes fault tolerance straightforward — if a server fails mid-conversation, the client simply retries against another server.

The uniform interface constraint is what gives HTTP APIs their interoperability. Using the standard HTTP methods — GET for retrieval, POST for creation, PUT for full replacement, PATCH for partial update, DELETE for removal — means that standard tooling works against your API without modification. Proxies, caches, monitoring systems, load balancers — they all understand the semantics of these methods. If you invent your own verb system, you lose all of that.

Cacheability is a constraint that teams frequently ignore to their cost. Responses that declare themselves cacheable can be stored and served by CDNs, by browser caches, by reverse proxies. This eliminates redundant requests at scale. A properly cache-controlled GET response for a resource that changes infrequently can be served from a CDN edge node close to the user, with no request reaching your origin server at all.

---

## Naming, Structure, and the Grammar of Good URLs

URLs should be nouns, not verbs. HTTP already provides the verbs — GET, POST, PUT, DELETE. Your URLs name the things being acted upon, and the HTTP method says what to do to them.

This means "slash users slash forty-two" rather than "slash get-user question mark id equals forty-two." It means "POST slash orders" rather than "POST slash create-order." The grammar of URL plus HTTP method is already expressive enough to describe any operation. You don't need to add verbs to your URLs.

Use plural nouns for collections. "Slash users" is the collection. "Slash users slash forty-two" is an item in the collection. "Slash users slash forty-two slash orders" is the orders belonging to that user. This nesting should only go as deep as the ownership relationship justifies. Resources with independent identities should have top-level endpoints. Deep nesting produces URLs that are hard to read, hard to remember, and hard to document.

---

## HTTP Status Codes: The Silent Contract

Never return a 200 success response with an error in the body. I want to say that again because it's one of the most common API design mistakes I see, and it causes disproportionate problems downstream.

When you return 200 with an error body, you force every client to parse the response body before it can determine whether the request succeeded. You break standard monitoring systems that use HTTP status codes to detect failures. You break caches that treat 200 responses as cacheable. You break load balancers that make routing decisions based on response codes. You break every tool in the ecosystem that relies on the HTTP status code meaning what it's supposed to mean.

HTTP status codes exist precisely for this purpose. Use them. A 400 when the request is malformed. A 401 when the user needs to authenticate. A 403 when the user is authenticated but not permitted. A 404 when the resource doesn't exist. A 429 when the client is making too many requests. A 500 when something unexpected went wrong on your side.

---

## The Cost of Breaking Changes

I mentioned earlier that unmanaged API changes cause forty percent of integration failures and average fifteen to twenty hours per incident to remediate. Those are industry-wide statistics, and they're striking. But the more concerning figure is the tail risk.

In 2023, a healthcare organisation suffered a breach exposing four hundred and fifty thousand patient records. The entry point was a deprecated SOAP endpoint that had been forgotten when the team migrated to a newer REST API. The REST endpoints had security patches. The old SOAP endpoint did not. It had been running, unmonitored, for six months, because no one thought about it when they applied the patches.

Old API endpoints don't just become technical debt. They become security liabilities. They become regulatory exposure. The practice of maintaining a complete inventory of your API surface — knowing what exists, what it does, and what security policies apply to it — is not just good hygiene. In regulated industries, it's a necessity.

The organisations that handle API change management proactively — with versioning, with explicit deprecation timelines, with client communication — reduce update-related incidents by about seventy percent compared to those that manage it reactively. That's a massive difference for a practice that mostly consists of discipline and planning rather than technical investment.

---

## Design for Change

The most important property an API can have, over a long enough time horizon, is tolerance to change. Your API will need to evolve. Your data model will change. Requirements will change. New consumers will appear with needs you didn't anticipate.

The design principle that enables this is to keep your internal implementation separate from your external API. Your API is a contract with your consumers. Your data model is an implementation detail. When these are the same thing — when you expose your database schema directly as your API — every internal refactor risks breaking your consumers.

Add an abstraction layer. Design the API for your consumers, not for your implementation. Then you can refactor freely internally without touching the contract.

Apply the robustness principle: be conservative in what you send and liberal in what you accept. Consumers should tolerate new fields in responses — if they break when your API adds an optional field, they're too tightly coupled to your schema. Servers should tolerate requests with extra fields they don't understand. This gives both sides room to evolve independently.

Consumer-driven contract testing takes this further. Each consumer defines the contract it expects from your API. Your CI pipeline runs those consumer contracts as tests. This means you find out about breaking changes before deployment rather than after — when a consumer's integration test fails in your pipeline rather than when their application breaks in production.

---

## Documentation Is Part of the Design

I want to end with something that is often treated as an afterthought: documentation. An API without documentation is, practically speaking, unusable. Documentation is not what you write after you've built the API. It's part of designing the API.

Writing documentation forces you to think through how a developer will actually use each endpoint. It forces you to articulate what each parameter means, what each response field contains, what each error code indicates. This process consistently reveals design problems that are otherwise invisible — endpoints whose behaviour is unclear, error cases that aren't handled, parameter names that are ambiguous.

The OpenAPI Specification gives you a standard format for describing HTTP APIs. Write the spec before you write the implementation. Treat it as the design document. Run it through linting tools that check for consistency. Review it the way you review code. The specification, not the implementation, is the source of truth for what your API promises to do.

When a developer encounters your API, the documentation is their first experience of it. Make that experience reflect the care and thought you've put into everything else.
