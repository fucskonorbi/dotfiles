# Examples

Quick, practical usage examples for every tool in this setup. All of this
assumes you've run `install.sh` and opened a fresh terminal (or `exec zsh`).

## zsh + zinit

Plugins load automatically on shell start (`fast-syntax-highlighting`,
`zsh-autosuggestions`, `zsh-completions`, plus oh-my-zsh's `git`, `sudo`,
`command-not-found` snippets).

```sh
zinit times                 # see how long each plugin took to load
zinit update                # update all plugins
zinit self-update           # update zinit itself
```

- Start typing a command you've run before → suggestion appears in grey
  → press `→` (right arrow) or `End` to accept it.
- Press `Esc Esc` to prefix the current/previous command with `sudo`
  (from the `sudo` OMZ snippet).

### Shell line-editing (word boundaries)

`alt+backspace` / `alt+d` / `ctrl+w` now delete **one path/word segment at
a time** (stops at `/`, `_`, `-`, `.`), matching bash, instead of zsh's
default of eating the whole path in one go. See "Alt+Backspace behavior"
in Exercises.md for a hands-on check.

```
type: cd ~/projects/my_app/src
alt+backspace →  cd ~/projects/my_app/
alt+backspace →  cd ~/projects/my_app
alt+backspace →  cd ~/projects/
```

## starship

Nothing to run — it's your prompt. It shows OS icon, user, current
directory (truncated to 3 levels), git branch + status, and command
duration for anything slower than 2s, all in Catppuccin Mocha colors.

```sh
starship config             # open starship.toml in $EDITOR
starship explain            # explain what each prompt segment is showing
```

## tmux

Prefix key is the tmux default: `Ctrl-b`.

| Keys | Action |
|---|---|
| `prefix` `\|` | split pane vertically |
| `prefix` `-` | split pane horizontally |
| `prefix` `h/j/k/l` | move between panes (vim-style) |
| `prefix` `H/J/K/L` | resize pane |
| `prefix` `c` | new window |
| `prefix` `,` | rename window |
| `prefix` `d` | detach session |
| `prefix` `r` | reload tmux.conf |
| `prefix` `I` | (re)install plugins via TPM |
| `tm` | shell alias → attach/create the `main` session |

```sh
tmux new -s work            # start a named session
tmux ls                     # list sessions
tmux attach -t work         # reattach
```

Session contents survive reboots/crashes via `tmux-resurrect` +
`tmux-continuum` (auto-saves periodically, auto-restores on tmux start).

## fzf

Shell integration gives you three keybindings out of the box:

| Keys | Action |
|---|---|
| `ctrl-r` | fuzzy-search your shell history |
| `ctrl-t` | fuzzy-find a file, insert its path at the cursor |
| `alt-c` | fuzzy-find a directory, `cd` into it |

```sh
vim **<TAB>                 # fzf-powered path completion (any command)
git branch | fzf             # fzf pipes work with anything
```

## zoxide

Learns your most-used ("frecent") directories. `cd` is aliased to `z`.

```sh
cd projects/my_app/src      # visit a few times normally...
z app                       # ...then jump there from anywhere by partial name
z -                         # go to previous directory
zi app                      # interactive picker (fzf) when there are multiple matches
```

## ripgrep (`rg`, aliased from `grep`)

```sh
rg "TODO"                        # recursive search, respects .gitignore automatically
rg "TODO" -t py                   # only search Python files
rg "foo" -l                       # just list matching filenames
rg "foo" -A 3 -B 1                 # 3 lines after, 1 line before each match
rg -i "error" --stats              # case-insensitive + summary stats
```

Global options (`~/.config/ripgrep/config`) already set `--smart-case`,
`--hidden`, and exclude `.git/`.

## bat (`cat` replacement)

```sh
bat src/main.py                  # syntax-highlighted, with line numbers
bat -A file.txt                   # show non-printable chars (like cat -A)
bat -r 10:20 file.py               # only show lines 10-20
git diff | bat -l diff             # bat as a generic pretty-printer for any input
man ls                              # bat is already wired in as $MANPAGER
```

## eza (`ls`/`ll`/`la`/`lt` aliases)

```sh
ls                    # eza --icons --group-directories-first
ll                     # long format + git status column
la                     # long format + hidden files + git status
lt                      # tree view, 2 levels deep
eza -T -L 3 --git-ignore  # tree, 3 levels, skip gitignored files
```

## fd (`find` replacement)

```sh
fd main.py                  # find files named main.py
fd -e md                     # find all .md files
fd -H "\.env"                  # include hidden files
fd -x rm {}                     # find + execute a command on each result
```

## delta (git diff pager)

Nothing to invoke directly — already wired in as git's pager:

```sh
git diff                    # side-by-side, syntax-highlighted, Catppuccin colors
git show HEAD                # same, for a specific commit
git log -p                    # paginated diff-per-commit history
```

## lazygit (`lg` alias)

```sh
lg                           # open the TUI in the current repo
```

| Keys | Action |
|---|---|
| `space` | stage/unstage file or hunk |
| `c` | commit |
| `P` | push |
| `p` | pull |
| `↑/↓` or `j/k` | navigate |
| `tab` | switch panel focus |
| `q` | quit |
