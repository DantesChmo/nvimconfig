-- ~/.config/nvim/lua/config/lsp_shared.lua
-- Общие настройки для всех LSP-клиентов: capabilities и стандартные keymap'ы.
-- Используются и в plugins/lsp.lua (через vim.lsp.config), и в ftplugin/java.lua (через nvim-jdtls).

local M = {}

-- Capabilities с поддержкой completion от nvim-cmp
function M.capabilities()
  return require("cmp_nvim_lsp").default_capabilities()
end

-- Базовые keymap'ы LSP, навешиваются при подключении сервера к буферу
function M.on_attach(_, bufnr)
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)         -- переход к определению
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)         -- поиск ссылок
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)        -- переход к декларации
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)     -- переход к реализации
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)    -- переход к типу
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)               -- показать документацию
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)     -- переименование символа
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- code actions
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)                                                       -- форматирование
end

return M
