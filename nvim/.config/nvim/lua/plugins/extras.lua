-- Language support: Python (primary, per this project) + shell/config langs.
--
-- The lazyvim.plugins.extras.lang.{json,yaml,markdown,python} imports live in
-- config/lazy.lua (LazyVim requires extras imports to sit between
-- lazyvim.plugins and your own plugins/, not nested inside plugins/ itself).
-- This file only holds the bits with no dedicated LazyVim extra: Bash.
return {
  -- Bash: LazyVim has no dedicated "lang.shell" extra, so wire up
  -- bash-language-server (needs npm — see install.sh's node/npm warning)
  -- plus shellcheck (lint) and shfmt (format) manually.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "shellcheck", "shfmt" },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },
}
