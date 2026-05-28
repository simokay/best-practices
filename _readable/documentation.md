# Writing Documentation That Actually Works

Let me start with a scenario that will be familiar to many of you.

An engineer has been at a company for four years. They built a critical piece of infrastructure. They know exactly how it works — the edge cases, the configuration quirks, the reason a particular design decision was made three years ago. And then they leave. Or they're promoted. Or they're pulled onto a different project.

And suddenly that knowledge is gone. Not in some abstract, recoverable sense. Gone. The documentation was either never written, or written at the time and never updated, or written in a way that only made sense to the person who already knew the system. New engineers spend weeks reverse-engineering something that should have taken hours to understand. They make changes that break things for reasons nobody can explain.

This is the knowledge silo problem, and documentation is the only way to solve it. But most documentation fails. Not because engineers don't know their subject matter — they know it very well. It fails for a more interesting reason.

---

## The Curse of Knowledge

There's a phenomenon in cognitive psychology called the curse of knowledge. It describes what happens when you become so fluent in a subject that you lose the ability to recall what it was like not to know it. The gaps that cause beginners to fail become invisible to you. The steps you skip over because they're obvious to you are not obvious to the person reading your documentation for the first time.

One practitioner put it this way: "Remember how it was when you learned the subject. Remember the questions you had to ask, the things you struggled with. Write the way you wish someone had written for you."

This is harder than it sounds. Holding back expertise while writing requires genuine cognitive effort. It means asking not "what do I know about this?" but "what would someone need to know to use this successfully, starting from nothing?"

The only reliable way to find out is to test your documentation with actual users from your intended audience. Not colleagues who know the system. People who don't. Watch where they get stuck. The places that surprise you are the places you've been invisibly assuming shared knowledge that your reader doesn't have.

---

## Why Most Documentation Fails

When practitioners diagnose documentation failures, two root causes come up most often.

The first is mixing. Most bad documentation is the product of conflating different types of documentation and trying to serve multiple purposes with a single document. The reader arrives looking for one thing and has to extract it from a mixture of things they don't need. The writer, simultaneously trying to teach, instruct, explain, and document, ends up doing none of them particularly well.

The second is incentives. Teams know that documentation matters in the abstract. But developers don't see their peers spending time on it, so they don't prioritise it. This creates a negative loop. One practitioner made a distinction that I think is valuable: there's a difference between compliance — forcing documentation to happen through mandates and deadlines — and commitment — engineers writing documentation because they see the value and want to. Culture scales through commitment. Compliance scales through process, but it produces documentation that reads like it was written as an obligation, and it's read the same way.

---

## The Four Types of Documentation, and Why Keeping Them Separate Matters

There's a framework for thinking about documentation that I find genuinely useful. It proposes that documentation has four fundamentally different purposes, and that the failures of most documentation can be traced back to conflating these purposes.

The first type is tutorials. A tutorial is for someone encountering a subject for the first time. They don't know what they don't know. They can't evaluate options because they have no frame of reference. The purpose of a tutorial is not to teach concepts. It is to give the reader a successful, confidence-building experience. To get them to a working state as quickly as possible, even if that means simplifying and deferring the full picture.

The failure mode of tutorials is introducing concepts before giving the reader anything to do. A tutorial that requires reading fifteen minutes of background theory before typing a single command has already failed for most of its audience. Learning by doing is not a pedagogical preference. It's how humans actually acquire confidence with new skills.

The second type is how-to guides. These are for someone who knows what they want to accomplish and needs the shortest route to doing it. A how-to guide assumes competence. It doesn't explain basics. It has a title like "How to configure SSL termination" — specific, action-oriented, results-focused. It is not a tutorial. The reader chose this task. You are not guiding them through a curriculum.

The third type is reference documentation. This is for someone who already knows what they're looking for and needs the precise details. API documentation, configuration option lists, command-line flag references. The defining characteristic: it is organised for lookup, not for learning. Every entry is consistent with every other entry. The most effective reference documentation is generated automatically from the code so it can't drift out of sync with the implementation.

The fourth type is explanations. These are for someone who wants to understand why. Not how to use something, not the specific details, but the context — why is it designed this way, what were the alternatives, what are the trade-offs? Explanations are where history belongs, where opinions belong, where you can be honest about the complexity of something rather than presenting a simplified face.

The key insight is that these four types should be kept separate. A tutorial that stops to explain design rationale loses its tutorial quality. A how-to guide that tries to teach background theory stops being useful for someone who just needs to get something done. Mixing them produces documentation that serves no purpose particularly well.

---

## Creation Velocity: Why Good Intentions Don't Produce Good Docs

One of the most practical insights I've heard from teams that have improved their documentation culture is this: the bottleneck isn't motivation. It's friction.

Documentation creation is slow enough that reality moves faster. A system changes. The documentation is outdated. Writing an update means opening a separate wiki, finding the right page, switching mental context. And so it doesn't happen.

The teams that produce consistently accurate documentation tend to keep documentation next to the code it describes, in the same repository, using the same review workflow. Changes to the system require changes to the documentation as part of the same pull request. The documentation lives where developers already are, uses tools they already use, and follows processes they already follow.

This is sometimes called docs-as-code, and the practical benefits are concrete. Documentation changes are reviewed alongside code changes, which catches inaccuracies before they're published. Documentation lives in version control, which means you can see what changed and when. Automated checks can flag links that break, APIs that have drifted from their documentation, and pages that haven't been updated since a related code change.

The organisational implication: documentation sprints are almost always a sign that documentation is not part of the workflow. By the time the sprint happens, the team has forgotten why decisions were made. The resulting documentation is retrospective reconstruction, which is both less accurate and less useful than documentation written contemporaneously.

---

## Writing for a World Without Context

There's a consequence of how developers actually use documentation that changes how you should write it. Most readers arrive at a documentation page directly — through a search engine, a link in a Slack message, a reference from Stack Overflow. They have not read the tutorial. They may not even know what the broader system is. They arrive at your page with a specific question and no guaranteed context.

This means every documentation page needs to be self-contained. Every page should answer the question "what is this?" in its first paragraph, without assuming the reader has read anything else. Every page should link to related content in both directions so the reader can orient themselves if they need broader context. Assumptions of prior reading are hidden barriers that cause readers to bounce.

The practical implication for organisation is that topic-based structure — where each page covers exactly one topic and topics are connected by links — is more resilient than linear narrative structure. A change to one topic doesn't require rewriting surrounding content. Each page stands alone and serves as an entry point.

---

## Writing Style: The Basics That Make the Most Difference

A few principles from technical writing practice that have an outsized effect on clarity.

Active voice over passive. "The server loads the configuration file at startup" is more direct and easier to process than "the configuration file is loaded by the server at startup." Active voice names the agent and makes the flow of cause and effect clearer.

Short sentences over long ones. A sentence with multiple nested clauses forces the reader to hold context in working memory while the meaning resolves. Break compound sentences. Let each idea land before introducing the next.

Define terms before using them. Every acronym or piece of jargon that a reader encounters without explanation is a moment of friction. Define on first use, or eliminate the jargon.

Code examples must run as written. An example that doesn't work, or that requires unstated assumptions, teaches the wrong lesson. Show realistic examples with realistic variable names and real error handling. The reader will pattern-match on your examples. Make sure the pattern they're matching is the right one.

---

## Measuring Whether It's Working

Almost no team measures whether documentation actually does what it's supposed to do. This is part of why documentation investment is hard to justify to leadership — it stays invisible.

The teams that have gotten buy-in for documentation investment tracked concrete things. Time to first successful result for new users following a tutorial. Support ticket volume before and after documentation improvements. The question "can a new team member onboard using only the documentation?" answered honestly, by timing a new team member doing it.

These are not exotic metrics. They're just rarely tracked. When they are tracked, the results make the investment obvious.

The deeper principle is that documentation is not a kindness you do for users. It is organisational memory, risk mitigation, and the foundation of a system that can survive the loss of any individual engineer. Write the documentation you wish had existed when you joined. Write it while you remember what it was like not to know. And treat it as the serious engineering discipline it is.
