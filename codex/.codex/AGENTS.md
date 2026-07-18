# Global Guidelines

This file defines global working rules for Codex sessions. Follow these rules unless the user explicitly gives a narrower or stricter instruction.

## Top-Level Rules

- Maximize efficiency. If multiple independent reads or commands can run safely in parallel, run them concurrently rather than sequentially.
- Think exclusively in English, but respond in the language used in the conversation unless instructed otherwise.

## Environment And Safety

This is the user's primary local machine, not an isolated sandbox. There may be no egress firewall and no container boundary, so any damage is real and may affect other projects. When in doubt about local machine state, shared systems, irreversible changes, or any rule below, stop and ask the user before proceeding.

### Workspace

- Multiple repositories may exist under the working area, and multiple agent sessions may run in parallel. Confine reads and writes to the repository you have been asked to work on.
- Do not touch sibling repositories unless explicitly instructed.

### Local Environment

- Do not install tools globally without permission. Prefer project-local alternatives such as `venv`, `npx`, `pipx`, or `cargo install --root`.
- Do not use `sudo`. If elevated privileges are genuinely required, stop and ask the user to run the command themselves.
- Do not pipe remote content directly into a shell, such as `curl ... | sh` or `wget ... | bash`.
- Do not modify files under the user's home directory, such as `~/.zshrc`, `~/.gitconfig`, `~/.ssh/*`, `~/.claude/*`, or `~/Library/...`, unless explicitly instructed.
- Do not add new dependencies without permission, including dev-only dependencies.

### Git

- `git` may be aliased or wrapped. Use the absolute executable, such as `/usr/bin/git` or `/opt/homebrew/bin/git`, when predictable behavior is important.
- Do not commit. Committing is the user's job.
- Do not run `git commit`, `git push`, or `git push --force`.
- Do not chain git commands with `&&` in a single shell invocation.
- Do not run destructive git commands without confirmation, including `git reset --hard`, `git clean -fd`, `git checkout -- .`, branch deletion, or operations using `--force` or `--no-verify`.
- Investigate unfamiliar files, branches, or commits before deleting or overwriting them.

### Remote Services

- Do not create PRs or Issues on GitHub or any remote forge without explicit user instruction.
- Do not post comments, reviews, reactions, or discussion replies without explicit user instruction.

### Secrets

- Do not stage, commit, print, echo, quote, or otherwise expose secret-looking material such as `.env`, `*.pem`, tokens, credentials files, SSH keys, or `credentials.json`.
- Never read credential stores by any means. This includes `~/.ssh/`, `~/.claude/`, `~/Library/Keychains/`, and any `credentials*` file.

### Tooling And Verification

- Always read a file before editing or writing it.
- Before reporting a task as complete, explicitly state what verification was performed.
- Do not run commands that require interactive TTY input, such as `vim`, `less`, `git rebase -i`, `git add -i`, or `npm init` without `-y`.
- Manage background processes responsibly. Track and terminate long-running processes when they are no longer needed.
- Do not fake test success by skipping tests, suppressing assertions, commenting out checks, or masking failures.
- Do not swallow errors. If an error is intentionally ignored, document why.
- When searching for hidden folders such as `.tmp`, use shell commands such as `find`; directory listing tools may omit hidden paths.
- To understand current library or API behavior, prefer primary sources such as official documentation, repository documentation, authoritative local references, or available documentation/search tools.

## Coding And Documentation

- Follow the existing style and conventions of the surrounding code.
- Do not opportunistically reformat or rewrite unrelated areas.
- Documentation, docstrings, code comments, and embedded comment text should be written in English unless the repository clearly uses another convention.
- Do not use emojis in code comments or embedded comments.
- When writing Japanese, avoid unnecessary spaces.
  - Correct: `Claude Code入門`
  - Incorrect: `Claude Code 入門`
- Avoid hard-coded values unless clearly justified.
- In TypeScript, do not use `any` or `unknown` unless there is a strong, explicit reason.
- Do not introduce a TypeScript `class` unless it is clearly necessary.

## Planning

For non-trivial work, use the repository-local `.tmp/` workflow. Trivial changes such as single-line fixes, typo corrections, formatter-only changes, small configuration tweaks, and simple Q&A may skip it.

- Create `.tmp/` at the root of the repository being worked on, never in a shared parent directory.
- Document requirements and design in `<repo>/.tmp/design-codex-<topic>.md`.
- Track concrete tasks and progress in `<repo>/.tmp/task-<topic>.md`.
- Keep `.tmp/task-<topic>.md` updated while working.
- `.tmp/` is working memory and must not be committed.
- Treat user-provided files under `.tmp/`, such as `.tmp/incoming/`, as read-only inputs unless instructed otherwise.

Before starting non-trivial work, check for existing `.tmp/design-codex-<topic>.md` or `.tmp/task-<topic>.md` using a shell command that can find hidden directories. If either exists:

1. Do not overwrite, modify, or delete it as a first action.
2. Read it and summarize the current design, completed tasks, remaining tasks, and apparent state to the user.
3. Ask the user how to proceed and wait for instruction before writing to either file.

For new non-trivial work:

1. Create a plan in `.tmp/design-codex-<topic>.md`.
2. Create a task checklist in `.tmp/task-<topic>.md`.
3. Create a new branch before implementation. Branch names should start with `feat/` unless the repository uses another convention.
4. Break work into small units suitable for review.
5. Apply the repository's formatter when appropriate.
6. Do not commit. Report completion and ask the user to review and commit.

## Pull Requests

When instructed to create a Pull Request, use this format:

- Title: Brief summary.
- Key Changes: Main changes and cautions.
- Testing: Tests run, tests added, and how to run them.
- Related Tasks: Related links or numbers.
- Other: Special notes.

Do not create a PR unless explicitly instructed.

## Completion

- In the final response, briefly summarize the outcome and the verification actually performed.
- If the user's action is required, such as review, approval, privileged command execution, or commit, state this explicitly.
- Send a macOS notification upon task completion, including minor tasks:

\```sh
osascript -e 'display notification "${TASK_DESCRIPTION} is complete" with title "${REPOSITORY_NAME}"'
\```

- If the user's action is required, reflect that in the notification text, for example: `Ready for review and commit`.
