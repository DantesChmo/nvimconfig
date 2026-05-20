-- return {
--   -- Copilot и интеграция с nvim-cmp
--   {
--     "zbirenbaum/copilot-cmp",
--     dependencies = { "github/copilot.vim", "hrsh7th/nvim-cmp" },
--     config = function()
--       require("copilot_cmp").setup()
--     end
--   },
--
--   -- Git интеграция с copilot
--   {
--     "github/copilot.vim",
--     config = function()
--       -- Включить автодополнение Copilot
--       vim.g.copilot_no_tab_map = true       -- отключаем стандартное Tab поведение
--       vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
--       vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Next()', { silent = true, expr = true })
--       vim.api.nvim_set_keymap("i", "<C-L>", 'copilot#Previous()', { silent = true, expr = true })
--     end
--   },
--
--   -- Copilot Chat: чат с AI внутри Neovim
--   {
--     "CopilotC-Nvim/CopilotChat.nvim",
--     dependencies = {
--       "github/copilot.vim",
--       "nvim-lua/plenary.nvim",
--     },
--     opts = {
--       model = "gpt-4o",
--     },
--     config = function ()
--       -- Copilot Chat
--       vim.keymap.set("n", "<leader>ai", function()
--         vim.cmd("CopilotChat")
--       end)
--       -- Объяснение кода с помощью Copilot Chat
--       vim.keymap.set("v", "<leader>ad", function()
--         vim.cmd("CopilotChatExplain")
--       end)
--     end
--   },
-- }


return {
  -- Автодополнение через твой сервер
  {
    "tzachar/cmp-ai",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local cmp_ai = require("cmp_ai.config")
      cmp_ai:setup({
        max_lines = 100,
        provider = "OpenAI",
        provider_options = {
          base_url = "https://api-copilot.x5.ru/aigw/v1/completions",
          model = "copilot-code-large",
          api_key = os.getenv("X5_API_KEY"),
          -- убираем функции, просто строки
          prompt = "code completion",
          max_tokens = 256,
          temperature = 0,
          stop = { "\n\n" },
        },
        notify = true,
        notify_callback = function(msg)
          vim.notify(msg)
        end,
        run_on_every_keystroke = true,
        ignored_file_types = {},
      })
    end,
  },

  -- Чат через твой сервер
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          x5 = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "x5",
              env = {
                url = "https://api-copilot.x5.ru/aigw/v1",
                api_key = "X5_API_KEY",
                chat_url = "/chat/completions",
              },
              schema = {
                model = {
                  default = "copilot-code-large",
                },
              },
            })
          end,
        },

        display = {
          chat = {
            show_settings = true,
          },
        },

        strategies = {
          chat = { adapter = "x5" },
          inline = { adapter = "x5" },
          agent = { adapter = "x5" },
        },
      })

      vim.keymap.set("n", "<leader>ai", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI Chat" })
      vim.keymap.set("v", "<leader>ad", "<cmd>CodeCompanionChat Add<cr>", { desc = "AI Add selection" })
      vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions" })
    end,
  },
}

