# Repository Guidelines

## Project Structure & Module Organization
- `dotfiles/`: Repository-owned files and directories that will be linked into the home directory.
- `dotfiles.map.json`: Map of repo paths (keys) to target locations (values). Each key mirrors the path under `dotfiles/`.
- `install.ps1`: Idempotent installer that links files from `dotfiles/` to targets.
- `install.sh`: Bash installer for Unix-like environments.
- `add-dotfile.ps1`: Helper that copies a file/folder into `dotfiles/` and updates `dotfiles.map.json`.
- `add-dotfile.sh`: Bash helper that copies a file/folder into `dotfiles/` and updates `dotfiles.map.json`.

## Build, Test, and Development Commands
This repo is script-driven; there is no build step.
- `pwsh ./install.ps1`: Install dotfiles; Windows falls back to copying if symlinks fail.
- `pwsh ./install.ps1 -DryRun`: Show intended actions without filesystem changes.
- `pwsh ./install.ps1 -Check`: Validate targets; exits non-zero for missing, foreign, or broken targets.
- `pwsh ./install.ps1 -Force`: Permit replacing foreign targets after backup.
- `pwsh ./install.ps1 -Only "git"`: Process one mapping key.
- `pwsh ./install.ps1 -Uninstall`: Remove repo-owned links only.
- `pwsh ./add-dotfile.ps1 -Source "<path>" -Key "git/.gitconfig" -Target "~/.gitconfig"`: Add a new file and map it.
- `./install.sh`: Install dotfiles by creating links (Bash; requires `jq`).
- `./install.sh --dry-run`: Show intended actions without filesystem changes.
- `./install.sh --check`: Validate targets; exits non-zero for missing, foreign, or broken targets.
- `./install.sh --force`: Permit replacing foreign targets after backup.
- `./install.sh --only "git"`: Process one mapping key.
- `./install.sh --uninstall`: Remove repo-owned links only.
- `./add-dotfile.sh "<path>" "git/.gitconfig" "~/.gitconfig" "windows,linux,macos"`: Add a new file and map it.

Prerequisites:
- PowerShell 7+ recommended (`pwsh`).
- `jq` required for Bash scripts.

## Coding Style & Naming Conventions
- PowerShell scripts use 4-space indentation and `PascalCase` for functions (e.g., `Process-Entry`).
- Use descriptive parameter names and keep scripts idempotent.
- Mapping keys should mirror the on-disk path under `dotfiles/` (e.g., `nvim/init.lua`).
- Platforms should be `windows`, `linux`, or `macos` (avoid `darwin`).

## Testing Guidelines
- CI runs automated checks; use installer `-DryRun` / `--dry-run` and `-Check` / `--check` for local behavior checks.

## Commit & Pull Request Guidelines
- Commit history is minimal; no enforced convention. Prefer short, imperative summaries (e.g., "Add zsh config").
- Avoid using "wip" for final commits.
- PRs should include: a brief description, affected platforms (windows/linux/macos), and example commands run.

## Security & Configuration Tips
- Without `-Force` / `--force`, foreign targets are refused and are not changed.
- With Force, foreign targets are backed up under `.backup/` before replacement; backups contain copies of the replaced files.
- `add-dotfile.ps1` follows symlinks; if the symlink target is outside `$HOME`, it prompts for confirmation.
