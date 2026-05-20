-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local opts = {
        ensure_installed = {
          "bash", "css", "go", "html", "java", "javascript", "json",
          "kotlin", "lua", "markdown", "markdown_inline",
          "properties", "python", "swift", "tsx", "typescript", "vim",
          "vimdoc", "xml", "yaml",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      }

      -- Пробуем новый API (без s)
      local ok_new, ts_config = pcall(require, "nvim-treesitter.config")
      if ok_new then
        ts_config.setup(opts)
        return
      end

      -- Пробуем старый API (с s)
      local ok_old, ts_configs = pcall(require, "nvim-treesitter.configs")
      if ok_old then
        ts_configs.setup(opts)
        return
      end

      -- Если ничего не сработало
      vim.notify(
        "nvim-treesitter setup failed. Try :Lazy sync and restart",
        vim.log.levels.ERROR
      )
    end,
  },
}

