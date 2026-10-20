# dotfiles

A small, script-driven dotfiles repo with an idempotent installer and a simple mapping file.

## Features
- Stateless install: no bookkeeping, safe re-runs
- Cross-platform targeting (windows/linux/macos)
- Repo-owned symlinks; optional force overwrite of foreign targets (with backup)
- Simple map file to define source-to-target links

## Repository Layout
- `dotfiles/`: Files and folders managed by this repo
- `dotfiles.map.json`: Mapping of repo paths to target paths
- `install.ps1`: Installer (link or copy on Windows if symlinks fail)
- `install.sh`: Installer for Bash environments
- `add-dotfile.ps1`: Helper to add files/folders and update the map
- `add-dotfile.sh`: Helper to add files/folders and update the map (Bash)
- `AGENTS.md`: Contributor guidelines

## Prerequisites
- PowerShell 7+ recommended (`pwsh`)
- Bash installer requires `jq`

## Quick Start
1) Add a dotfile (file or directory):

```powershell
pwsh ./add-dotfile.ps1 -Source "$HOME\.gitconfig" -Key "git/.gitconfig" -Target "~/.gitconfig"
```

```bash
./add-dotfile.sh "$HOME/.gitconfig" "git/.gitconfig" "~/.gitconfig" "linux,macos"
```

2) Dry run the install:

```powershell
pwsh ./install.ps1 -DryRun
```

```bash
./install.sh --dry-run
```

3) Install:

```powershell
pwsh ./install.ps1
```

```bash
./install.sh
```

## Mapping File (`dotfiles.map.json`)
Each entry maps a repo-relative key to a target location and optional platforms:

```json
{
  "git/.gitconfig": {
    "target": "~/.gitconfig",
    "platforms": ["windows", "linux", "macos"]
  }
}
```

Rules:
- Keys mirror paths under `dotfiles/` (e.g., `nvim/init.lua`)
- `target` supports `~` for the home directory
- `platforms` controls which OSes a mapping applies to

Keys are path identifiers, not necessarily directories. A key such as `git` or `wezterm` can map a single source file.

| Action | PowerShell | Bash | Result |
|---|---|---|---|
| Preview | `-DryRun` | `--dry-run` | Print intended actions without changing targets. |
| Check | `-Check` | `--check` | Report missing, foreign, or broken targets; exit non-zero if any are found. |
| Force | `-Force` | `--force` | Back up and replace foreign targets. Without Force, refuse replacement. |
| Filter | `-Only <key>` | `--only <key>` | Process one mapping key. |
| Uninstall | `-Uninstall` | `--uninstall` | Remove repo-owned links only. |

On Windows, if symlink creation fails, the installer falls back to copying the file/folder.
Backups of replaced targets are stored under `.backup/` and can contain personal configuration data.
`--uninstall` / `-Uninstall` can remove a managed link even if its source has been deleted.

## Adding More Dotfiles
Use `add-dotfile.ps1` to copy the source into `dotfiles/` and update the map:

```powershell
pwsh ./add-dotfile.ps1 -Source "$HOME\.config\nvim" -Key "nvim" -Target "~/.config/nvim"
```

```bash
./add-dotfile.sh "$HOME/.config/nvim" "nvim" "~/.config/nvim" "linux,macos"
```

`add-dotfile.ps1` follows symlinks. If the symlink target is outside `$HOME`, it prompts for confirmation.
With `-DryRun`, it reports the external target without prompting or copying.

Both add helpers default to all supported platforms (`windows`, `linux`, `macos`).

```bash
./add-dotfile.sh "$HOME/.config/nvim" "nvim" "~/.config/nvim"
```

PowerShell examples:

```powershell
# Explicit platforms
pwsh ./add-dotfile.ps1 -Source "$HOME\.config\nvim" -Key "nvim" -Target "~/.config/nvim" -Platforms windows,linux,macos
```

```powershell
# Symlink outside HOME prompts for confirmation
pwsh ./add-dotfile.ps1 -Source "$HOME\.config\some-link" -Key "some-link" -Target "~/.config/some-link"
```

Dry run and explicit platforms:

```bash
./add-dotfile.sh "$HOME/.config/nvim" "nvim" "~/.config/nvim" --platforms=linux,macos --dry-run
pwsh ./add-dotfile.ps1 -Source "$HOME/.config/nvim" -Key "nvim" -Target "~/.config/nvim" -DryRun
```

## Safety Notes
- Review `dotfiles.map.json` before running `-Force`.
- Do not store secrets in `dotfiles/`. Keep them in secure stores or local-only files.

## Contributing
See `AGENTS.md` for contributor guidelines.
