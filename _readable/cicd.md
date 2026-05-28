# Continuous Integration and Delivery

Software that is not deployed is not delivering value. Every day a finished feature sits undeployed is a day of deferred benefit — and a day of accumulated risk, as more changes are made around it and the gap between what is working in development and what is running in production grows wider.

The goal of continuous integration and continuous delivery is to make the path from a developer's committed change to production as fast, reliable, safe, and reversible as possible.

---

## Continuous Integration

Continuous integration is a development practice, not a tool. Running a CI server does not make you doing continuous integration. The practice is this: every developer integrates their work with the main codebase at least once a day, and usually more often.

The reason this matters is that the cost of integration grows with the time since last integration. Two developers who have both been working for a week on separate branches will encounter more conflicts, more subtle incompatibilities, and more surprises when they finally merge than if they had integrated daily. Integrating frequently makes each integration small and low-risk.

The technical requirement for continuous integration is that a broken main branch is fixed within minutes, not hours. When a commit breaks the build or causes a test to fail, fixing it is the immediate priority for the team. A broken main branch means every other developer is working in an uncertain state.

Continuous integration requires **trunk-based development**: all developers integrate their work to the main branch, not to long-lived feature branches. Long-lived branches undermine the practice because they delay integration and accumulate divergence. Feature flags enable incomplete features to be shipped safely — the code is in production but the feature is disabled for users until it is ready.

---

## The Deployment Pipeline

A deployment pipeline is an automated implementation of your build, test, and release process. Every committed change passes through the same pipeline, in the same order, on the same infrastructure.

The critical principle is that you build the deployable artefact once and promote that same artefact through all subsequent stages. You never rebuild for each environment. What runs in staging is exactly what you will run in production — the only differences are configuration. Rebuilding from source for each environment introduces the possibility that what you tested is not what you deployed.

Structure the pipeline to fail fast. Run the quickest checks first: compilation, unit tests, and static analysis. Only if those pass should you run the slower integration tests. Only if those pass should you deploy to staging. This way, the most common failures are caught in the first few minutes rather than after a thirty-minute run.

Every pipeline failure is a priority. The team's goal is to have a releasable build at all times.

---

## Continuous Delivery vs Continuous Deployment

These are related but distinct.

**Continuous delivery** means that every commit that passes the pipeline could be deployed to production. The technical capability exists at all times. Whether and when to deploy is a business decision, not a technical one.

**Continuous deployment** means that every commit that passes the pipeline is automatically deployed to production. There is no human approval step before production. This is the approach used by high-trust teams with strong monitoring and fast rollback capabilities.

Most teams use continuous delivery: automatic deployment to staging, with a human gate before production. The value of continuous delivery is not necessarily that you deploy to production more often — it is that you could, at any point, which means your deployment process is practised, tested, and reliable rather than a stressful infrequent event.

---

## The Four Key Metrics

Research into software delivery performance has identified four metrics that distinguish high-performing teams from the rest.

**Deployment frequency** measures how often you deploy to production. Elite teams deploy on demand, multiple times per day.

**Lead time for changes** measures how long it takes for a committed change to reach production. Elite teams measure this in under an hour.

**Change failure rate** measures what percentage of deployments cause a production incident requiring remediation. Elite teams keep this below fifteen percent.

**Time to restore service** measures how long it takes to recover from a production incident. Elite teams recover in under an hour.

The most important finding from this research is that high deployment frequency does not correlate with higher failure rates. The teams that deploy most often also have the lowest failure rates. Speed and stability are not in tension — they are achieved together through good practices. Infrequent deployments do not reduce risk; they accumulate it.

---

## Deployment Strategies

Different strategies for releasing new versions balance speed, risk, and rollback capability differently.

**Blue-green deployment** maintains two identical production environments. You deploy the new version to the inactive environment, test it, then switch the load balancer. Rollback is instantaneous — switch back. The cost is running twice the infrastructure during the transition.

**Canary deployment** routes a small percentage of production traffic — perhaps one or five percent — to the new version while the majority continues to use the old version. You monitor error rates and latency. If the new version behaves well, you gradually increase the percentage. The blast radius of a problem is limited to the canary fraction. The complexity is that both versions run simultaneously and must be compatible.

**Feature flags** decouple deployment from release. Code is deployed to all servers but a feature is only enabled for a subset of users — internal employees first, then a small percentage of external users, then everyone. This gives you a granular, instant kill switch. The cost is the complexity of maintaining flags in the code, which must be cleaned up once a feature is stable.

**Rolling deployment** replaces instances one at a time or in batches. Simple to implement, but rollback is slow, and old and new versions serve traffic simultaneously during the rollout.

---

## Infrastructure as Code

Every configuration decision about how your infrastructure is provisioned and configured should exist in version-controlled code, not in manual console operations. This makes environments reproducible, auditable, and consistent.

Infrastructure as code enables the same practices that make application code trustworthy: code review, automated testing, version history, and rollback. A manually configured server is a liability — it cannot be reliably reproduced, and differences between environments are invisible until they cause problems.

**GitOps** extends this further: the Git repository is the single source of truth for both application and infrastructure state. Changes are proposed as pull requests. A controller continuously reconciles the running state with the declared state in the repository.

---

## Secrets Management

Secrets — passwords, API keys, tokens, certificates, private keys — must not appear in version control. Not in application code, not in configuration files, not in commit history.

The standard approach is to load secrets from environment variables at runtime, with those values injected by a secrets management system. Secrets should be rotated regularly. Access to secrets should be audited. Anomalous access patterns should trigger alerts. Use short-lived credentials where the platform supports it, eliminating the risk of long-lived credentials being leaked.

---

## Testing Strategy

The test pyramid describes the right proportion of test types for a healthy CI pipeline. Unit tests — fast, isolated, with no external dependencies — should be the most numerous. Integration tests, which involve real external dependencies, should be fewer and slower. End-to-end tests, which exercise the whole stack, should be few and reserved for the most critical flows.

Inverting the pyramid — many end-to-end tests, few unit tests — produces pipelines that are slow, brittle, and difficult to maintain. Test failures in end-to-end tests are hard to diagnose. A test suite that takes ninety minutes to run does not provide fast feedback.

**Flaky tests** — tests that pass and fail intermittently without code changes — are a serious problem. Once a team learns that some tests sometimes fail for no reason, they start ignoring test failures. Quarantine flaky tests immediately and fix or delete them promptly.

---

## Common Anti-Patterns

**The nightly build** runs once a day. This means bugs can go undetected for hours. Developers find out about failures the next morning, far from the code that caused them. This is not continuous integration.

**Long-lived feature branches** accumulate divergence. The longer a branch lives, the harder it is to merge. The integration tax is paid all at once rather than continuously.

**Manual approvals for every deploy** eliminate the speed benefits of automation. The value of automated pipelines is wasted if every stage requires a human approval. Reserve gates for the final production promotion.

**Siloed testing** — where testing is the responsibility of a separate QA team rather than the developers writing the code — produces tests that do not reflect what developers care about. Testing is a development activity.
