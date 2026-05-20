local opt = vim.opt

-- Основные настройки
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false

-- Отступы
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Поиск
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Внешний вид
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

-- Разделение окон
opt.splitbelow = true
opt.splitright = true

-- Производительность
opt.updatetime = 250
opt.timeoutlen = 300

-- Дополнительно
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10

