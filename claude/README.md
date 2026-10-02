# claude

Claude Code configuration: `CLAUDE.md`, `settings.json` and `statusline.sh`.

```sh
stow claude
```

The mods in `.claude/mods/` load through `CLAUDE_CODE_PLUGIN_DIRS` in
`settings.json`, which points into this folder. Stow skips them
(`.stow-local-ignore`): Claude Code refuses a hooks module that is a symlink
resolving outside its plugin folder.

The skills live in the [my-skills](https://github.com/Mageas/my-skills) repo,
including the third-party ones (`vendor/`), and are installed as the separate
`agent-skills` package by `make install` in that repo.
