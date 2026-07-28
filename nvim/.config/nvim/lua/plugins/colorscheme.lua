return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- same flavour as starship/eza/bat/tmux/lazygit
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        telescope = true,
        which_key = true,
        mason = true,
        noice = true,
        notify = true,
        native_lsp = { enabled = true },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
