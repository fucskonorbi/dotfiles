#!/usr/bin/env bash
# install.sh — bootstraps this dotfiles repo on a fresh machine.
#
#   macOS (sudo available):  uses Homebrew for everything.
#   Linux with sudo:         still uses portable static binaries (musl where
#                             possible) so behaviour is identical with/without
#                             root — no apt/dnf version drift between machines.
#   Linux without sudo:      same static-binary path, installed into
#                             ~/.local/bin (already expected to be on PATH).
#
# Safe to re-run (idempotent): skips anything already installed/linked.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
OPT_DIR="$HOME/.local/opt"
PACKAGES=(zsh starship tmux git bat eza lazygit ripgrep nvim opencode)

mkdir -p "$BIN_DIR" "$OPT_DIR" "$HOME/.config"

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

OS="$(uname -s)"
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
    x86_64|amd64) ARCH=amd64 ;;
    arm64|aarch64) ARCH=arm64 ;;
    *) warn "Unsupported arch: $ARCH_RAW"; ARCH=amd64 ;;
esac

# ---------------------------------------------------------------------------
# macOS: Homebrew path
# ---------------------------------------------------------------------------
install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    fi
    log "Installing packages via Homebrew..."
    brew install --quiet \
        zsh tmux git stow starship fzf zoxide ripgrep bat eza fd git-delta lazygit neovim \
        font-jetbrains-mono-nerdfont 2>&1 | tail -n 50 || true
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Linux: portable static-binary path (GitHub releases), no sudo required.
# ---------------------------------------------------------------------------
gh_latest_tag() {
    # gh_latest_tag <owner/repo>  -- resolves the redirect of .../releases/latest
    # instead of hitting the (much more rate-limited) api.github.com, and
    # returns the tag name, e.g. "v1.2.3".
    curl -fsSIL "https://github.com/$1/releases/latest" \
        | tr -d '\r' \
        | grep -i '^location:' \
        | sed -E 's#.*/releases/tag/(.+)$#\1#' \
        | tail -n1
}

install_from_tarball() {
    # install_from_tarball <owner/repo> <asset-name-template> <binary-name>
    # <asset-name-template> may contain the literal token TAG or TAG_NOV
    # (TAG without a leading "v"), which get substituted with the resolved
    # release tag before downloading.
    local repo="$1" name_template="$2" bin_name="$3"
    if command -v "$bin_name" >/dev/null 2>&1; then
        log "$bin_name already installed, skipping"
        return
    fi
    local tag tag_nov asset url
    tag="$(gh_latest_tag "$repo")"
    if [ -z "$tag" ]; then
        warn "Could not resolve latest release tag for $bin_name ($repo), skipping"
        return
    fi
    tag_nov="${tag#v}"
    asset="${name_template//TAG_NOV/$tag_nov}"
    asset="${asset//TAG/$tag}"
    url="https://github.com/$repo/releases/download/$tag/$asset"
    log "Installing $bin_name from $url"
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL "$url" -o "$tmp/asset.tar.gz"
    tar -xzf "$tmp/asset.tar.gz" -C "$tmp"
    local found
    found="$(find "$tmp" -type f -name "$bin_name" | head -n1)"
    if [ -z "$found" ]; then
        warn "Couldn't locate '$bin_name' binary inside archive for $repo"
        rm -rf "$tmp"
        return
    fi
    install -m 755 "$found" "$BIN_DIR/$bin_name"
    rm -rf "$tmp"
}

install_fzf_tmux_script() {
    # fzf-tmux is a plain shell script (not a compiled binary), so it's never
    # bundled in fzf's per-arch release tarballs — only in the fzf git repo
    # itself (bin/fzf-tmux). tmux-sessionx requires it, so fetch it directly.
    if command -v fzf-tmux >/dev/null 2>&1; then
        log "fzf-tmux already installed, skipping"
        return
    fi
    if ! command -v fzf >/dev/null 2>&1; then
        return
    fi
    log "Installing fzf-tmux helper script..."
    curl -fsSL "https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux" \
        -o "$BIN_DIR/fzf-tmux"
    chmod 755 "$BIN_DIR/fzf-tmux"
}

install_linux() {
    log "Installing CLI tools as static binaries into $BIN_DIR ..."
    if [ "$ARCH" = amd64 ]; then
        install_from_tarball starship/starship            'starship-x86_64-unknown-linux-musl.tar.gz'        starship
        install_from_tarball junegunn/fzf                  'fzf-TAG_NOV-linux_amd64.tar.gz'                   fzf
        install_fzf_tmux_script
        install_from_tarball ajeetdsouza/zoxide            'zoxide-TAG_NOV-x86_64-unknown-linux-musl.tar.gz'  zoxide
        install_from_tarball BurntSushi/ripgrep            'ripgrep-TAG_NOV-x86_64-unknown-linux-musl.tar.gz' rg
        install_from_tarball sharkdp/bat                   'bat-TAG-x86_64-unknown-linux-musl.tar.gz'         bat
        install_from_tarball eza-community/eza             'eza_x86_64-unknown-linux-musl.tar.gz'             eza
        install_from_tarball sharkdp/fd                    'fd-TAG-x86_64-unknown-linux-musl.tar.gz'          fd
        install_from_tarball dandavison/delta              'delta-TAG_NOV-x86_64-unknown-linux-musl.tar.gz'   delta
        install_from_tarball jesseduffield/lazygit          'lazygit_TAG_NOV_linux_x86_64.tar.gz'              lazygit
        install_neovim 'nvim-linux-x86_64.tar.gz' 'nvim-linux-x86_64'
    else
        install_from_tarball starship/starship            'starship-aarch64-unknown-linux-musl.tar.gz'       starship
        install_from_tarball junegunn/fzf                  'fzf-TAG_NOV-linux_arm64.tar.gz'                   fzf
        install_fzf_tmux_script
        install_from_tarball ajeetdsouza/zoxide            'zoxide-TAG_NOV-aarch64-unknown-linux-musl.tar.gz' zoxide
        install_from_tarball BurntSushi/ripgrep            'ripgrep-TAG_NOV-aarch64-unknown-linux-musl.tar.gz' rg
        install_from_tarball sharkdp/bat                   'bat-TAG-aarch64-unknown-linux-gnu.tar.gz'         bat
        install_from_tarball eza-community/eza             'eza_aarch64-unknown-linux-gnu.tar.gz'             eza
        install_from_tarball sharkdp/fd                    'fd-TAG-aarch64-unknown-linux-musl.tar.gz'         fd
        install_from_tarball dandavison/delta              'delta-TAG_NOV-aarch64-unknown-linux-gnu.tar.gz'   delta
        install_from_tarball jesseduffield/lazygit          'lazygit_TAG_NOV_linux_arm64.tar.gz'               lazygit
        install_neovim 'nvim-linux-arm64.tar.gz' 'nvim-linux-arm64'
    fi

    install_nerd_font

    if ! command -v zsh >/dev/null 2>&1;  then warn "zsh not found — ask your admin to install it, or use a Linux distro that ships it."; fi
    if ! command -v tmux >/dev/null 2>&1; then warn "tmux not found — ask your admin to install it, or use a Linux distro that ships it."; fi
    if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
        warn "node/npm not found — Neovim's bash/yaml/json LSP servers (installed on-demand by mason.nvim) need npm and will fail to install without it. Python (pyright/ruff) is unaffected."
    fi

    # Real GNU stow is not distributed as a static binary; we transparently
    # fall back to bin/link.sh (see link_packages below) when it's missing.
    if ! command -v stow >/dev/null 2>&1; then
        warn "GNU stow not found (expected on a no-sudo box) — using bundled bin/link.sh instead."
    fi
}

# ---------------------------------------------------------------------------
# Neovim: unlike the other tools, the binary isn't standalone — it looks up
# its bundled runtime/ tree relative to its own real path. So we extract the
# full release tree into ~/.local/opt/nvim and just symlink the bin/nvim
# entrypoint into ~/.local/bin (symlinks resolve fine, tested).
# ---------------------------------------------------------------------------
install_neovim() {
    local asset="$1" extracted_dirname="$2"
    if command -v nvim >/dev/null 2>&1; then
        log "nvim already installed, skipping"
        return
    fi
    local tag url tmp
    tag="$(gh_latest_tag neovim/neovim)"
    if [ -z "$tag" ]; then
        warn "Could not resolve latest release tag for neovim, skipping"
        return
    fi
    url="https://github.com/neovim/neovim/releases/download/$tag/$asset"
    log "Installing neovim from $url"
    tmp="$(mktemp -d)"
    curl -fsSL "$url" -o "$tmp/nvim.tar.gz"
    tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
    rm -rf "$OPT_DIR/nvim"
    mv "$tmp/$extracted_dirname" "$OPT_DIR/nvim"
    ln -sf "$OPT_DIR/nvim/bin/nvim" "$BIN_DIR/nvim"
    rm -rf "$tmp"
}

# ---------------------------------------------------------------------------
# tree-sitter CLI — nvim-treesitter's "main" branch (used by LazyVim) needs
# this to compile parsers, and prefers any `tree-sitter` already on PATH over
# installing its own via mason. Mason's own copy (and the latest npm release)
# is a prebuilt binary requiring glibc >= 2.39, which fails hard on older
# distros (e.g. Ubuntu 22.04's glibc 2.35 — confirmed on this machine). Pinning
# to an older tree-sitter-cli release compiles/runs fine everywhere, so we
# install this ourselves into ~/.local (ahead of mason's) rather than relying
# on whatever mason would fetch.
# ---------------------------------------------------------------------------
install_treesitter_cli() {
    if command -v tree-sitter >/dev/null 2>&1; then
        log "tree-sitter CLI already installed, skipping"
        return
    fi
    if ! command -v npm >/dev/null 2>&1; then
        warn "npm not found — skipping tree-sitter CLI install. nvim-treesitter parser compilation may fail; LSP/completion are unaffected, only syntax highlighting falls back to Vim's regex-based highlighting."
        return
    fi
    log "Installing tree-sitter CLI (pinned to a glibc-compatible version)..."
    npm install -g tree-sitter-cli@0.24.7 --prefix "$HOME/.local" >/dev/null 2>&1 \
        || warn "tree-sitter CLI install failed — nvim-treesitter parser compilation may not work."
}

# ---------------------------------------------------------------------------
# JetBrainsMono Nerd Font — needed for eza/starship icons to render (macOS
# gets it via Homebrew cask in install_macos; this is the Linux/no-sudo path).
# User-level install into ~/.local/share/fonts, no root required. You still
# need to select "JetBrainsMono Nerd Font" as your *terminal emulator's* font
# for the icons to actually show up — this only makes the font available.
# ---------------------------------------------------------------------------
install_nerd_font() {
    local fonts_dir="$HOME/.local/share/fonts/JetBrainsMono"
    if [ -d "$fonts_dir" ] && [ -n "$(ls -A "$fonts_dir" 2>/dev/null)" ]; then
        log "JetBrainsMono Nerd Font already installed, skipping"
        return
    fi
    log "Installing JetBrainsMono Nerd Font..."
    local tmp
    tmp="$(mktemp -d)"
    if ! curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip" -o "$tmp/JetBrainsMono.zip"; then
        warn "Could not download JetBrainsMono Nerd Font, skipping (eza/starship icons won't render without it)."
        rm -rf "$tmp"
        return
    fi
    mkdir -p "$fonts_dir"
    if command -v unzip >/dev/null 2>&1; then
        unzip -q "$tmp/JetBrainsMono.zip" -d "$tmp/extracted"
        find "$tmp/extracted" -name '*.ttf' -exec cp {} "$fonts_dir/" \;
    else
        warn "unzip not found — skipping JetBrainsMono Nerd Font install."
    fi
    rm -rf "$tmp"
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
    fi
}

# ---------------------------------------------------------------------------
# Symlinking
# ---------------------------------------------------------------------------
link_packages() {
    log "Linking dotfiles into \$HOME ..."
    if command -v stow >/dev/null 2>&1; then
        for pkg in "${PACKAGES[@]}"; do
            stow -v -R -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
        done
    else
        for pkg in "${PACKAGES[@]}"; do
            bash "$DOTFILES_DIR/bin/link.sh" "$DOTFILES_DIR" "$pkg" "$HOME"
        done
    fi
}

# ---------------------------------------------------------------------------
# zinit (zsh plugin manager) — plain git clone, works everywhere
# ---------------------------------------------------------------------------
install_zinit() {
    local zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
    if [ ! -d "$zinit_home" ]; then
        log "Installing zinit..."
        mkdir -p "$(dirname "$zinit_home")"
        git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$zinit_home"
    fi
}

# ---------------------------------------------------------------------------
# bat theme cache (Catppuccin Mocha) — shared by bat AND delta
# ---------------------------------------------------------------------------
install_bat_theme() {
    if ! command -v bat >/dev/null 2>&1; then return; fi
    local themes_dir
    themes_dir="$(bat --config-dir)/themes"
    mkdir -p "$themes_dir"
    if [ ! -f "$themes_dir/Catppuccin Mocha.tmTheme" ]; then
        log "Installing Catppuccin Mocha theme for bat/delta..."
        curl -fsSL -o "$themes_dir/Catppuccin Mocha.tmTheme" \
            "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme"
        bat cache --build >/dev/null 2>&1 || true
    fi
}

# ---------------------------------------------------------------------------
# Default shell
# ---------------------------------------------------------------------------
set_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh || true)"
    [ -z "$zsh_path" ] && return
    if [ "$SHELL" = "$zsh_path" ]; then return; fi

    if grep -qxF "$zsh_path" /etc/shells 2>/dev/null && chsh -s "$zsh_path" 2>/dev/null; then
        log "Default shell changed to zsh ($zsh_path). Log out/in to take effect."
    else
        warn "Couldn't run chsh (no permissions?). Falling back to auto-exec zsh from .bashrc."
        local marker="# >>> auto-launch zsh (dotfiles) >>>"
        if ! grep -qF "$marker" "$HOME/.bashrc" 2>/dev/null; then
            {
                echo ""
                echo "$marker"
                echo "if [ -t 1 ] && command -v zsh >/dev/null 2>&1 && [ -z \"\$ZSH_VERSION\" ]; then"
                echo "  exec zsh"
                echo "fi"
                echo "# <<< auto-launch zsh (dotfiles) <<<"
            } >> "$HOME/.bashrc"
        fi
    fi
}

main() {
    log "Detected OS=$OS ARCH=$ARCH_RAW"
    if [ "$OS" = "Darwin" ]; then
        install_macos
    else
        install_linux
    fi
    install_zinit
    link_packages
    install_bat_theme
    install_treesitter_cli
    set_default_shell
    log "Done. Open a new terminal (or run 'exec zsh'), then launch tmux once to auto-install plugins."
}

main "$@"
