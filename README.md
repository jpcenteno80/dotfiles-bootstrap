# dotfiles-bootstrap

One-liner to set up a new Linux machine with my dev environment.

## Usage

### Standard (sudo + apt available)

```bash
curl -fsSL https://raw.githubusercontent.com/jpcenteno80/dotfiles-bootstrap/main/bootstrap.sh | bash
```

### Restricted servers (no sudo)

```bash
DOTFILES_NO_SUDO=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/jpcenteno80/dotfiles-bootstrap/main/bootstrap.sh)"
```

The `bash -c "$(curl …)"` form is required when setting the env var. Pipe-to-bash strips the variable.

In no-sudo mode, the installer expects `zsh`, `git`, `curl`, and `wget` to already be present. It will install everything else (ripgrep, bat, fzf, direnv, gh, tmux, AWS CLI, pyenv, nvm, Claude Code) under `~/.local`. If `tmux` is missing, it will be built from source, which requires `gcc` and `make` on the box.

## What it does

Both modes generate an SSH key (prompting you to add it to GitHub), clone the private dotfiles repo, and run the full install.
