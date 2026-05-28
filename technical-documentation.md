---
title: Technical Documentation
nav_order: 7
---

# Writing Effective Technical Documentation

> Synthesized from **Daniele Procida** (Diátaxis framework, Canonical/Django), **Jacob Kaplan-Moss** (Django co-creator, writing philosophy), **Mark Baker** (Every Page is Page One), **Tom Preston-Werner** (README-Driven Development), **Write the Docs community**, and **Google's Technical Writing guidelines**.

---

## Why Documentation Fails

Most technical documentation is bad — not because writers lack technical knowledge, but because they lack a framework for what documentation *is for*. Daniele Procida's diagnosis: "The problem is that we conflate different kinds of documentation and try to meet several different needs at once. The solution is to recognize that documentation has four distinct functions, and to keep them separate."

Common failure modes:
- **Tutorial/reference hybrids**: Instructions mixed with explanations mixed with reference — the reader doesn't know what they're looking at
- **Documentation that only makes sense to the author**: Written to record what the author knows, not to transfer knowledge to someone who doesn't
- **Documentation that describes the system, not the user's needs**: Organized around the implementation, not around what users are trying to accomplish
- **Documentation written after the fact, as obligation**: Read as such by users

---

## The Diátaxis Framework (Procida)

The most useful framework for organizing technical documentation. Procida identifies two axes:

- **Study vs. Work**: Is the user trying to learn, or trying to get something done?
- **Practical vs. Theoretical**: Is the user focused on doing, or on understanding?

These axes create four quadrants, each requiring a fundamentally different type of document:

```
                    STUDY
                      |
         Tutorials    |    Explanations
                      |
 PRACTICAL ———————————|——————————————— THEORETICAL
                      |
         How-to       |    Reference
         Guides       |
                      |
                    WORK
```

---

### Quadrant 1: Tutorials (Practical Study)

**Purpose**: Help a newcomer learn by *doing*. The goal is not to teach concepts; it is to give a beginner a successful experience that builds confidence and motivation.

**Characteristics:**
- The reader does not yet know what they don't know
- You, the writer, decide what they will learn and in what order
- Every step should work and produce visible results
- No choices, no options, no digressions — one right path through
- The subject matter is simplified; theoretical completeness is sacrificed for usability

**What a tutorial is not**: A tutorial is not a how-to guide. "Install and configure nginx" is a how-to. "Build your first web server in 15 minutes" is a tutorial.

**Writing guidance:**
- Use second-person, present tense: "Type the following command."
- Show the output of every command, so readers can verify they're on track
- Explain the minimum necessary to proceed; save deeper explanations for the Explanation section
- Test the tutorial with actual beginners — the gaps will surprise you

---

### Quadrant 2: How-to Guides (Practical Work)

**Purpose**: Help an experienced user accomplish a specific goal. The reader knows what they want; they need to know how.

**Characteristics:**
- Results-oriented, not learning-oriented
- Assumes a level of competence; does not explain basics
- Specific: "How to configure SSL termination with nginx and Let's Encrypt"
- Can be short — a few steps — if the task is simple

**What a how-to guide is not**: A tutorial. The reader chose to do this task; you are not guiding them through a curriculum.

**Writing guidance:**
- Title: "How to [verb] [noun]" — specific and action-oriented
- Number the steps; each step should be a discrete action with a visible outcome
- Include error cases: "If you see [X], [do Y]"
- No theory — if theory is needed, link to Explanation
- Focus on the task, not on the tool's features

---

### Quadrant 3: Reference (Theoretical Work)

**Purpose**: Provide accurate, complete information that practitioners look up while working.

**Characteristics:**
- The reader knows what they're looking for; they need the precise details
- Comprehensive and correct above all else
- Organized to support lookup (alphabetical, by module, by concept) not learning order
- Descriptive, not instructional

**Examples**: API documentation, man pages, class/function docs, configuration option lists, CLI flag references.

**Writing guidance:**
- Write in a neutral, impersonal register
- Every entry should be consistent with every other entry
- Code examples should be minimal and correct — not tutorials
- Automate where possible: generate reference docs from code annotations (JSDoc, Sphinx autodoc, Javadoc) to keep them in sync
- Mark deprecations clearly; don't remove until the feature is removed

---

### Quadrant 4: Explanations (Theoretical Study)

**Purpose**: Help the reader understand why things are the way they are. Context, background, design decisions, architectural reasoning.

**Characteristics:**
- Illuminates context and relationships; does not instruct
- Can introduce alternatives and discuss tradeoffs
- Answers "why" questions, not "how" questions

**Examples**: "Why does Django use CSRF tokens?", "How the event loop works", "The rationale behind React's unidirectional data flow."

**Writing guidance:**
- Use a conversational, exploratory tone — you are thinking with the reader
- Historical context is appropriate here
- Connect concepts across the codebase/system
- This is where opinions and tradeoffs are discussed — be honest about them

---

## README-Driven Development (Tom Preston-Werner)

Preston-Werner's principle (2010): write the README before writing the code. The README forces you to articulate what the project does, why it exists, and how it works from the outside in.

**What a README must contain:**
1. **What is this?** One paragraph. What problem does it solve? Who is it for?
2. **Quick start**: A minimal working example that takes < 5 minutes. If someone can't get it working in 5 minutes, they will leave.
3. **Installation**: Step-by-step. Include prerequisites explicitly.
4. **Core usage examples**: The most common 3–5 use cases. Show real code.
5. **Configuration reference**: Link to full docs or include here if brief.
6. **Contributing**: How to run tests, submit changes.
7. **License**: One line.

**What a README should not contain**: Everything. A README that takes 30 minutes to read has failed as a README. Long content belongs in linked documentation.

---

## Every Page Is Page One (Mark Baker)

Baker's key insight: in the age of search engines, readers arrive at any documentation page directly — not necessarily having read earlier pages. Documentation must therefore be **self-contained**.

**Design for findability:**
- Every page should make sense without its context
- Every page should answer the question: "What is this?" in the first paragraph
- Provide forward and backward links to related content
- Don't assume the reader has read the tutorial, the installation guide, or any other page

**Topic-based writing**: Each page covers exactly one topic. Topics are linked, not sequenced. This also makes docs easier to maintain — a change to one topic doesn't ripple through surrounding prose.

---

## Writing Style (Google's Technical Writing Guide)

### Clarity First

**Use active voice:**
```
Passive: The configuration file is loaded by the server at startup.
Active:  The server loads the configuration file at startup.
```

**Be direct:**
```
Wordy: In order to be able to successfully authenticate, it is necessary for you to...
Direct: To authenticate, you must...
```

**Define terms before using them**: Don't assume the reader knows your jargon. Define a term clearly on its first use.

**One idea per sentence**: Long sentences with multiple clauses obscure meaning. Break them.

### Code Examples

- Every code example must run as written (or be clearly marked as partial/pseudocode)
- Use realistic variable and function names — not `foo`, `bar`, `x`
- Comment only what isn't obvious from the code itself
- Show both input and expected output
- Handle errors in examples — real code has error handling

### Formatting for Scannability

Technical documentation is not read linearly. Readers scan for what they need.

- **Headers**: Create hierarchy; readers scan headers to navigate
- **Bullet lists**: For parallel items without natural prose flow
- **Numbered lists**: For ordered steps or ranked items only
- **Code blocks**: For all code, commands, file names, and configuration values
- **Bold**: Sparingly, for genuinely critical terms or warnings
- **Tables**: For comparing multiple items across multiple attributes

---

## Documentation in the Development Workflow

### Docs-as-Code

The most successful technical documentation practices treat documentation with the same rigor as code:
- Documentation lives in the same repository as the code it describes (or a closely linked repo)
- Changes to docs go through pull requests and code review
- Docs are linted (Vale, markdownlint)
- Stale docs are identified by automated checks (link rot detection, API drift)

**Jacob Kaplan-Moss**: "Documentation that lives outside the codebase is documentation that will fall out of date."

### What to Document (and What Not To)

Document:
- Public APIs and interfaces (everything a consumer of your code needs)
- Non-obvious architectural decisions and their rationale
- Operational runbooks for on-call
- Onboarding paths for new team members

Do not document:
- Implementation details that change frequently (these belong in code comments, not docs)
- Things that are obvious from the code
- Everything equally — prioritize by impact

### The Curse of Knowledge

Jacob Kaplan-Moss describes this as the central challenge of technical writing: the more you know about something, the harder it is to remember what it was like not to know it. The knowledge gaps that cause novice readers to fail are invisible to experts.

**Mitigation:**
- Test docs with actual users from the target audience
- Read your docs aloud — awkward phrasings become obvious
- Have someone outside the team attempt a tutorial; watch where they get stuck
- Maintain a "confusion log" where support questions become documentation improvements

---

## Measuring Documentation Quality

### Quantitative signals
- Time-to-first-successful-result for new users following a tutorial
- Support ticket reduction after documentation improvements
- Documentation search success rate (found answer vs. opened support ticket)
- Page bounce rate on documentation pages

### Qualitative signals
- Can a new team member onboard using only the documentation?
- When a bug is reported, is there a doc that covers the scenario?
- Do code reviews regularly prompt documentation updates?

---

## Documentation Anti-Patterns

**The "How It Works" tutorial**: A tutorial that teaches concepts instead of getting users to a working state. Procida: "A tutorial that makes the learner read theory before they can do anything has already failed."

**The comprehensive README**: A README so thorough it takes an hour to read. Solution: a brief README that links to detailed docs organized by Diátaxis type.

**Documentation sprints**: Dedicated time to write documentation is a signal that documentation is not part of the workflow. By the time the sprint happens, the team has forgotten why decisions were made.

**Docs that mirror the code structure**: Documentation organized by module, class, or file — as if the reader shares the implementor's mental model. Organize by user goals instead.

**The "last updated" problem**: A date on a page provides false confidence that it's current and false alarm that it might not be. Instead: verify docs against code on each release.

---

## Key References

- Procida, D. — Diátaxis framework: https://diataxis.fr (free, comprehensive)
- Preston-Werner, T. (2010). "Readme Driven Development": https://tom.preston-werner.com/2010/08/23/readme-driven-development.html
- Baker, M. (2013). *Every Page is Page One*. XML Press.
- Google Technical Writing Courses: https://developers.google.com/tech-writing
- Write the Docs community and style guide: https://www.writethedocs.org
- Kaplan-Moss, J. — "Writing Great Documentation": https://jacobian.org/writing/great-documentation/
- Vale (prose linter for docs-as-code): https://vale.sh
