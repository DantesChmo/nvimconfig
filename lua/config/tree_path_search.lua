-- Path-aware поиск внутри буфера nvim-tree (замена нативного `/`).
--
-- Идея: печатаешь как путь, сегменты разделены `/`.
--   pages          -> подсветить детей текущего уровня, начинающихся с "pages"
--   pages/         -> раскрыть папку pages, подсветить её саму
--   pages/auth     -> внутри раскрытой pages подсветить детей, начинающихся с "auth"
--   (стёр до pages) -> pages свернуть обратно, вернуться к первому шагу
--
-- Механика ввода повторяет nvim-tree/explorer/live-filter.lua: однострочный
-- оверлей-буфер у курсора + хук on_lines, реагирующий на каждый символ.
--
-- Разбор: последний сегмент — active (что ищем сейчас), всё до него — committed
-- (уже пройденный путь). Committed-сегменты резолвим от корня, раскрывая по
-- одной директории за шаг; active-сегмент подсвечивает детей текущего контекста.
-- Сегменты матчатся по префиксу, без учёта регистра. Совпадение — только среди
-- ПРЯМЫХ детей контекста (не рекурсивно).

local M = {}

local core = require("nvim-tree.core")
local view = require("nvim-tree.view")

local NS = vim.api.nvim_create_namespace("nvim_tree_path_search")

-- Подсветка совпадений. link=default, чтобы не перебивать пользовательскую тему.
vim.api.nvim_set_hl(0, "NvimTreePathSearchMatch", { link = "Search", default = true })
vim.api.nvim_set_hl(0, "NvimTreePathSearchCurrent", { link = "CurSearch", default = true })

---@type table? активная сессия поиска; nil когда поиск не идёт
local state = nil

-- Директория ли узел (у файлов нет .nodes).
local function is_dir(node)
  return node ~= nil and type(node.nodes) == "table"
end

-- Прямые дети узла с учётом группировки (group_empty): реальные дети лежат на
-- последнем узле группы. Для корня (explorer) — просто explorer.nodes.
local function children_of(node)
  if node == state.explorer then
    return node.nodes or {}
  end
  local head = node.last_group_node and node:last_group_node() or node
  return head.nodes or {}
end

-- Первая сверху дочерняя директория, чьё имя начинается с prefix (case-insensitive).
local function find_prefix_dir(nodes, prefix)
  local lp = prefix:lower()
  for _, n in ipairs(nodes) do
    if is_dir(n) and n.name:lower():sub(1, #lp) == lp then
      return n
    end
  end
  return nil
end

local function contains(list, item)
  for _, v in ipairs(list) do
    if v == item then
      return true
    end
  end
  return false
end

-- Раскрыть ровно один уровень директории (с учётом группировки), вернуть её head.
local function open_one(node)
  local head = node:last_group_node()
  if not head.open then
    head.open = true
    if #head.nodes == 0 then
      state.explorer:expand_dir_node(head)
    end
  end
  return head
end

local function clear_highlights(bufnr)
  bufnr = bufnr or (state and state.tree_bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
  end
end

-- Подсветить строки узлов; первый — «текущий», курсор ставим на него.
local function highlight(nodes)
  clear_highlights(state.tree_bufnr)
  local first_line
  for i, node in ipairs(nodes) do
    local line = state.explorer:find_node_line(node)
    if line > 0 then
      local group = (i == 1) and "NvimTreePathSearchCurrent" or "NvimTreePathSearchMatch"
      vim.api.nvim_buf_set_extmark(state.tree_bufnr, NS, line - 1, 0, {
        line_hl_group = group,
        priority = 200,
      })
      first_line = first_line or line
    end
  end
  if first_line and view.get_winnr() and vim.api.nvim_win_is_valid(view.get_winnr()) then
    vim.api.nvim_win_set_cursor(view.get_winnr(), { first_line, 0 })
  end
end

-- Ядро: пересобрать состояние дерева под текущий запрос.
local function update(query)
  if not state then
    return
  end

  local segments = vim.split(query, "/", { plain = true })
  local active = segments[#segments]
  local committed = {}
  for i = 1, #segments - 1 do
    committed[i] = segments[i]
  end

  -- Резолвим committed-путь от корня, раскрывая по одной директории.
  local ctx = state.explorer
  local new_opened = {}
  local resolved = true
  for _, seg in ipairs(committed) do
    local child = find_prefix_dir(children_of(ctx), seg)
    if not child then
      resolved = false
      break
    end
    local head = child:last_group_node()
    if not head.open then
      open_one(child)
      table.insert(new_opened, head) -- раскрыли мы
    elseif contains(state.opened, head) then
      table.insert(new_opened, head) -- раскрывали мы раньше — сохраняем владение
    end
    ctx = child
  end

  -- Свернуть то, что раскрывали мы и что больше не на пути (шаг «стёр — папка закрылась»).
  -- Папки, открытые пользователем до поиска, не в state.opened — их не трогаем.
  for _, node in ipairs(state.opened) do
    if not contains(new_opened, node) then
      node.open = false
    end
  end
  state.opened = new_opened

  state.explorer.renderer:draw()

  -- Подсветка: active пустой (ввёл слэш) — подсвечиваем саму папку-контекст;
  -- иначе — детей контекста с префиксом active.
  local matches = {}
  if resolved then
    if active == "" then
      if ctx ~= state.explorer then
        matches = { ctx }
      end
    else
      local lp = active:lower()
      for _, n in ipairs(children_of(ctx)) do
        if n.name:lower():sub(1, #lp) == lp then
          table.insert(matches, n)
        end
      end
    end
  end
  highlight(matches)
end

-- Свернуть всё, что раскрыли, и вернуть дерево в исходное состояние.
local function restore()
  for _, node in ipairs(state.opened) do
    node.open = false
  end
  state.opened = {}
  state.explorer.renderer:draw()
  if state.start_node then
    local line = state.explorer:find_node_line(state.start_node)
    if line > 0 and view.get_winnr() and vim.api.nvim_win_is_valid(view.get_winnr()) then
      vim.api.nvim_win_set_cursor(view.get_winnr(), { line, state.start_col or 0 })
    end
  end
end

local function finish()
  if not state then
    return
  end
  local s = state
  state = nil

  clear_highlights(s.tree_bufnr)

  if vim.api.nvim_win_is_valid(s.overlay_winnr) then
    vim.api.nvim_win_close(s.overlay_winnr, true)
  end
  if vim.api.nvim_buf_is_valid(s.overlay_bufnr) then
    vim.api.nvim_buf_delete(s.overlay_bufnr, { force = true })
  end

  if s.cancel then
    state = s -- restore ссылается на state
    restore()
    state = nil
  end

  -- вернуть фокус в дерево
  if view.get_winnr() and vim.api.nvim_win_is_valid(view.get_winnr()) then
    vim.api.nvim_set_current_win(view.get_winnr())
  end
end

-- Отмена по Esc: помечаем и выходим из insert (InsertLeave добьёт finish).
function M._cancel()
  if state then
    state.cancel = true
  end
  vim.cmd("stopinsert")
end

local function create_overlay()
  local bufnr = vim.api.nvim_create_buf(false, true)
  state.overlay_bufnr = bufnr

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function()
      vim.schedule(function()
        if state and vim.api.nvim_buf_is_valid(bufnr) then
          local line = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)[1] or ""
          update(line)
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    buffer = bufnr,
    once = true,
    callback = finish,
  })

  -- <CR> — зафиксировать (cancel остаётся false), <Esc> — отменить с откатом.
  vim.keymap.set("i", "<CR>", "<cmd>stopinsert<CR>", { buffer = bufnr })
  vim.keymap.set("i", "<Esc>", M._cancel, { buffer = bufnr })

  -- Прибиваем ввод к нижней строке окна дерева — как привычный `/` внизу.
  local tree_winnr = view.get_winnr()
  local win_height = vim.api.nvim_win_get_height(tree_winnr)
  local win_width = vim.api.nvim_win_get_width(tree_winnr)
  state.overlay_winnr = vim.api.nvim_open_win(bufnr, true, {
    relative = "win",
    win = tree_winnr,
    row = win_height - 1,
    col = 0,
    width = math.max(win_width, 1),
    height = 1,
    border = "none",
    style = "minimal",
  })
  vim.api.nvim_set_option_value("filetype", "NvimTreePathSearch", { buf = bufnr })
  vim.cmd("startinsert")
end

-- Точка входа: маппится на `/` в буфере дерева (см. on_attach в plugins/ui.lua).
function M.start()
  local explorer = core.get_explorer()
  if not explorer then
    return
  end
  if state then
    finish()
  end

  local start_node = explorer:get_node_at_cursor()
  local cursor = explorer:get_cursor_position()

  state = {
    explorer = explorer,
    tree_bufnr = vim.api.nvim_get_current_buf(),
    opened = {}, -- директории, раскрытые нами в этой сессии
    start_node = start_node,
    start_col = cursor and cursor[2] or 0,
    cancel = false,
  }

  create_overlay()
end

return M
