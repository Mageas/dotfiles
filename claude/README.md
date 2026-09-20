# claude

Claude Code configuration: `CLAUDE.md`, `settings.json`, `statusline.sh` and the
skills in `.claude/skills`.

```sh
stow claude
```

## Skills

The skills are vendored from the [my-skills](https://github.com/Mageas/my-skills)
repo, where they are kept up to date. This folder only holds the copy that gets
stowed into `~/.claude/skills`.

## Original sources

`.claude/skills/ponytail` comes from
[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail):

```sh
npx skills add DietrichGebert/ponytail --skill ponytail --agent claude-code
```

`.claude/skills/typescript-advanced-types` comes from
[wshobson/agents](https://github.com/wshobson/agents):

```sh
npx skills add https://github.com/wshobson/agents --skill typescript-advanced-types
```

`.claude/skills/unslop` comes from
[cursor/plugins](https://github.com/cursor/plugins):

```sh
mkdir -p .claude/skills/unslop && \
curl -fsSL https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/unslop/SKILL.md \
  -o .claude/skills/unslop/SKILL.md
```

Every other skill comes from
[mattpocock/skills](https://github.com/mattpocock/skills):

```sh
npx skills add mattpocock/skills --agent claude-code
```
