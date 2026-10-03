# claude

Claude Code configuration: `CLAUDE.md`, `settings.json` and `statusline.sh`.

```sh
stow claude
```

The mods in `.claude/mods/` load through `CLAUDE_CODE_PLUGIN_DIRS` in
`settings.json`, which points into `~/.claude/mods`. Stow skips them
(`.stow-local-ignore`): with `--no-folding` it would link each file, and
Claude Code refuses a hooks module whose real path lies outside its plugin
folder. Link the whole folder once instead:

```sh
ln -s ../.dots/claude/.claude/mods ~/.claude/mods
```

The skills live in the [my-skills](https://github.com/Mageas/my-skills) repo,
including the third-party ones (`vendor/`), and are installed as the separate
`agent-skills` package by `make install` in that repo.
