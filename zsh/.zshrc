#!/usr/bin/env zsh
# ~/.zshrc — minimal, fast, batteries-included.

# --- Path ---
export PATH="$HOME/.local/bin:$PATH"

# --- History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY INC_APPEND_HISTORY

setopt AUTO_CD
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS

# --- Word boundaries (alt+backspace / alt+d / ctrl+w) ---
# zsh's default WORDCHARS (*?_-.[]~=/&;!#$%^(){}<>) treats "/", "_", "-", "~"
# as part of a "word", so alt+backspace deletes across whole path segments
# instead of stopping at each one, like it does in bash. `select-word-style
# bash` makes zsh use bash's rule instead (only alnums count as word chars),
# so alt+backspace/alt+d/ctrl+w stop at "/", "_", "-", "." etc.
autoload -Uz select-word-style
select-word-style bash

# --- zinit bootstrap (auto-installs itself if missing) ---
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# --- Plugins (lazy/turbo loaded for fast startup) ---
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# --- fzf ---
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
fi

# Catppuccin Mocha colors for fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#313244,label:#cdd6f4 \
--height=40% --layout=reverse --border=rounded"

command -v fd >/dev/null 2>&1 && export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# --- zoxide (smarter cd) ---
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd="z"
fi

# --- ripgrep config ---
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# --- bat as manpager / cat replacement ---
if command -v bat >/dev/null 2>&1; then
    alias cat="bat --paging=never"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export BAT_THEME="Catppuccin Mocha"
fi

# --- eza (ls replacement) ---
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -l --icons --group-directories-first --git"
    alias la="eza -la --icons --group-directories-first --git"
    alias lt="eza --tree --icons --level=2"
fi

# --- misc quality-of-life aliases ---
if command -v nvim >/dev/null 2>&1; then
    alias vim="nvim"
    export EDITOR="nvim"
    export VISUAL="nvim"
else
    export EDITOR="vim"
    export VISUAL="vim"
fi
alias lg="lazygit"
alias tm="tmux new-session -A -s main"
alias grep="rg"

export PATH=$HOME/.opencode/bin:$PATH

# --- vibeup / vibedown: throwaway git worktrees for opencode sessions ---
# vibeup <branch_name>   creates ~/git_worktrees/<repo>/<branch_name> as a new
#                        worktree branched off the current HEAD, inits
#                        submodules, and launches opencode in it.
# vibedown <branch_name> removes that worktree again.
_vibe_repo_name() {
    # --git-common-dir always resolves to the *main* repo's .git dir, even
    # when run from inside a linked worktree, so this works from either.
    local common_dir
    common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
    basename "$(dirname "$common_dir")"
}

vibeup() {
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        echo "vibeup: usage: vibeup <branch_name>" >&2
        return 1
    fi
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "vibeup: not inside a git repository" >&2
        return 1
    fi

    local repo_name worktree_dir
    repo_name=$(_vibe_repo_name) || return 1
    worktree_dir="$HOME/git_worktrees/$repo_name/$branch_name"

    if [ -e "$worktree_dir" ]; then
        echo "vibeup: worktree dir already exists: $worktree_dir" >&2
        return 1
    fi

    mkdir -p "$(dirname "$worktree_dir")"

    echo "vibeup: creating worktree '$branch_name' off $(git branch --show-current) at $worktree_dir"
    git worktree add -b "$branch_name" "$worktree_dir" || return 1

    (
        cd "$worktree_dir" || exit 1

        if [ -f .gitmodules ]; then
            echo "vibeup: initializing submodules..."
            git submodule update --init --recursive
        fi

        # TODO: placeholder for per-project setup (install deps, copy env
        # files, run codegen, etc.) — edit me.

        opencode
    )
}

vibedown() {
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        echo "vibedown: usage: vibedown <branch_name>" >&2
        return 1
    fi
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "vibedown: not inside a git repository" >&2
        return 1
    fi

    local repo_name worktree_dir
    repo_name=$(_vibe_repo_name) || return 1
    worktree_dir="$HOME/git_worktrees/$repo_name/$branch_name"

    if [ ! -d "$worktree_dir" ]; then
        echo "vibedown: no worktree found at $worktree_dir" >&2
        return 1
    fi

    git worktree remove "$worktree_dir" --force \
        && echo "vibedown: removed worktree $worktree_dir"
}

# --- starship prompt (must be last) ---
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

