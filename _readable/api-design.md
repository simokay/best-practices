# Designing APIs That Last

An API is a contract. Unlike internal code that you can refactor freely, changing an API has external consequences: it breaks the developers who depend on it. A poorly designed API is one you will either be forced to maintain in its broken state indefinitely, or forced to break — costing the trust and time of everyone who built on it.

Good API design is therefore design for longevity. It means thinking carefully about who will use your API, what they will need to do with it, and — just as importantly — what they will need to do with it in the future, when requirements have changed in ways you cannot predict today.

The most common mistake in API design is designing for the provider rather than the consumer. An API that accurately reflects your internal data model, your database schema, or your system's internal organisation is easy for you to build. But the developer using your API has a different mental model, different terminology, and different goals. The API should meet them where they are.

---

## What REST Actually Means

REST — Representational State Transfer — is an architectural style derived from the principles that make the web scalable and resilient. Most APIs that call themselves REST do not fully implement it, which is not necessarily a problem, but understanding the constraints helps you make informed tradeoffs.

**Statelessness** means every request contains all the information needed to process it. The server holds no session state between requests. This enables horizontal scaling — any server can handle any request — and makes failure recovery straightforward.

**A uniform interface** means that the same vocabulary — the standard HTTP methods and status codes — applies to all resources. Clients learn one protocol and can use it universally, rather than learning a custom vocabulary for each API.

**Cacheability** means responses declare whether they can be cached. Caches at every layer — client, CDN, proxy — can eliminate redundant requests, reducing load and improving response time.

**A layered system** means clients do not know or care whether they are talking directly to the origin server or to an intermediary. Load balancers, caches, and gateways can be inserted transparently.

In practice, most HTTP APIs implement statelessness and a uniform interface. Full REST, including hypermedia navigation where responses include links to available next actions, is rarer and more complex to implement — and not always worth the investment.

---

## Modelling Resources

URLs should be nouns, not verbs. HTTP already provides verbs: GET, POST, PUT, PATCH, DELETE. Your URLs name the things being acted upon.

Collections are plural: slash-users. Individual items include an identifier: slash-users-slash-42. Nested resources reflect ownership: slash-users-slash-42-slash-orders. Only model nesting in the URL when the child resource only makes sense in the context of the parent. Resources with independent identities should have top-level endpoints. Deep nesting — more than two levels — produces URLs that are hard to read and difficult to work with.

Use the HTTP methods with their correct semantics. GET retrieves without side effects. POST creates or triggers non-idempotent operations. PUT replaces a resource completely — the client sends the full new representation. PATCH applies a partial update — the client sends only what changes. DELETE removes the resource. Idempotency matters: a GET, PUT, or DELETE can safely be retried without risk of unintended side effects; a POST cannot.

Use standard HTTP status codes. Never return a 200 success response containing an error in the body — this breaks every standard tool that treats HTTP status codes as meaningful, from monitoring systems to caches to load balancers. When an error occurs, use the appropriate 4xx code for client errors and 5xx for server errors. A 400 means the request was malformed. A 401 means authentication is required or failed. A 403 means the user is authenticated but not permitted. A 404 means the resource does not exist. A 429 means the client is being rate-limited.

---

## Error Responses, Pagination, and Filtering

Define a single error response format and use it consistently across your entire API. Include the HTTP status code, a human-readable message, a machine-readable error type, and enough detail for a developer to understand what went wrong and what to do about it.

Always paginate collections that may grow large, and design pagination in from the start — retrofitting it is a breaking change. Cursor-based pagination is more robust than page-and-offset pagination for datasets that change while the client is paginating through them.

Use consistent query parameter conventions for filtering, sorting, and searching. Whatever conventions you choose, apply them the same way across all endpoints so developers can predict how they work.

---

## Versioning

Versioning is an admission that you need to make a breaking change. Design to avoid breaking changes wherever possible, and be clear about what constitutes one.

Breaking changes include: removing or renaming a field in a response, changing a field's type, removing an endpoint, changing authentication requirements, and removing an enum value. Non-breaking changes include: adding new optional fields to responses, adding new endpoints, and adding new optional request parameters. Design clients to ignore fields they do not recognise — this makes adding new optional fields safely possible without a version bump.

When a major version is unavoidable, URL versioning — including the version number in the path — is the most common approach. It is visible, easy to route, and easy to document. Maintain old versions with a published deprecation timeline rather than removing them without notice.

---

## Authentication

Never build your own authentication protocol. Use established standards.

For delegated authorisation — allowing users to grant a third-party application access to their data without sharing their credentials — use OAuth 2.0 with OpenID Connect. For server-to-server authentication where delegated auth is unnecessary, API keys are appropriate: they should be long, random, stored as hashes on the server, and rotatable. JSON Web Tokens provide a stateless bearer token format; verify the signature on every request, validate the expiry and audience claims, and use short token lifetimes combined with refresh tokens.

Always use HTTPS. Credentials and tokens transmitted over plain HTTP are trivially interceptable.

---

## Designing for Change

The most important property of an API is its tolerance to change — the ability to evolve over time without breaking existing consumers.

Apply the robustness principle: be conservative in what you send and liberal in what you accept. Do not expose your internal data model directly; add an abstraction layer between your API and your implementation. This gives you the freedom to refactor internally without breaking the contract externally.

Consumer-driven contract testing formalises this: each consumer of your API defines the contract it expects, and the provider's CI pipeline runs those consumer contracts as tests. This catches breaking changes before deployment rather than after.

---

## Documentation

An API without documentation is unusable. Documentation is not a post-implementation chore — it is part of the design. Writing documentation forces you to think through how a developer will actually use each endpoint, which often reveals design problems that are otherwise invisible.

The OpenAPI Specification is the standard format for HTTP API documentation. It enables generating interactive documentation, client libraries, and server stubs. Design the specification before writing implementation code — the spec becomes the design artefact and the review document.

Every endpoint should document what it does, all parameters with their types and constraints, all possible response shapes, all possible error responses, authentication requirements, and rate limit behaviour.

---

## When to Use Alternatives

REST over HTTP is not always the right choice. For high-performance service-to-service communication where strong typing, efficient encoding, and streaming matter, gRPC — which uses Protocol Buffers over HTTP/2 — is worth considering. For frontends with diverse and variable data needs, GraphQL lets clients specify exactly what data they need, eliminating over-fetching and under-fetching at the cost of greater implementation complexity. Match the technology to the actual requirements rather than defaulting to one approach for everything.
