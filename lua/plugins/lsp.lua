-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  -- Swift плагин для Neovim
  {
    "devswiftzone/swift.nvim",
    ft = "swift",  -- загружается только при открытии .swift
    config = function()
      require("swift").setup({
        -- здесь можно указать дополнительные опции
        -- например: auto_open_scheme_picker = true
      })
    end,
  },

  -- Mason Tool Installer: ставит инструменты, которые НЕ настраиваются через mason-lspconfig
  -- (jdtls запускается через nvim-jdtls, java-debug-adapter и java-test — DAP-бандлы,
  -- google-java-format — форматтер для conform.nvim)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "jdtls",                 -- Java LSP
          "java-debug-adapter",    -- DAP-адаптер для Java
          "java-test",             -- бандл для запуска JUnit/TestNG в DAP
          "google-java-format",    -- форматтер для Java
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "folke/neodev.nvim", opts = {} },
    },
    config = function()
      -- Mason setup
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",           -- Go
          "ts_ls",           -- TypeScript/JavaScript
          "pyright",         -- Python
        --  "sourcekit",       -- Swift
          "kotlin_language_server", -- Kotlin
          "lua_ls",          -- Lua
          -- jdtls здесь НЕТ намеренно: его запускает nvim-jdtls из ftplugin/java.lua
        },
        automatic_installation = true,
      })

      -- Общие capabilities и on_attach для всех LSP-клиентов (включая jdtls)
      local lsp_shared = require("config.lsp_shared")
      local capabilities = lsp_shared.capabilities()
      local on_attach = lsp_shared.on_attach

      -- Используем vim.lsp.config для новых версий Neovim
      local lsp_config = vim.lsp.config

      -- Go
      lsp_config.gopls = {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.work", "go.mod", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      }

      -- TypeScript/JavaScript
      lsp_config.ts_ls = {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Python
      lsp_config.pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
            },
          },
        },
      }

      -- Swift
      lsp_config.sourcekit = {
        cmd = { "sourcekit-lsp" },
        filetypes = { "swift", "objective-c", "objective-cpp" },
        root_markers = { "Package.swift", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Kotlin
      lsp_config.kotlin_language_server = {
        cmd = { "kotlin-language-server" },
        filetypes = { "kotlin" },
        root_markers = { "settings.gradle", "settings.gradle.kts", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Lua
      lsp_config.lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = { enable = false },
          },
        },
      }

      -- Включаем серверы
      vim.lsp.enable("gopls")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("sourcekit")
      vim.lsp.enable("kotlin_language_server")
      vim.lsp.enable("lua_ls")

      -- Диагностика
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
      })

      -- Иконки диагностики
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    end,
  },

  -- Nvim-html-css: Подсветка CSS в HTML и JSX файлах
  {
    "Jezda1337/nvim-html-css",
    dependencies = {"nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp"},
    opts = {
      enable_on = { "html", "javascriptreact", "typescriptreact", "vue", "php", "svelte" },
      documentation = { auto_show = true },
    },
  },
}

