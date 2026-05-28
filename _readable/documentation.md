# Writing Documentation That Actually Works

Most technical documentation fails not because the writer lacks technical knowledge, but because they lack a clear framework for what the documentation is trying to do. Without this framework, a single document ends up attempting to serve several incompatible purposes at once — and ends up serving none of them well.

The reader arrives looking for one specific kind of help. If the document mixes tutorials with reference material, how-to instructions with conceptual explanation, the reader must work to extract what they need while being distracted by what they do not. The writer, meanwhile, cannot write clearly because they are not clear about what kind of document they are writing.

---

## The Four Types of Documentation

There is a useful framework that separates documentation into four distinct types, organised along two axes.

The first axis is whether the reader is trying to learn or trying to accomplish something right now. Someone learning is willing to invest time and follow a structured path. Someone trying to get a specific thing done needs the shortest route to completion and does not want to be taught more than necessary.

The second axis is whether the focus is practical or theoretical. Practical documentation is about doing. Theoretical documentation is about understanding.

These two axes produce four quadrants, each requiring a fundamentally different kind of writing.

---

## Tutorials: Learning by Doing

A tutorial is for someone who is new to a technology or concept. They do not yet know what they do not know. They cannot evaluate different approaches because they have no frame of reference yet.

The purpose of a tutorial is not to teach concepts. It is to give a beginner a successful, confidence-building experience. By the end, the reader should have accomplished something real and have a sense that this technology is something they can work with.

This has practical implications for how to write tutorials. Every step must work. Every command should show its expected output so the reader can verify they are on track. There should be no choices, no options, no digressions — one right path, with everything decided by the writer. Theoretical completeness is sacrificed for usability.

The most common failure mode of tutorials is introducing concepts before giving the reader anything to do. A tutorial that requires reading fifteen minutes of background theory before typing a single command has already lost most of its audience.

---

## How-To Guides: Getting Things Done

A how-to guide is for someone who knows what they want to accomplish. They are not learning — they chose this task. They need the most direct route to completing it.

How-to guides assume competence. They do not explain basics. They are focused entirely on the outcome. "How to configure SSL termination" is a how-to. "Understanding TLS" is not.

Titles for how-to guides should be specific and action-oriented. The steps should be numbered, discrete, and each should have a visible outcome so the reader knows they are on track. Include what to do if something goes wrong. Keep theory out — if background is needed, link to an explanation rather than including it.

---

## Reference: The Source of Truth

Reference documentation is for someone who already knows what they are looking for and needs the precise details. They are not reading to learn — they are reading to verify or look up a specific fact.

Reference documentation must be complete and accurate above all else. It is organised for lookup, not for learning — alphabetically, by module, by concept. It is descriptive rather than instructional. It does not explain why things are designed the way they are.

API documentation, configuration option lists, command-line flag references, and man pages are all reference documentation. The most effective reference documentation is generated automatically from the code — this keeps it in sync with the implementation and eliminates the manual work of keeping it up to date.

---

## Explanations: Understanding Why

Explanations are for someone who wants to understand the context behind something — why it works the way it does, what the design decisions were, what alternatives were considered and why they were not chosen.

Explanations do not instruct. They illuminate. They answer "why" questions, not "how" questions. They can discuss tradeoffs, historical context, and the relationship between different concepts. The tone can be more conversational and exploratory than other documentation types.

Examples: "Why does this framework use the approach it does?", "How the event loop works and why that matters for I/O-heavy code", "The reasoning behind this architectural decision."

---

## Keeping the Types Separate

The key insight of this framework is that these four types of documentation should be kept separate from each other. Mixed documentation — a tutorial that stops to explain concepts, a how-to guide that tries to teach background theory, a reference page that includes narrative — fails at all of its purposes simultaneously.

When you sit down to write documentation, decide first which type you are writing. This clarifies your purpose, your audience, your tone, and what to include and exclude.

---

## Writing the README First

One useful discipline is to write the project's README before writing any code. The README forces you to articulate what the project is, what problem it solves, who it is for, and how it works — from the outside in. This process often reveals gaps in the design that are much cheaper to address before implementation than after.

A good README contains: a one-paragraph answer to "what is this?"; a quick start that gets someone to a working result in under five minutes; installation instructions with all prerequisites made explicit; a few core usage examples showing the most common cases; a link to fuller documentation for depth; and how to contribute and the licence.

What a README should not contain is everything. A README that takes thirty minutes to read has failed as a README. Long content belongs in the appropriate type of linked documentation.

---

## Writing for a Distributed Audience

In a world where readers arrive at documentation via search engines, any page may be the first page a reader sees. Documentation cannot assume the reader has followed a linear path through earlier material.

Each page should make sense on its own. Each page should answer "what is this?" in its first paragraph without requiring context from other pages. Related pages should be linked in both directions. Do not assume the reader has completed a tutorial, read an installation guide, or seen any other specific content.

This has implications for how to organise documentation. Topic-based structure — where each page covers exactly one topic and topics are connected by links rather than sequenced — is more resilient than a linear narrative structure. A change to one topic does not require rewriting surrounding material.

---

## Writing Style

Active voice is clearer than passive voice. "The server loads the configuration file" is more direct and easier to process than "the configuration file is loaded by the server." Prefer it.

Short sentences are clearer than long ones. A sentence with multiple nested clauses forces the reader to hold several pieces of context in mind simultaneously before the meaning resolves. Break it.

Define technical terms before using them. Every piece of jargon that a reader encounters without definition is a moment of friction. Define on first use.

Code examples must run as written. An example that does not work, or that omits the error handling that real code requires, teaches the wrong lesson. Show realistic examples with real variable names and real error handling.

---

## Documentation in the Development Workflow

Documentation written after the fact, as an obligation, reads like it was written after the fact as an obligation. The most reliable way to produce good documentation is to treat it as part of the definition of done for any feature, not as a separate subsequent task.

Documentation that lives in the same repository as the code it describes is more likely to stay in sync. Documentation changes can go through the same review process as code changes. Automated checks can flag links that break, APIs that drift from their documentation, and prose that has not been updated alongside a code change.

**The curse of knowledge** is the central challenge of technical writing. The more familiar you are with something, the harder it is to remember what it was like not to know it. The gaps that cause a new reader to become confused are invisible to you — they are the things that are so obvious to you that they do not seem worth stating.

The only reliable antidote is testing documentation with actual users from the intended audience. Watch where they get stuck. Read documentation aloud — awkward phrasing becomes immediately apparent. Track where users open support tickets or ask questions, and treat each one as a documentation gap to address.
