return {
  -- Fzf-lua: Быстрый поиск и навигация
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local fzf = require('fzf-lua')

      fzf.setup({
        "fzf-native",
        winopts = {
          height = 0.85,
          width = 0.80,
          preview = {
            layout = "vertical",
          },
        },
      })

      -- Горячие клавиши для FZF
      vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Files" })
      vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Grep" })
      vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Help" })
      vim.keymap.set("n", "<leader>fc", fzf.commands, { desc = "Commands" })

      -- FZF для просмотра Docker контейнеров и логов
      vim.keymap.set("n", "<leader>dps", function()
        fzf.fzf_exec("docker ps --format '{{.Names}}'", {
          prompt = "Containers> ",
          actions = {
            ["default"] = function(selected)
              vim.cmd("ToggleTerm cmd='docker logs -f " .. selected[1] .. "'")
            end,
          },
        })
      end)

      -- FZF для просмотра Docker Compose сервисов
      local function compose_services()
        return "docker compose ps --services"
      end

      -- FZF для запуска Docker Compose сервисов
      vim.keymap.set("n", "<leader>dcu", function()
        fzf.fzf_exec(compose_services(), {
          prompt = "Compose UP> ",
          actions = {
            ["default"] = function(sel)
              vim.cmd("ToggleTerm cmd='docker compose up -d " .. sel[1] .. "'")
            end,
          },
        })
      end)


      -- FZF для остановки Docker Compose сервисов
      vim.keymap.set("n", "<leader>cl", function()
        fzf.fzf_exec(compose_services(), {
          prompt = "Compose LOGS> ",
          actions = {
            ["default"] = function(sel)
              vim.cmd("ToggleTerm cmd='docker compose logs -f " .. sel[1] .. "'")
            end,
          },
        })
      end)

      -- FZF для остановки всех Docker Compose сервисов
      vim.keymap.set("n", "<leader>cd", function()
        vim.cmd("ToggleTerm cmd='docker compose down'")
      end)

      -- FZF для просмотра k9s в терминале
      vim.keymap.set("n", "<leader>kk", function()
        require("toggleterm.terminal").Terminal
          :new({ cmd = "k9s", hidden = true })
          :toggle()
      end)

      -- Горячие клавиши для FZF диагностики
      vim.keymap.set("n", "<leader>dd", require("fzf-lua").diagnostics_document)
      vim.keymap.set("n", "<leader>dw", require("fzf-lua").diagnostics_workspace)
    end,
  },
}
