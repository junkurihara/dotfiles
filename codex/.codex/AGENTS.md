# Global Guidelines

This file defines global working rules for Codex sessions.

## General

- Maximize efficiency. If multiple independent reads or commands can run safely in parallel, run them concurrently rather than sequentially.
- Think in English, but respond in the language used in the conversation unless instructed otherwise.
- Read a file before editing it. Do not patch based on guesses.
- Before declaring work complete, explicitly state what you verified.

## Environment And Safety

When in doubt about local machine state, shared systems, or irreversible changes, stop and ask the user.

### Local Environment

- Do not install tools globally without permission. Prefer project-local alternatives.
- Do not use `sudo`. If elevated privileges are genuinely required, ask the user to run the command or approve the escalation path.
- Do not pipe remote content directly into a shell. Download, inspect, and execute as separate steps.
- Do not modify files under the home directory such as `~/.zshrc`, `~/.gitconfig`, `~/.ssh/*`, or `~/Library/...` unless the user explicitly asked for that scope.
- Do not add new dependencies without permission, including dev dependencies.

### Git

- `git` may be aliased. Prefer the absolute executable such as `/usr/bin/git` or `/opt/homebrew/bin/git` when behavior needs to be predictable.
- Do not run `git push` or `git push --force` without explicit user instruction.
- Do not run destructive git commands without confirmation, including `git reset --hard`, `git clean -fd`, `git checkout -- .`, branch deletion, or operations using `--force` or `--no-verify`.
- Investigate unfamiliar files, branches, or commits before deleting or overwriting them.

### Remote Services

- Do not create PRs, Issues, comments, reviews, reactions, or other remote-side changes without explicit user instruction.

### Secrets

- Do not stage, commit, print, or quote secret-looking material such as `.env`, `*.pem`, tokens, or credentials files unless the user explicitly needs a specific redacted detail.

### Tooling

- Do not run commands that require interactive TTY input unless the task specifically requires it and the user understands the consequence.
- Manage background processes responsibly. If you start a long-running process, track it and clean it up when appropriate.
- Do not fake test success by skipping tests, suppressing assertions, or masking failures just to get a green result.

## Coding And Documentation

- Follow the existing style and conventions of the surrounding code. Do not opportunistically reformat unrelated areas.
- Documentation, docstrings, code comments, and embedded comment text should be written in English unless the repository clearly uses another convention.
- Do not use emojis in code comments or embedded comments.
- When writing Japanese, avoid unnecessary spaces.
- Avoid hard-coded values unless they are clearly justified.
- In TypeScript, avoid `any` and `unknown` unless there is a strong, explicit reason.
- Do not introduce a TypeScript `class` unless it is clearly necessary.
- Do not swallow errors. If an error is intentionally ignored, document why.

## Planning

- For non-trivial work, document requirements and approach in `.tmp/design.md`.
- For non-trivial work, track concrete tasks and progress in `.tmp/task.md`.
- If `.tmp/design.md` or `.tmp/task.md` already exist, read them before proceeding. If they may reflect active or in-progress work, explain the current contents to the user and ask how to proceed before overwriting, reusing, or redirecting them.
- Keep `.tmp/task.md` up to date while working.
- Trivial changes such as typo fixes, formatter-only changes, small config tweaks, and simple Q&A can skip the `.tmp/design.md` and `.tmp/task.md` workflow.

## Research

- When you need current library or API behavior, prefer primary sources such as official documentation, repository docs, or authoritative local project references.

## Completion

- In the final response, summarize the outcome briefly and include the verification you actually performed.
