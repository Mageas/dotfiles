#!/usr/bin/env bash
# Detects the markers of migrate-repo's step 1 in the repo it runs from.
#
# Usage, from the repo root:
#   bash <migrate-repo skill folder>/scripts/detect.sh
#
# Prints one "<file>: <finding>" line per marker found, then "No marker found."
# if there was none. It checks every marker of the step 1 table except the
# tracker labels, which need the tracker itself. The templates come from the
# setup-repo skill folder beside this one.
#
# Exit status: 0 once the check ran, 1 when the repo has no docs/agents/
# (never set up), 2 when the setup-repo folder is missing.

set -uo pipefail

setup="$(cd "$(dirname "$0")/../../setup-repo" 2>/dev/null && pwd)" || {
  echo "setup-repo skill folder not found beside migrate-repo" >&2
  exit 2
}

if [[ ! -d docs/agents ]]; then
  echo "docs/agents/: missing, the repo was never set up"
  exit 1
fi

found=0
mark() { printf '%s: %s\n' "$1" "$2"; found=1; }

# --- docs/agents ----------------------------------------------------------

[[ -f docs/agents/triage-labels.md ]] && mark docs/agents/triage-labels.md "exists"

lifecycle=docs/agents/ticket-lifecycle.md
if [[ ! -f $lifecycle ]]; then
  mark $lifecycle "missing"
else
  while IFS= read -r heading; do
    grep -qxF "$heading" $lifecycle || mark $lifecycle "lacks the table $heading"
  done < <(grep '^## ' "$setup/ticket-lifecycle.md" | grep -vx '## Rules')
  while IFS= read -r role; do
    # setup-repo drops the wayfinder rows when wayfinder isn't installed.
    [[ $role == wayfinder:* && ! -d "$setup/../wayfinder" ]] && continue
    grep -qF "| \`$role\`" $lifecycle || mark $lifecycle "lacks the row $role"
  done < <(sed -n 's/^| `\([^`]*\)`.*/\1/p' "$setup/ticket-lifecycle.md")
  while IFS= read -r rule; do
    grep -qxF -- "$rule" $lifecycle || mark $lifecycle "lacks the rule: $rule"
  done < <(sed -n '/^## Rules$/,$p' "$setup/ticket-lifecycle.md" | grep '^- ')
fi

tracker=docs/agents/issue-tracker.md
if [[ -f $tracker ]]; then
  template=""
  case "$(head -n1 $tracker)" in
    *GitHub*) template="$setup/issue-tracker-github.md" ;;
    *GitLab*) template="$setup/issue-tracker-gitlab.md" ;;
    *Local*) template="$setup/issue-tracker-local.md" ;;
  esac
  # An "other" tracker has no template to compare with.
  if [[ -n $template ]]; then
    while IFS= read -r heading; do
      grep -qxF "$heading" $tracker || mark $tracker "lacks the section $heading"
    done < <(grep '^## ' "$template")
    while IFS= read -r item; do
      grep -qF "**$item**" $tracker || mark $tracker "lacks **$item**"
    done < <(sed -n 's/^- \*\*\([^*]*\)\*\*.*/\1/p' "$template" | awk '!seen[$0]++')
  fi
  while IFS= read -r line; do
    mark $tracker "says PRD on line ${line%%:*}"
  done < <(grep -nw -e PRD -e PRDs $tracker)
fi

domain=docs/agents/domain.md
if [[ ! -f $domain ]]; then
  mark $domain "missing"
elif ! diff -q "$setup/domain.md" $domain >/dev/null; then
  mark $domain "differs from the template"
fi

# --- Agent skills block ---------------------------------------------------

agents_file=""
for f in CLAUDE.md AGENTS.md; do [[ -f $f ]] && { agents_file=$f; break; }; done
if [[ -z $agents_file ]]; then
  mark "CLAUDE.md / AGENTS.md" "neither exists, so no Agent skills block"
elif ! grep -qx '## Agent skills' $agents_file; then
  mark $agents_file "lacks the ## Agent skills block"
else
  expected=$(awk '/^```/ { if (inside && block) exit; inside = !inside; next }
                  inside && /^## Agent skills$/ { block = 1; next }
                  block && /^### / { print }' "$setup/SKILL.md")
  actual=$(awk '/^## Agent skills$/ { block = 1; next } block && /^## / { exit }
                block && /^### / { print }' $agents_file)
  while IFS= read -r heading; do
    [[ -z $heading ]] && continue
    grep -qxF "$heading" <<<"$actual" || mark $agents_file "Agent skills block lacks $heading"
  done <<<"$expected"
  while IFS= read -r heading; do
    [[ -z $heading ]] && continue
    grep -qxF "$heading" <<<"$expected" || mark $agents_file "Agent skills block has $heading"
  done <<<"$actual"
fi

# --- Old names ------------------------------------------------------------

[[ -d .out-of-scope ]] && mark .out-of-scope/ "exists at the repo root"

while IFS= read -r f; do
  mark "$f" "old name"
done < <({ git ls-files -co --exclude-standard 2>/dev/null || find . -type f | sed 's|^\./||'; } \
          | grep -E '(^|/)CONTEXT(-MAP)?\.md$' || true)

# --- Local tracker files --------------------------------------------------

if [[ -d .scratch ]]; then
  while IFS= read -r -d '' f; do
    case "$f" in
      */PRD.md | */prd.md) mark "$f" "old spec name" ;;
    esac
    first=$(head -n1 "$f")
    [[ $first == '# '* ]] || mark "$f" "first line isn't a # title"
    [[ $first =~ ^#\ [0-9]+: ]] && mark "$f" "title opens with the ticket number"
    grep -qE '^\*\*(Type|Status|Blocked by):\*\*' "$f" && mark "$f" "bold field line"
    grep -qE '^Status: (claimed|resolved)$' "$f" && mark "$f" "old Status: claimed or resolved"
    grep -qx '## Answer' "$f" && mark "$f" "## Answer section"
    case "$f" in
      */issues/*)
        grep -qx 'Type: AFK' "$f" && mark "$f" "Type: AFK"
        grep -qx 'Type: HITL' "$f" && mark "$f" "Type: HITL"
        grep -qE '^Type: (research|prototype|grilling|task)$' "$f" && mark "$f" "type without the wayfinder: prefix"
        grep -q '^Type:' "$f" || mark "$f" "no Type: line"
        grep -q '^Blocked by:' "$f" || mark "$f" "no Blocked by: line"
        grep -q '^\*\*What to build:\*\*' "$f" && mark "$f" "**What to build:** paragraph"
        if grep -qE '^- \[[ x]\]' "$f" && ! grep -qx '## Acceptance criteria' "$f"; then
          mark "$f" "acceptance criteria under no heading"
        fi
        grep -qE '^(## Parent|Part of|## Blocked by)' "$f" && mark "$f" "## Parent, Part of or ## Blocked by"
        ;;
      */map.md)
        grep -q '^Type:' "$f" || mark "$f" "no Type: line"
        ;;
    esac
  done < <(find .scratch -mindepth 2 \( -path '.scratch/*/issues/*.md' -o -name spec.md -o -name map.md \
             -o -name PRD.md -o -name prd.md \) -type f -print0)
fi

[[ $found == 1 ]] || echo "No marker found."
