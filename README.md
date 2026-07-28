# dotfiles

Minimal, fast, consistently themed terminal setup (Catppuccin Mocha).

**Stack:** zsh + [zinit](https://github.com/zdharma-continuum/zinit) · [starship](https://starship.rs) · [tmux](https://github.com/tmux/tmux) (+ [TPM](https://github.com/tmux-plugins/tpm)) · [fzf](https://github.com/junegunn/fzf) · [zoxide](https://github.com/ajeetdsouza/zoxide) · [ripgrep](https://github.com/BurntSushi/ripgrep) · [bat](https://github.com/sharkdp/bat) · [eza](https://github.com/eza-community/eza) · [fd](https://github.com/sharkdp/fd) · [delta](https://github.com/dandavison/delta) · [lazygit](https://github.com/jesseduffield/lazygit)

## Install

```sh
git clone <this-repo-url> ~/dotfiles
~/dotfiles/install.sh
```

That's it. The script:

1. Installs every CLI tool:
   - **macOS** → via Homebrew.
   - **Linux** → downloads static (mostly musl) binaries straight from each
     project's GitHub releases into `~/.local/bin`. No `sudo`/`apt` needed —
     this is what makes the exact same script work on a locked-down
     corporate machine and on a personal box with root.
2. Symlinks every config into `$HOME`, mirroring GNU `stow`'s behavior
   (`stow -R -t ~ <package>`) for each package folder (`zsh/`, `tmux/`,
   `git/`, ...). If real `stow` is installed (macOS via brew, or any Linux
   box where you do have `apt install stow`), it's used directly. If not
   available, `bin/link.sh` — a ~30-line stand-in with identical semantics —
   is used instead, so the repo never *requires* stow to be installed.
3. Installs `zinit` (zsh plugin manager, plain `git clone`, no binary needed).
4. Installs the Catppuccin Mocha theme for `bat` (also used by `delta`,
   which reuses bat's theme cache) and rebuilds bat's theme cache.
5. Tries to set zsh as your login shell (`chsh`). If that fails because you
   don't have permission (common on corporate machines), it instead appends
   a small `exec zsh` snippet to `.bashrc` so zsh launches automatically
   whenever you open a terminal — no admin rights required.

Re-running `install.sh` any time is safe/idempotent.

## First run of tmux

The first time you start `tmux`, it self-bootstraps TPM and installs its
plugins automatically (via a `run` hook in `tmux.conf`). If for any reason
that doesn't trigger, press `prefix + I` (capital i) inside tmux to install
plugins manually.

## Repo layout (stow packages)

```
zsh/.zshrc
starship/.config/starship.toml
tmux/.config/tmux/tmux.conf
git/.gitconfig
bat/.config/bat/config
eza/.config/eza/theme.yml
lazygit/.config/lazygit/config.yml
ripgrep/.config/ripgrep/config
```

Each top-level directory is a "package": its internal path structure is
exactly what gets recreated (as symlinks) under `$HOME`. To add a new tool,
create a new top-level folder with the right path inside it and add its
name to the `PACKAGES` array in `install.sh`.

## Adding a machine

```sh
git clone <this-repo-url> ~/dotfiles
~/dotfiles/install.sh
```

Same command everywhere: work laptop with no sudo, personal Linux box,
or macOS with full admin rights.

## Nerd Font (required for icons)

`starship`, `eza --icons`, and the tmux/lazygit glyphs need a
[Nerd Font](https://www.nerdfonts.com/) installed and selected in your
terminal emulator's settings — this can't be automated portably across
terminal apps, so:

- **macOS**: `install.sh` already installs `font-jetbrains-mono-nerdfont`
  via Homebrew — just select "JetBrainsMono Nerd Font" in your terminal's
  preferences.
- **Linux / no sudo**: download a Nerd Font zip from
  https://www.nerdfonts.com/font-downloads, unzip into
  `~/.local/share/fonts`, run `fc-cache -f`, then select it in your
  terminal emulator (this repo doesn't do it for you since most corporate
  Linux boxes are accessed via a local terminal emulator like iTerm2,
  Windows Terminal, or VS Code's integrated terminal — configure the font
  there).

## Alternate themes

Everything here is themed with **Catppuccin Mocha** hex codes, hand-written
directly into each tool's config (no external theme-fetching at runtime,
so nothing breaks if a repo disappears). If you'd rather use a different
palette, these are equally popular and have first-class community support
across this exact tool list — swap the hex values / theme names:

- [Tokyo Night](https://github.com/folke/tokyonight.nvim) — `tokyonight`
  ports exist for starship, tmux, fzf, bat, delta, lazygit.
- [Gruvbox](https://github.com/morhetz/gruvbox) — very mature, same coverage.
- [Nord](https://www.nordtheme.com/) — cooler/lower-contrast, same coverage.

To switch: replace the `palette`/hex values in `starship/.config/starship.toml`,
the `@catppuccin_*` options in `tmux/.config/tmux/tmux.conf` (swap the
`catppuccin/tmux` plugin for e.g. `folke/tokyonight.nvim`'s tmux port or
`nordtheme/tmux`), `BAT_THEME` in `zsh/.zshrc`, and the theme download URL
in `install.sh`'s `install_bat_theme`.

## Shell aliases worth knowing

| alias | does |
|---|---|
| `ls` / `ll` / `la` / `lt` | `eza` variants (icons, git status, tree) |
| `cat` | `bat` |
| `cd` | `zoxide` (`z`) — learns your frecent directories |
| `grep` | `rg` |
| `lg` | `lazygit` |
| `tm` | attach/create the `main` tmux session |
| `ctrl-r` | fzf fuzzy history search |
| `ctrl-t` | fzf fuzzy file finder (respects `.gitignore` via `fd`) |

## Learn the tools

- [`Examples.md`](Examples.md) — practical usage examples for every tool.
- [`Exercises.md`](Exercises.md) — hands-on tasks to build muscle memory,
  with answers at the bottom.
