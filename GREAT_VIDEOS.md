# Great Engineering Videos

Conference talks and lectures considered essential by the software engineering community. Focused on architecture and videos that change how you approach writing code — not tutorials or framework guides.

Sourced from Hacker News "talks that changed how I think about programming" threads, the hellerve/programming-talks and JanVanRyswyck/awesome-talks GitHub lists, and TechYaks.

---

## Foundational Philosophy

These four are the most-cited starting point. Watch them before anything else.

### Simple Made Easy — Rich Hickey (Strange Loop 2011)
https://www.youtube.com/watch?v=SxdOUGdseq4

The single most-referenced talk in the software community. Hickey draws a hard line between *simple* (one role, not interleaved) and *easy* (familiar, close to hand) and argues that conflating the two is the root cause of most software complexity. After watching this you will never use the words "simple" and "easy" interchangeably again.

---

### Hammock Driven Development — Rich Hickey (Clojure Conj 2010)
https://www.youtube.com/watch?v=f84n5oFoZBc

A direct challenge to the bias-toward-action culture in software. Hickey argues that most bugs are design errors, not coding errors, and that the background mind — away from the keyboard — solves hard problems better than grinding. Forces you to ask: am I coding, or am I thinking?

---

### The Value of Values — Rich Hickey (JaxConf 2012)
https://www.youtube.com/watch?v=-I-VpPMzG7c

Hickey dismantles place-oriented programming — the idea that a variable is a memory location you update in place — and makes the case for values as the fundamental unit of information. Foundational for understanding why immutability and functional approaches solve real architectural problems rather than being stylistic preferences.

---

### Inventing on Principle — Bret Victor (CUSEC 2012)
https://www.youtube.com/watch?v=PUv66718DII

Victor demonstrates live-feedback programming environments that make the gap between intent and outcome immediate. Philosophically provocative: creators must have an immediate connection to what they create. One of the most visually stunning and intellectually ambitious talks in the field.

---

## Architecture

### Architecture: The Lost Years — Robert C. Martin (Ruby Midwest 2011)
https://www.youtube.com/watch?v=WpkDN78P884

Uncle Bob argues that web frameworks have hijacked application architecture and that the web is a delivery mechanism, not an architectural constraint. The talk that crystallised Clean Architecture as a practical discipline. The core claim: your top-level directory structure should scream what the application *does*, not what framework it uses.

---

### Making Architecture Matter — Martin Fowler (OSCON 2015)
https://www.youtube.com/watch?v=DngAZyWMGR0

Fowler makes the economic case for caring about internal quality. Introduces the design payoff line — the point at which good architecture enables faster feature delivery than poor architecture — giving developers a vocabulary to justify quality work to non-technical stakeholders.

---

### The Art of Destroying Software — Greg Young (Øredev 2014)
https://www.youtube.com/watch?v=1FPsJ-if2RU

Young's counterintuitive rule: write no component that a developer couldn't rewrite from scratch in one week. Reframes the entire goal of software design away from reuse and toward deletability. If your code can't be thrown away, it owns you.

---

### Decisions, Decisions — Dan North (Øredev 2016)
https://www.youtube.com/watch?v=EauykEv_2iA

North reframes software development as a series of decisions under uncertainty and introduces the concept of software that fits in your head as a practical design constraint. One of the most useful lenses for evaluating architectural choices.

---

### Software Is Details — Kevlin Henney (GOTO 2020)
https://www.youtube.com/watch?v=kX0prJklhUE

Challenges the architecture/code divide by arguing that details are not separate from design. The implementation choices *are* the design. Neglecting them at the "architecture" level is intellectual laziness dressed up as abstraction.

---

### Software, Faster — Dan North (GOTO Amsterdam 2016)
https://www.youtube.com/watch?v=USc-yLHXNUg

North argues that the Agile and SOLID canon may be solving the wrong problem, proposing deliberate discovery and spike-and-stabilise as more honest models of how good software actually gets built. A useful challenge to received wisdom — best watched after you've internalised the mainstream view.

---

## Code Quality and Approach

### Boundaries — Gary Bernhardt (RubyConf 2012)
https://www.youtube.com/watch?v=yTkzNHF6rMs

Introduces the architecture of separating functional core from imperative shell, using immutable values at the seams. Simultaneously resolves test isolation, concurrency, and dependency management. One of the most practically transformative design talks of the last decade — the ideas apply regardless of language.

---

### Seven Ineffective Coding Habits of Many Programmers — Kevlin Henney (DevTernity 2016)
https://www.youtube.com/watch?v=SUIUZ09mnwM

Henney methodically dismantles common habits around naming, formatting, commenting, and testing with precision and evidence. Applies to every programmer regardless of language or experience level.

---

### All the Little Things — Sandi Metz (RailsConf 2014)
https://www.youtube.com/watch?v=8bZh5LMaSmE

Using a live refactoring of a deeply nested conditional (the Gilded Rose kata), Metz demonstrates that duplication is far cheaper than the wrong abstraction — a maxim that has genuinely changed how thousands of developers approach refactoring.

---

### Old Is the New New — Kevlin Henney (GOTO Chicago 2018)
https://www.youtube.com/watch?v=AbgsfeGvg3E

Traces how fundamental ideas — structured programming, immutability, functional style, actor models — are rediscovered repeatedly. Gives developers historical perspective and inoculates against hype-driven architecture decisions.

---

### Refactoring to Immutability — Kevlin Henney (NDC)
https://www.youtube.com/watch?v=APUCMSPiNh4

A hands-on walk through making existing mutable object-oriented code immutable, showing concretely how immutability eliminates whole classes of bugs and simplifies reasoning about state.

---

## Testing

### TDD, Where Did It All Go Wrong — Ian Cooper (DevTernity 2017)
https://www.youtube.com/watch?v=EZ05e7EMOLM

Cooper goes back to Kent Beck's original intent for TDD and argues that the industry got it badly wrong by testing implementations rather than behaviours. Resets how most developers think about what a "unit" actually is. Essential if your test suite ever felt like it slowed you down rather than gave you confidence.

---

## Complexity and Systems Thinking

### The Mess We're In — Joe Armstrong (Strange Loop 2014)
https://www.youtube.com/watch?v=lKXe3HUG2l4

The creator of Erlang delivers a sober diagnosis of why software is so irreducibly complex — touching on entropy, naming, identity, and the impossibility of fully understanding modern systems.

---

### Is It Time to Rewrite the Operating System in Rust? — Bryan Cantrill (QConSF 2018)
https://www.youtube.com/watch?v=HgtRAbE1nBM

A technically rigorous examination of language design trade-offs at the systems level. Cantrill's honest framing of what Rust actually solves — and what it doesn't — models the kind of first-principles reasoning that generalises far beyond the specific question.

---

## Culture and Engineering Practice

### Principles of Technology Leadership — Bryan Cantrill (Monktoberfest 2017)
https://www.youtube.com/watch?v=9QMGAtxUlAc

Cantrill draws on historical leadership writing to articulate the values that distinguish engineering cultures worth joining from those worth leaving. One of the most-shared talks on what engineering culture actually means beyond the platitudes.

---

### A Path to Better Programming — Robert C. Martin & Allen Holub (GOTO 2021)
https://www.youtube.com/watch?v=QnmRpHFoYLk

A candid dialogue between two senior practitioners re-examining whether Agile and Clean Code have been implemented well or badly, and what going back to first principles actually looks like.

---

## Quick Reference

| Talk | Speaker | URL |
|---|---|---|
| Simple Made Easy | Rich Hickey | https://youtu.be/SxdOUGdseq4 |
| Hammock Driven Development | Rich Hickey | https://youtu.be/f84n5oFoZBc |
| The Value of Values | Rich Hickey | https://youtu.be/-I-VpPMzG7c |
| Inventing on Principle | Bret Victor | https://youtu.be/PUv66718DII |
| Architecture: The Lost Years | Robert C. Martin | https://youtu.be/WpkDN78P884 |
| Making Architecture Matter | Martin Fowler | https://youtu.be/DngAZyWMGR0 |
| The Art of Destroying Software | Greg Young | https://youtu.be/1FPsJ-if2RU |
| Decisions, Decisions | Dan North | https://youtu.be/EauykEv_2iA |
| Software Is Details | Kevlin Henney | https://youtu.be/kX0prJklhUE |
| Software, Faster | Dan North | https://youtu.be/USc-yLHXNUg |
| Boundaries | Gary Bernhardt | https://youtu.be/yTkzNHF6rMs |
| Seven Ineffective Coding Habits | Kevlin Henney | https://youtu.be/SUIUZ09mnwM |
| All the Little Things | Sandi Metz | https://youtu.be/8bZh5LMaSmE |
| Old Is the New New | Kevlin Henney | https://youtu.be/AbgsfeGvg3E |
| Refactoring to Immutability | Kevlin Henney | https://youtu.be/APUCMSPiNh4 |
| TDD, Where Did It All Go Wrong | Ian Cooper | https://youtu.be/EZ05e7EMOLM |
| The Mess We're In | Joe Armstrong | https://youtu.be/lKXe3HUG2l4 |
| Rewrite the OS in Rust? | Bryan Cantrill | https://youtu.be/HgtRAbE1nBM |
| Principles of Technology Leadership | Bryan Cantrill | https://youtu.be/9QMGAtxUlAc |
| A Path to Better Programming | Martin & Holub | https://youtu.be/QnmRpHFoYLk |
