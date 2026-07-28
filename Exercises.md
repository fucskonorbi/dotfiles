# Exercises

Hands-on tasks to build muscle memory for the new tools. Do them in order,
in a scratch directory so you don't need to worry about breaking anything:

```sh
mkdir -p /tmp/dotfiles-exercises && cd /tmp/dotfiles-exercises
```

Try to solve each one yourself before checking the Answers section at the
bottom.

---

### 1. Alt+Backspace behavior

Type (don't press enter):

```
echo foo/bar_baz
```

Press `alt+backspace` **once**. What's left on the line?
Press it two more times. What's left after each press?

---

### 2. eza basics

Create this structure:

```sh
mkdir -p demo/{src,docs} && touch demo/src/main.py demo/docs/readme.txt demo/.hidden
cd demo
```

- List the directory with icons and directories grouped first.
- List it again including the hidden file.
- Show it as a 2-level tree.

---

### 3. bat vs cat

```sh
printf 'def add(a, b):\n    return a + b\n' > demo/src/main.py
```

- View `demo/src/main.py` with syntax highlighting and line numbers.
- View only line 2 of that file.

---

### 4. ripgrep

```sh
mkdir -p project/{app,tests}
printf 'print("hello")\n# TODO: refactor this\n' > project/app/main.py
printf '# TODO: write tests\n' > project/tests/test_main.py
printf 'not python\nTODO here too\n' > project/notes.txt
```

- Find every `TODO` in `project/`.
- Find every `TODO` but only in `.py` files.
- Just list which *files* contain `TODO`, not the matching lines themselves.

---

### 5. fd

Using the same `project/` folder from exercise 4:

- Find all `.py` files under `project/`.
- Find all files (of any type) with "test" in the name.

---

### 6. zoxide

```sh
mkdir -p /tmp/dotfiles-exercises/a/b/c
cd /tmp/dotfiles-exercises/a/b/c
cd /tmp/dotfiles-exercises
```

You just visited `a/b/c`. Without typing the full path, jump straight back
into it using zoxide, from wherever you currently are.

---

### 7. fzf

- Press `ctrl-r` and fuzzy-search your shell history for a command you ran
  earlier in this exercise set (e.g. search for "rg").
- Press `ctrl-t` in the middle of typing a command (e.g. after typing
  `bat `) to fuzzy-pick a file from the current directory instead of
  typing the path yourself.

---

### 8. tmux

- Start a new named tmux session called `exercise`.
- Split the window into two panes side-by-side.
- Move focus to the left pane using the vim-style keybinding (no arrow keys).
- Detach from the session (keep it running).
- List running tmux sessions from *outside* tmux to confirm `exercise` is
  still alive.
- Reattach to it.

---

### 9. git + delta

```sh
cd /tmp/dotfiles-exercises
git init demo-repo && cd demo-repo
printf 'line one\nline two\nline three\n' > file.txt
git add . && git commit -m "initial" -q
printf 'line one\nline TWO changed\nline three\n' > file.txt
```

- View the diff of your uncommitted change. What's different visually
  from a plain `git diff` you might remember from before?

---

### 10. lazygit

Using the same `demo-repo` from exercise 9:

- Open lazygit.
- Stage `file.txt` from within the TUI (not the command line).
- Commit it from within the TUI.
- Quit back to the shell.

---

## Answers

<details>
<summary>1. Alt+Backspace</summary>

```
echo foo/bar_baz
alt+backspace →  echo foo/bar_          (deleted "baz")
alt+backspace →  echo foo/              (deleted "bar_")
alt+backspace →  echo                    (deleted "foo/")
```

This is because `.zshrc` runs `select-word-style bash`, which makes zsh
treat only alphanumerics as "word" characters (like bash does), instead of
zsh's default `WORDCHARS` which lumps `/`, `_`, `-`, `~` etc. in with word
characters and deletes across all of them in one go.
</details>

<details>
<summary>2. eza basics</summary>

```sh
ls demo            # eza --icons --group-directories-first
la demo             # + hidden files (.hidden shows up)
lt demo              # eza --tree --icons --level=2
```
</details>

<details>
<summary>3. bat vs cat</summary>

```sh
bat demo/src/main.py
bat -r 2:2 demo/src/main.py
```
</details>

<details>
<summary>4. ripgrep</summary>

```sh
rg TODO project/
rg TODO project/ -t py
rg TODO project/ -l
```
</details>

<details>
<summary>5. fd</summary>

```sh
fd -e py . project/
fd test project/
```
</details>

<details>
<summary>6. zoxide</summary>

```sh
z c
# or, if there are multiple "c" matches on your system:
zi c
```
`z` matches on any part of the path, ranked by frecency (frequency +
recency) — since `a/b/c` is the only/most recent match containing "c",
`z c` jumps straight there.
</details>

<details>
<summary>7. fzf</summary>

- `ctrl-r` opens a fuzzy history search; typing "rg" filters to lines
  containing it; `enter` puts the selected command on your prompt.
- `bat ` then `ctrl-t` opens a fuzzy file picker; selecting a file inserts
  its path after `bat `, so you never have to type/tab-complete it.
</details>

<details>
<summary>8. tmux</summary>

```sh
tmux new -s exercise
# inside tmux:
prefix |            # split vertically (side-by-side panes)
prefix h            # focus left pane
prefix d            # detach

# outside tmux:
tmux ls              # shows "exercise: 1 windows ..."
tmux attach -t exercise
```
</details>

<details>
<summary>9. git + delta</summary>

```sh
git diff
```
Instead of plain `+`/`-` colored lines, delta shows a **side-by-side**
view with syntax highlighting, per-character emphasis on the exact part
of the line that changed (e.g. just "two" → "TWO" highlighted, not the
whole line), and line numbers in the gutter for both old/new versions.
</details>

<details>
<summary>10. lazygit</summary>

```sh
lg
```
- Navigate to `file.txt` in the file list panel, press `space` to stage it.
- Press `c`, type a commit message, confirm.
- Press `q` to quit.
</details>
