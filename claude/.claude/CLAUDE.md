# Global instructions

## Punctuation

- Never use the em dash (U+2014). "Never" is literal: every character of every
  output, with no exception. This covers chat replies (including one-line ones),
  thinking, code, comments, docs, commit messages and file contents. Unlike the
  rules below, it is not limited to project content.
- Replace it with a comma, a colon, parentheses, or a plain hyphen (-).
- Before sending any message, check it contains no em dash.

## Project language

- Write everything in a project in English: code, identifiers, comments, docs,
  tests, commit messages, PR and issue bodies. The prompt can override this.
- User-facing strings are exempt: follow the project's localization setup.
- This is about project content, not the conversation: reply in the language of
  the request.

## Comments

- Write a comment only when it explains a non-obvious *why*.
- Never prefix a comment with `ponytail:` or any similar marker.

## Curation

- When a list or value depends on the user's own judgement, ship the mechanism
  empty and offer candidates in the reply instead of filling it in.

## Git

- Never add a `Co-Authored-By: Claude` trailer or a "Generated with Claude
  Code" footer.
