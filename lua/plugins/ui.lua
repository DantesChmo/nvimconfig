return {
      -- Nvim-tree: файловый проводник
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function ()
      require('nvim-tree').setup({
        sort_by = 'case_sensitive',
        renderer = { group_empty = true },
        actions = {
          open_file = { quit_on_open = false, resize_window = true },
        },
        view = {
          width = 30,
          side = 'left',
        },
        on_attach = function (bufnr)
          local api = require('nvim-tree.api')

          local function opts(desc)
            return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- Основные действия
          vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open')) -- открыть файл/папку
          vim.keymap.set('n', 'o', api.node.open.edit, opts('Open')) -- открыть файл/папку
          vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split')) -- открыть в вертикальном сплите
          vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split')) -- открыть в горизонтальном сплите
          vim.keymap.set('n', 't', api.node.open.tab, opts('Open: New Tab')) -- открыть в новой вкладке
          vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory')) -- закрыть папку
          vim.keymap.set('n', 'l', api.node.open.edit, opts('Open')) -- открыть файл/папку

          -- Работа с файлами
          vim.keymap.set('n', 'a', api.fs.create, opts('Create File')) -- добавить файл
          vim.keymap.set('n', 'd', api.fs.remove, opts('Delete File')) -- удалить файл
          vim.keymap.set('n', 'r', api.fs.rename, opts('Rename File')) -- переименовать файл
          vim.keymap.set('n', 'x', api.fs.cut, opts('Cut File')) -- вырезать файл
          vim.keymap.set('n', 'p', api.fs.paste, opts('Paste File')) -- вставить файл
        end
      })
    end
  },

  -- Symbols-outline: боковая панель с символами файла
  { "simrat39/symbols-outline.nvim" },

  -- Lualine: статусбар
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function ()
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = "",
          component_separators = ""
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            "filename",
            function()
              return require("lsp-progress").progress()
            end,
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end
  },
}
