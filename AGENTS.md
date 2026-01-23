# Repository Guidelines

## Project Structure & Module Organization
- `dotfiles/`: Repository-owned files and directories that will be linked into the home directory.
- `dotfiles.map.json`: Map of repo paths (keys) to target locations (values). Each key mirrors the path under `dotfiles/`.
- `install.ps1`: Idempotent installer that links files from `dotfiles/` to targets.
- `add-dotfile.ps1`: Helper that copies a file/folder into `dotfiles/` and updates `dotfiles.map.json`.

## Build, Test, and Development Commands
This repo is script-driven; there is no build step.
- `pwsh ./install.ps1`: Install dotfiles by creating links (or copying on Windows if symlinks fail).
- `pwsh ./install.ps1 -DryRun`: Show intended actions without changing the system.
- `pwsh ./install.ps1 -Check`: Validate current targets and report missing/foreign items.
- `pwsh ./install.ps1 -Force`: Overwrite non-repo targets.
- `pwsh ./add-dotfile.ps1 -Source "<path>" -Key "git/.gitconfig" -Target "~/.gitconfig"`: Add a new file and map it.

## Coding Style & Naming Conventions
- PowerShell scripts use 4-space indentation and `PascalCase` for functions (e.g., `Process-Entry`).
- Use descriptive parameter names and keep scripts idempotent.
- Mapping keys should mirror the on-disk path under `dotfiles/` (e.g., `nvim/init.lua`).

## Testing Guidelines
- No automated test suite exists. Use `-DryRun` and `-Check` to validate behavior before applying changes.

## Commit & Pull Request Guidelines
- Commit history is minimal; no enforced convention. Prefer short, imperative summaries (e.g., "Add zsh config").
- Avoid using "wip" for final commits.
- PRs should include: a brief description, affected platforms (windows/linux/macos), and example commands run.

## Security & Configuration Tips
- Review targets in `dotfiles.map.json` carefully; `-Force` can overwrite existing files.
- Keep secrets out of `dotfiles/`; prefer references to secure stores or local-only files.
