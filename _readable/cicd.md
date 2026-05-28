# Continuous Integration and Delivery

Charity Majors, one of the most incisive voices in the industry on operational practices, has a way of framing the cost of infrequent deployment that I find clarifying. She asks: how much is your fear of deployments costing you?

Because here's the thing. When deployments are scary, teams do them less often. When they do them less often, more changes accumulate. When more changes accumulate, each deployment becomes a bigger, riskier event. When each deployment is a bigger, riskier event, teams get more scared of deploying. And you end up paying a compounding interest rate on your fear in the form of slower delivery, more stressful releases, and — paradoxically — more production incidents.

The solution, which is counterintuitive until you live it, is to deploy more often. Not less. The teams with the highest deployment frequency consistently have the lowest incident rates. The relationship between speed and stability isn't a trade-off. It's a correlation. Get fast enough and safe enough at the same time.

---

## What the Evidence Shows

Let me give you some concrete data points.

HubSpot deploys two hundred to three hundred times per day across eighty-five engineers. That's an average of four deployments per engineer, per day. Monzo — the digital bank — deploys to production over a hundred times a day. Hunter.io, a smaller company, reaches twenty deploys daily, and describes the process as essentially invisible. It happens in the background, automatically, and engineers rarely think about it.

These are not outliers from some special category of organisation with unlimited resources and unique technology. They're ordinary engineering teams that decided to take deployment seriously and built the practices and infrastructure to support it.

At the other end of the spectrum, I want to tell you about OpsRamp, because their transformation story is instructive. They were running quarterly waterfall-style releases. Thirty people in a change management meeting every Wednesday, coordinating twelve codebases. Eight-day advance tickets for any change request. Risk committees pre-approving releases. Sound familiar? TrueCar had similar ceremonies.

Both companies described these rituals not as safety measures, but as security theatre — the performance of control without the substance of it. The thirty-person meeting didn't catch bugs. It slowed everything down while giving people the feeling of oversight without the reality.

When both organisations moved to continuous delivery, the outcomes were measurable. Up to thirty percent faster time to market. Fifty percent fewer defects. A two hundred percent increase in deployment frequency.

---

## What Continuous Integration Actually Means

I want to be precise about what continuous integration is, because the term is used loosely in ways that obscure what makes it valuable.

Continuous integration is not "running a CI server." GitHub Actions doesn't make you CI-compliant. Jenkins doesn't make you CI-compliant. The practice of continuous integration is this: every developer integrates their work with the main codebase at least once a day, and usually more often.

Why does the frequency matter? Because the cost of integration grows with the time since last integration. Two developers who have been working on separate branches for two weeks will encounter more conflicts, more subtle incompatibilities, and more surprises when they merge than if they had integrated daily. Each day of isolation accumulates divergence. Integration done daily is a small, routine event. Integration done monthly is a project.

The technical contract for continuous integration is that the main branch is always in a releasable state. A broken build is fixed within minutes, not hours. When someone breaks the build, fixing it is the immediate priority for the team. While the build is broken, everyone is working in an uncertain state.

Continuous integration requires trunk-based development — all developers integrating to the main branch, not to long-lived feature branches. Feature branches that live for weeks or months are the opposite of continuous integration. They accumulate exactly the kind of divergence that CI is designed to prevent.

Feature flags solve the obvious objection: what about features that aren't ready to ship? The answer is that code and features are different things. You can deploy code that implements an incomplete feature as long as the feature itself is toggled off for users. The code ships. The feature doesn't. When the feature is ready, you flip the flag. This is how you get the integration benefits of trunk-based development without shipping half-finished work to users.

---

## The Pipeline as a Concept

A deployment pipeline is the automated implementation of your build, deploy, test, and release process. Every committed change passes through the same pipeline, in the same order, on the same infrastructure.

There's a principle here that's worth stating explicitly: you build the deployable artefact once, and you promote that exact artefact through every subsequent stage. You don't rebuild from source for each environment. What runs in staging is exactly what runs in production. The only difference is configuration. If you rebuild for each environment, you introduce the possibility that what you tested is not what you deployed.

The pipeline should be structured to fail fast. The fastest checks run first. Compilation, unit tests, linting — these take seconds or minutes and catch the most common failures. They run before the slower integration tests. Integration tests run before the performance tests. Performance tests run before deployment. The principle is that you find out about problems as early as possible, at the lowest cost.

When a pipeline fails, it is a priority. Not "someone will look at it this afternoon." A priority. A broken pipeline means every subsequent commit is piling up behind a broken state, and every developer working on the codebase is working in an uncertain environment.

---

## The Four Metrics That Tell You How You're Doing

Research into software delivery performance has produced a remarkably clean set of four metrics that distinguish high-performing teams from the rest.

Deployment frequency measures how often you ship to production. Lead time for changes measures how long it takes from a commit being made to it running in production. Change failure rate measures what percentage of deployments cause a production incident. And time to restore service measures how quickly you recover when something goes wrong.

The finding that surprises most people is that these metrics are not in tension. Teams that score well on deployment frequency also score well on change failure rate and time to restore service. The teams shipping the most often are also the teams with the fewest production incidents, and the fastest recovery times.

The explanation is that frequent, small deployments are easier to reason about when something goes wrong. If you deploy once a quarter and something breaks, diagnosing the problem means sifting through three months of changes. If you deploy multiple times a day, the change set is small and the cause is usually obvious.

---

## Deployment Strategies: Managing Risk in Production

Different deployment strategies balance the trade-offs between speed, risk, and rollback capability.

Blue-green deployment maintains two identical production environments. You deploy the new version to the inactive environment, run your post-deployment checks, and then switch the load balancer. Rollback is instantaneous — you switch the load balancer back. The cost is running twice the infrastructure during each deployment.

Canary deployment routes a small fraction of production traffic — say one or five percent — to the new version while the majority continues to hit the old version. You monitor error rates and latency. If the new version looks healthy, you gradually increase the percentage. If it looks unhealthy, you roll it back quickly, having limited the blast radius to a small portion of users. The complexity is that both versions run simultaneously and must be API-compatible.

Feature flags take a different approach entirely. The code is deployed everywhere, but the feature is only enabled for a specified subset of users — internal employees first, then a small percentage of external users, then everyone. This gives you a per-user kill switch that can be activated instantly if something goes wrong. It also decouples your deployment schedule from your release schedule, which is powerful.

Rolling deployment replaces instances progressively, one at a time or in batches. It's simple — no extra infrastructure, no switching. But rollback is slow, and during the deployment you have old and new versions running simultaneously.

---

## Infrastructure as Code and the Snowflake Problem

There is a type of production server that practitioners sometimes call a "snowflake." It's a server that has been configured manually over time, accumulating small tweaks and changes that were never recorded anywhere. Nobody knows exactly what's on it. It can't be reliably reproduced. When you try to spin up a new instance, something is always slightly different.

Snowflake servers are a deployment reliability problem. They're also a security problem — because if you can't reproduce the server configuration, you can't audit it. And they're a team knowledge problem, because the configuration exists only in the memory of whoever has been maintaining the server.

The solution is to define all infrastructure in code, version-controlled, deployed through the same pipeline as application code. Every configuration decision becomes auditable, reviewable, and reproducible. Infrastructure becomes deterministic — you can spin up an identical environment from scratch. Changes go through review. Drift between environments becomes visible.

This principle extends to secrets management. Passwords, API keys, tokens, private keys — none of these belong in version-controlled configuration files. They belong in a secrets management system, injected at runtime, with access audited and credentials rotatable.

---

## The Cultural Dimension

Something that the transformation stories consistently emphasise is that CI/CD is not primarily a technical problem. OpsRamp and TrueCar didn't fail to do continuous delivery because they lacked the tooling. They did it because of organisational culture — change management rituals, approval processes, a model of stability that equated infrequency of deployment with safety.

The practices that enable cultural change in CI/CD environments have a consistent pattern. Blameless post-mortems — when something goes wrong, the goal is to understand the system failure, not to find someone to blame. Without psychological safety, engineers don't take the risks that fast delivery requires.

Testing as a development activity, not a QA silo. If developers don't own the tests, the tests don't reflect what developers care about. A test suite that no one trusts is worse than no test suite, because it gives false confidence while failing to catch real problems.

And the consistent elimination of manual gates. Approval processes that require human sign-off at every stage don't make deployments safer. They make deployments slower and more stressful, which increases the pressure to batch changes, which makes each deployment bigger and riskier. Automate everything that can be automated. Reserve human judgement for the decisions that genuinely require it.

The goal is to make deployment so routine, so fast, and so reversible that it stops being a notable event. When deployment is invisible, the fear goes away. And when the fear goes away, you can focus on building things that matter.
