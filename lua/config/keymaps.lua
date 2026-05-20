local keymapSet = vim.keymap.set
local opts = { noremap = true, silent = true } 

-- Горизонтальный терминал
keymapSet('n', '<leader>th', ':split | terminal<CR>', opts)

-- Вертикальный терминал
keymapSet('n', '<leader>tv', ':vsplit | terminal<CR>', opts)

-- Навигация между окнами
keymapSet('n', '<C-h>', '<C-w>h', opts) -- влево
keymapSet('n', '<C-j>', '<C-w>j', opts) -- вниз
keymapSet('n', '<C-k>', '<C-w>k', opts) -- вверх
keymapSet('n', '<C-l>', '<C-w>l', opts) -- вправо

keymapSet('n', '<leader>tt', '<cmd>ToggleTerm<CR>', opts) -- переключение терминала
keymapSet('n', '<leader>e', ':NvimTreeToggle<CR>', opts) -- файловый проводник

keymapSet('n', '<leader>gs', ':Git<CR>', opts) -- git статус
keymapSet('n', '<leader>gc', ':Git commit<CR>', opts) -- git коммит
keymapSet('n', '<leader>gp', ':Git push<CR>', opts) -- git пуш
keymapSet('n', '<leader>gl', ':Git pull<CR>', opts) -- git пулл

keymapSet('n', 'gd', vim.lsp.buf.definition, opts) -- переход к определению
keymapSet('n', 'gr', vim.lsp.buf.references, opts) -- поиск ссылок на символ
keymapSet('n', 'gi', vim.lsp.buf.implementation, opts) -- переход к реализации
keymapSet('n', 'K', vim.lsp.buf.hover, opts) -- показать документацию

keymapSet('n', '<leader>rn', vim.lsp.buf.rename, opts) -- переименование символа
keymapSet('n', '<leader>ca', vim.lsp.buf.code_action, opts) -- действия кода
keymapSet('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts) -- форматирование
keymapSet('n', '<S-l>', ':bnext<CR>', opts) -- следующий буфер
keymapSet('n', '<S-h>', ':bprevious<CR>', opts) -- предыдущий буфер
keymapSet('n', '<leader>q', ':qa!<CR>', opts) -- выйти из Neovim
keymapSet('n', '<leader>w', ':w<CR>', opts) -- сохранить файл

keymapSet('n', '<leader><space>', ':nohlsearch<CR>', opts) -- очистка подстветки поиска

-- Горячие клавиши для диагностики LSP
keymapSet('n', '<leader>de', vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Показать ошибки/предупреждения в строке" })
keymapSet('n', '<leader>dq', vim.diagnostic.setloclist, { noremap = true, silent = true, desc = "Список ошибок буфера" })
keymapSet('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = "Предыдущая ошибка" })
keymapSet('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "Следующая ошибка" })

-- LSP прыжки к реализации
keymapSet("n", "gi", function()
  vim.lsp.buf.implementation()
end, { silent = true })

-- LSP поиск ссылок на символ
keymapSet("n", "gr", function()
  vim.lsp.buf.references()
end, { silent = true })

keymapSet('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })
