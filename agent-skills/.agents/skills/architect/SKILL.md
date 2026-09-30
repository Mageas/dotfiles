---
name: architect
description: "Audit the code a change crosses and design its interfaces, reuse and modules before the spec."
disable-model-invocation: true
---

# Architect

Design a change before it is specced: the interfaces it adds or changes, the code it reuses or factors, and the modules it adds or splits. The design is written in the repo's language, as signatures that follow the language's idioms. This skill audits and designs; it changes no code.

Call the Skill tool with "codebase-design" for the vocabulary (module, interface, seam, adapter, depth), and name domain concepts with the `CONTEXT.md` terms.

A change **touches the shape** when it adds, splits or merges a module, adds or changes an interface between modules, or adds an I/O dependency (clock, disk, network, database, a third-party service). A change that stays inside one module's implementation leaves the shape as it is: tell the user, and hand back to `/to-spec`, or to `/implement` for a ticket.

## 1. Read

Take the change from the conversation, or from the spec or ticket the user passed. Read `CONTEXT.md` and the ADRs in the area it touches, then the code it crosses: the modules it changes, their callers, and the modules that already do something close to what it needs.

## 2. Audit

Run the repo's tools on the paths the change crosses:

- its linters at their strictest setting (`cargo clippy -- -W clippy::pedantic`, `swiftlint lint --strict`, eslint with the repo's config);
- a clone detector (`npx jscpd <paths>`), when it is installed or npx can fetch it.

Then read the code for the findings below. Tool output is evidence: keep what bears on the design, and leave formatting and naming to the linters.

- **Duplication**: logic written twice, or that the change would write again. Near copies count: the same steps over different types or constants.
- **Reuse**: a helper, type or interface that already does what the change needs, or nearly.
- **Built-in dependency**: a module that builds its own I/O (reads the clock, opens a file, creates an HTTP client) instead of receiving it.
- **Mixed responsibilities**: a module that changes for unrelated reasons, such as parsing, policy and I/O in one function.
- **Repeated branching**: the same match on a kind at several sites, where the change would add a case to each.
- **Wide interface**: callers that each use a small part of it, or an adapter that leaves part of it unimplemented.
- **Primitive stand-in**: a string or number standing for a domain concept.
- **Off-idiom**: code that departs from how the language's standard library and ecosystem do it: errors, ownership or mutability, iteration, async, the interface mechanism (trait, protocol, interface).

Done when each finding names its sites and says whether the change touches them. Findings the change doesn't touch are follow-ups: list them for the user after the design, which stays clear of them.

## 3. Design

Draft the design in the repo's language, by these rules:

- **Reuse before writing.** Use what already does the job, and extend what nearly does.
- **One copy.** Factor each duplicate the change touches into one module that every site calls. Factor copies that change for the same reason; two copies that only look alike stay apart.
- **Interfaces at real seams.** An interface earns its place with two adapters, and a test fake counts as one. Every I/O dependency sits behind one: modules receive it, and the entry point (main, app setup) builds the production adapters.
- **Small interfaces.** Each interface holds what its callers use, so every adapter implements all of it. Keep the behaviour behind it deep.
- **Extend by adding.** When the change adds a kind to a set that keeps growing, the new kind is a new implementation, not a new branch at each site. A closed set keeps the language's exhaustive form (an enum with a match, a union with a switch).
- **Domain types.** Give each primitive stand-in the change touches its own type.
- **Idiomatic signatures.** Write each signature the way the language's ecosystem would: its error type, ownership, async model and naming.

Propose one design. When an interface is uncertain, run `codebase-design`'s design-it-twice pattern and present the designs side by side instead.

## 4. Grill

Call the Skill tool twice, for "grilling" on the design and "domain-modeling" for the terms and ADRs it settles. Revise the design as answers land. A choice that reverses an ADR supersedes it.

Done when the user approves each interface, each factored duplicate and each module change.

## 5. Record

Write the agreed design as an **Architecture section**, in the template below:

- **No issue passed**: post it in the chat. `/to-spec` copies it into the spec.
- **A spec or ticket passed**: write it into the issue's body, replacing any earlier Architecture section.

<architecture-section-template>

## Architecture

### Interfaces

```<language>
// Each interface the change adds or changes, as signatures, with a doc comment
// for what the types don't say: invariants, error modes, ordering.
```

- **<Interface>**: its adapters (production, test), and the modules that receive it.

### Reuse

- **<Logic>**: the sites that hold it today, and the one module that owns it after the change.

### Modules

- **Added** / **Changed** / **Removed** <module>: what it owns in one line, and what it receives.

### ADRs

- The ADRs this design rests on, supersedes or adds.

</architecture-section-template>

Drop a heading that has nothing to hold.
