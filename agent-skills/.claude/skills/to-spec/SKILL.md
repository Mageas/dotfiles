---
name: to-spec
description: "Turn the current conversation into a spec and publish it to the project issue tracker: no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a spec. Do NOT interview the user; just synthesize what you already know.

The issue tracker and ticket lifecycle should have been provided to you. If not, tell the user to run `/setup-repo`.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Check the shape. When the feature touches the shape (it adds, splits or merges a module, adds or changes an interface between modules, or adds an I/O dependency) and no Architecture section was agreed in this conversation, stop and suggest `/architect` first.

3. Sketch out the seams at which you're going to test the feature. When an Architecture section was agreed, test through its interfaces: they are settled. Otherwise, existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations.

4. Write the spec using the template below, then publish it to the project issue tracker. Apply the `spec` role and no state: the spec is the user's to validate, never an agent's to claim.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Architecture

The Architecture section agreed with `/architect`, copied as it stands, signatures included. Omit it when the feature leaves the shape as it is.

## Implementation Decisions

A list of implementation decisions that were made. The interfaces, the reuse and the module changes live in the Architecture section. This can include:

- Technical clarifications from the developer
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>

5. If the conversation worked from a `/wayfinder` map, link the map at the top of the spec, then close the map as `done` with a comment linking the spec. The spec now carries the map's decisions forward.
