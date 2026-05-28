---
title: API Design Best Practices
nav_order: 7
---

# API Design Best Practices

> Synthesized from **Roy Fielding** (REST dissertation, Apache co-founder), **Mike Amundsen** (Building Hypermedia APIs, API designer), **Sam Newman** (Building Microservices, Monolith to Microservices), **Arnaud Lauret** (The Design of Web APIs, API Handyman), **Martin Fowler** (Enterprise Integration Patterns, REST API patterns), and **Google's API Design Guide** (Guides API design at Google scale).

---

## First Principles: What Is an API For?

Arnaud Lauret opens *The Design of Web APIs* with the observation that most API usability problems stem from designing for *providers* rather than *consumers*. An API is a product. Its users are developers. Everything else follows from that.

Roy Fielding's 2000 doctoral dissertation gave us REST — Representational State Transfer — as an *architectural style* derived from the constraints that make the web scalable and resilient. Most "REST APIs" violate one or more of Fielding's constraints. Understanding why those constraints exist helps you make informed tradeoffs.

---

## REST Constraints (Fielding)

Fielding defined six constraints. An architecture satisfying all six is RESTful:

1. **Client-Server**: Separation of concerns. The UI and data storage are independent; either can evolve separately.
2. **Stateless**: Every request must contain all information needed to process it. No server-side session state between requests. Enables horizontal scaling and fault tolerance.
3. **Cacheable**: Responses must declare whether they are cacheable. Caching eliminates redundant requests, improves scalability.
4. **Uniform Interface**: The central constraint. Four sub-constraints:
   - Resource identification in requests (URIs identify resources)
   - Resource manipulation through representations (clients manipulate resources through representations, not direct access)
   - Self-descriptive messages (each message includes information about how to process it)
   - Hypermedia as the engine of application state (HATEOAS — responses include links to next possible actions)
5. **Layered System**: Clients cannot tell whether they're connected directly to the origin server or to an intermediary (proxy, gateway, CDN).
6. **Code on Demand** (optional): Servers can extend client functionality by transferring executable code (e.g., JavaScript).

**Fielding's frustration** (2008 blog post): "I am getting frustrated by the number of people calling any HTTP-based interface a REST API." Without hypermedia (HATEOAS), it is an HTTP API, not a REST API. Most APIs in practice are HTTP APIs. That is not necessarily wrong — but be honest about it.

---

## Resource Modeling

### Nouns, Not Verbs

HTTP already has verbs (GET, POST, PUT, PATCH, DELETE). Your URLs should be nouns.

```
# Wrong: verb-based URLs
GET /getUser?id=42
POST /createOrder
POST /deleteProduct/17

# Correct: noun-based resources
GET /users/42
POST /orders
DELETE /products/17
```

### Plural Nouns for Collections

```
/users         → collection of users
/users/42      → specific user
/users/42/orders  → orders belonging to user 42
/orders/17        → specific order (also accessible directly)
```

### Hierarchy Reflects Ownership, Not Schemas

Only model parent-child hierarchy in the URL if the child resource only makes sense in the context of the parent. Resources with independent identities should have top-level endpoints.

```
# Good: an article's comments only exist in context of the article
GET /articles/8/comments

# Questionable: orders have independent identities; deep nesting isn't necessary
GET /users/42/orders/17/items/3  ← prefer GET /order-items/3
```

Google's API Design Guide recommends limiting nesting depth to two levels.

---

## HTTP Methods

| Method | Semantics | Idempotent | Safe |
|---|---|---|---|
| GET | Retrieve | Yes | Yes |
| HEAD | Retrieve headers only | Yes | Yes |
| POST | Create / non-idempotent action | No | No |
| PUT | Replace (full update) | Yes | No |
| PATCH | Partial update | No (by default) | No |
| DELETE | Delete | Yes | No |
| OPTIONS | Describe capabilities | Yes | Yes |

**Idempotent** = repeated identical requests have the same effect as a single request.
**Safe** = no side effects; can be cached, prefetched, retried freely.

**PUT vs PATCH**: Use PUT for full replacement (client sends the complete new representation). Use PATCH for partial updates (client sends only the fields to change). PATCH requires care: define the patch format (JSON Merge Patch — RFC 7396, or JSON Patch — RFC 6902).

---

## HTTP Status Codes

Don't invent a custom error system. HTTP status codes exist for this purpose.

**2xx — Success:**
- `200 OK` — general success
- `201 Created` — resource created; include `Location` header pointing to new resource
- `202 Accepted` — async operation accepted, not yet complete
- `204 No Content` — success with no response body (common for DELETE)

**3xx — Redirection:**
- `301 Moved Permanently` — permanent URL change; update your links
- `304 Not Modified` — conditional GET; cached version is still valid

**4xx — Client Error:**
- `400 Bad Request` — malformed syntax, validation failure
- `401 Unauthorized` — authentication required or failed
- `403 Forbidden` — authenticated but not authorized
- `404 Not Found` — resource does not exist
- `405 Method Not Allowed` — HTTP method not supported on this resource
- `409 Conflict` — state conflict (e.g., duplicate creation, optimistic concurrency failure)
- `410 Gone` — resource permanently removed (prefer over 404 for deleted resources)
- `422 Unprocessable Entity` — valid syntax, but semantic errors (e.g., validation failures)
- `429 Too Many Requests` — rate limiting; include `Retry-After` header

**5xx — Server Error:**
- `500 Internal Server Error` — unexpected server-side failure
- `502 Bad Gateway` — upstream service error
- `503 Service Unavailable` — temporary overload; include `Retry-After`
- `504 Gateway Timeout` — upstream service timeout

**Never return `200 OK` with an error in the body.** This forces clients to parse the body to determine success — breaking standard HTTP tooling (caches, proxies, monitoring).

---

## Request and Response Design

### Consistent Error Format

Define a single error response schema and use it everywhere. Google's convention:

```json
{
  "error": {
    "code": 404,
    "message": "User not found",
    "status": "NOT_FOUND",
    "details": [
      {
        "type": "ResourceNotFound",
        "resourceType": "User",
        "resourceId": "42"
      }
    ]
  }
}
```

RFC 7807 (Problem Details for HTTP APIs) provides a standard format:

```json
{
  "type": "https://example.com/problems/insufficient-funds",
  "title": "Insufficient Funds",
  "status": 400,
  "detail": "Your account balance is $10.00. The transfer amount is $50.00.",
  "instance": "/transactions/abc123"
}
```

### Pagination

For collections that may grow large, always paginate from day one.

**Cursor-based pagination** (preferred for large/changing datasets):
```json
{
  "data": [...],
  "pagination": {
    "cursor": "eyJpZCI6MTAwfQ==",
    "has_more": true
  }
}
```
Cursor-based pagination is stable when items are inserted/deleted between pages. Offset-based pagination (`?page=3&per_page=20`) is simpler but unstable under writes.

**Link headers** (RFC 5988):
```
Link: <https://api.example.com/users?cursor=abc>; rel="next",
      <https://api.example.com/users?cursor=xyz>; rel="prev"
```

### Filtering, Sorting, Searching

Consistent query parameter conventions:
```
GET /products?category=electronics&min_price=100
GET /users?sort=-created_at           # minus prefix = descending
GET /articles?q=kubernetes            # full-text search
GET /events?fields=id,name,date       # field selection / sparse fieldsets
```

---

## Versioning

Arnaud Lauret and Sam Newman both emphasize: **avoid breaking changes** wherever possible. Versioning is the admission that you failed to avoid one.

**Strategies:**

**URL versioning** (`/v1/users`, `/v2/users`): Most common, highly visible, easy to route. Downside: forces clients to update URLs on major versions; old versions must be maintained.

**Header versioning** (`Accept: application/vnd.example.v2+json`): Cleaner URLs, but harder to test in browsers; less discoverable.

**Query parameter** (`?version=2`): Easy to test but considered inelegant; not cacheable by default.

**Google's recommendation**: URL versioning for major versions. Never break compatibility within a version.

### What Constitutes a Breaking Change
- Removing or renaming a field in a response
- Changing a field's type
- Removing an endpoint
- Changing authentication requirements
- Changing query parameter semantics
- Removing an enum value

### Non-Breaking Changes (safe to ship without a version bump)
- Adding new optional fields to responses
- Adding new endpoints
- Adding new optional request parameters
- Adding new enum values (but clients must handle unknown values gracefully)

---

## Authentication and Authorization

**Never roll your own auth.** Use standard protocols.

- **OAuth 2.0 + OIDC**: The standard for delegated authorization and federated identity. Use PKCE for public clients (SPAs, mobile apps).
- **API Keys**: For server-to-server authentication where OAuth is overkill. Keys should be long (32+ bytes), random, stored hashed server-side, and rotatable.
- **JWT (JSON Web Tokens)**: Stateless bearer tokens. Verify signature always; validate `exp`, `iss`, `aud` claims. Use short expiry + refresh tokens. Prefer RS256 or ES256 over HS256 for multi-service architectures.

**Always use HTTPS.** Never transmit credentials or tokens over HTTP.

---

## API Design for Change (Sam Newman)

From *Building Microservices*: the most important property of an API is **tolerance to change**. Design for extensibility:

- **Postel's Law (Robustness Principle)**: "Be conservative in what you send, liberal in what you accept." Clients should ignore unknown fields in responses (don't break on new fields). Servers should accept requests with extra fields.
- **Avoid tight coupling**: Don't expose your internal data model directly. Add an abstraction layer — the API is a contract, not a database view.
- **Consumer-Driven Contract Testing** (Pact): Define the contract from the consumer's perspective. Run the consumer's test suite against the provider. Catches breaking changes before deployment.

---

## Documentation

An undocumented API is an unusable API. Arnaud Lauret: documentation is not a post-implementation chore; it is part of design.

**OpenAPI / Swagger (OAS 3.x)**: The standard for HTTP API documentation. Generates interactive documentation (Swagger UI, Redoc), client SDKs, and server stubs.

Minimum documentation per endpoint:
- Description of what the endpoint does
- All parameters with types, constraints, and examples
- All possible response schemas with examples
- All possible error responses
- Authentication requirements
- Rate limit behavior

**Design-first vs. code-first**: Design the OpenAPI spec before writing implementation code. The spec *is* the design review artifact. Use tools like Spectral to lint the spec for consistency.

---

## Performance and Reliability Considerations

**Rate limiting**: Every public API must have rate limits. Return `429 Too Many Requests` with a `Retry-After` header. Expose limits in response headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`).

**Idempotency keys**: For non-idempotent operations (payments, order creation), allow clients to supply an idempotency key (`Idempotency-Key: <uuid>`). Server deduplicates requests with the same key. Stripe's API pioneered this pattern.

**Timeouts**: Document and enforce server-side timeouts. Never let a request hang indefinitely. Return `504` after timeout rather than waiting forever.

**Bulk operations**: For batch processing, expose a bulk endpoint (`POST /users/batch`) rather than forcing N sequential calls. LinkedIn's API team found that N+1 API patterns were the #1 latency problem for clients.

**Conditional requests**: Support `ETag` / `Last-Modified` and `If-None-Match` / `If-Modified-Since` for efficient caching of individual resources.

---

## gRPC and GraphQL as Alternatives

**gRPC** (Google): Protocol Buffers + HTTP/2. Strong typing, bidirectional streaming, efficient binary encoding. Best for internal service-to-service communication where performance and type safety matter more than human readability.

**GraphQL** (Facebook): Clients specify exactly what data they need. Eliminates over-fetching and under-fetching. Higher implementation complexity; caching is harder; requires thoughtful security (query depth limiting, cost analysis). Best for flexible client needs with diverse consumers (BFF — Backend for Frontend pattern).

**Choosing:**
- Public API with diverse, unknown consumers: REST/HTTP API
- Internal microservices: gRPC or REST
- Mobile/web frontend with diverse data needs: GraphQL (via BFF)
- Real-time or streaming: gRPC streaming, WebSockets, or Server-Sent Events

---

## Key References

- Fielding, R.T. (2000). *Architectural Styles and the Design of Network-based Software Architectures* (PhD dissertation). UC Irvine.
- Lauret, A. (2019). *The Design of Web APIs*. Manning.
- Newman, S. (2021). *Building Microservices* (2nd ed.). O'Reilly.
- Amundsen, M. (2011). *Building Hypermedia APIs with HTML5 and Node*. O'Reilly.
- Google API Design Guide: https://cloud.google.com/apis/design
- RFC 7807 — Problem Details for HTTP APIs
- RFC 5988 — Web Linking (Link headers)
- Stripe API Design: https://stripe.com/docs/api (widely cited as exemplary)
