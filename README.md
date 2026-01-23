# dotfiles

A small, script-driven dotfiles repo with an idempotent installer and a simple mapping file.

## Features
- Stateless install: no bookkeeping, safe re-runs
- Cross-platform targeting (windows/linux/macos)
- Repo-owned symlinks; optional force overwrite of foreign targets
- Simple map file to define source-to-target links

## Repository Layout
- `dotfiles/`: Files and folders managed by this repo
- `dotfiles.map.json`: Mapping of repo paths to target paths
- `install.ps1`: Installer (link or copy on Windows if symlinks fail)
- `add-dotfile.ps1`: Helper to add files/folders and update the map
- `AGENTS.md`: Contributor guidelines

## Prerequisites
- PowerShell 7+ recommended (`pwsh`)

## Quick Start
1) Add a dotfile (file or directory):

```powershell
pwsh ./add-dotfile.ps1 -Source "$HOME\.gitconfig" -Key "git/.gitconfig" -Target "~/.gitconfig"
```

2) Dry run the install:

```powershell
pwsh ./install.ps1 -DryRun
```

3) Install:

```powershell
pwsh ./install.ps1
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

## Installer Behavior
- `-DryRun`: show actions without changes
- `-Check`: validate current targets and report missing/foreign items
- `-Force`: overwrite non-repo targets

On Windows, if symlink creation fails, the installer falls back to copying the file/folder.

## Adding More Dotfiles
Use `add-dotfile.ps1` to copy the source into `dotfiles/` and update the map:

```powershell
pwsh ./add-dotfile.ps1 -Source "$HOME\.config\nvim" -Key "nvim" -Target "~/.config/nvim"
```

## Safety Notes
- Review `dotfiles.map.json` before running `-Force`.
- Do not store secrets in `dotfiles/`. Keep them in secure stores or local-only files.

## Contributing
See `AGENTS.md` for contributor guidelines.
