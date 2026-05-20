# Neovim Configuration

A personal Neovim setup focused on polyglot development (Java/Spring Boot, Go, TypeScript, Python, Swift, Kotlin, Lua) with LSP, DAP, AI-assisted completion, Git integration, and Docker/Kubernetes helpers.

## Requirements

- Neovim ≥ 0.10 (uses `vim.lsp.config` / `vim.lsp.enable` API)
- `git`, `curl`, a C compiler (for tree-sitter parsers)
- `ripgrep` and `fd` (recommended, used by `fzf-lua`)
- A Nerd Font (for `nvim-web-devicons`)
- `node` (for some LSP servers via Mason)
- `JDK 17+` if you plan to use the Java toolchain (`jdtls`)

## Installation

```sh
git clone <this-repo> ~/.config/nvim
nvim
```

On first launch `lazy.nvim` bootstraps itself and installs all plugins. After plugins are installed, `mason.nvim` and `mason-tool-installer` will pull the LSP servers, debug adapters and formatters listed below.

## Structure

```
.
├── init.lua                  # entry point — loads config.* modules
├── lazy-lock.json            # locked plugin versions
├── ftplugin/
│   └── java.lua              # per-buffer jdtls bootstrap for Java files
└── lua/
    ├── config/
    │   ├── options.lua       # vim options (numbers, tabs, search, UI, etc.)
    │   ├── keymaps.lua       # global keymaps
    │   ├── lazy.lua          # lazy.nvim bootstrap and plugin spec import
    │   └── lsp_shared.lua    # shared LSP capabilities + on_attach
    └── plugins/
        ├── init.lua          # colorscheme (gruvbox)
        ├── lsp.lua           # mason, mason-lspconfig, lspconfig
        ├── cmp.lua           # nvim-cmp completion + luasnip
        ├── treesitter.lua    # nvim-treesitter
        ├── fzf.lua           # fzf-lua + Docker/k9s pickers
        ├── git.lua           # gitsigns, fugitive, diffview, toggleterm
        ├── ui.lua            # nvim-tree, lualine, symbols-outline
        ├── helpers.lua       # autopairs, autotag, comment, bufferline, etc.
        ├── format.lua        # conform.nvim (google-java-format)
        ├── dap.lua           # nvim-dap + dap-ui + virtual text
        ├── test.lua          # neotest + neotest-java
        ├── db.lua            # vim-dadbod + dadbod-ui
        ├── java.lua          # nvim-jdtls and spring-boot.nvim specs
        └── ai.lua            # cmp-ai + codecompanion (X5 endpoint)
```

## Plugin manager

[`folke/lazy.nvim`](https://github.com/folke/lazy.nvim) — bootstrapped automatically by `lua/config/lazy.lua`. Plugin specs are split per-domain under `lua/plugins/` and imported as a whole directory.

## Language support

LSP servers managed by `mason-lspconfig` and configured via `vim.lsp.config` in `lua/plugins/lsp.lua`:

| Language       | Server                    |
| -------------- | ------------------------- |
| Go             | `gopls`                   |
| TypeScript/JS  | `ts_ls`                   |
| Python         | `pyright`                 |
| Swift          | `sourcekit-lsp`           |
| Kotlin         | `kotlin_language_server`  |
| Lua            | `lua_ls`                  |
| Java           | `jdtls` (via `nvim-jdtls`)|

Java is special: `jdtls` is started per-buffer from `ftplugin/java.lua` (not via `mason-lspconfig`) because it needs its own workspace per project, DAP bundles, and Spring Boot extensions. `mason-tool-installer` ensures the following tools are present:

- `jdtls` — Java LSP
- `java-debug-adapter` — DAP adapter for Java
- `java-test` — JUnit/TestNG runner bundle
- `google-java-format` — Java formatter (used by `conform.nvim`, AOSP style)

Treesitter parsers (`nvim-treesitter`) cover Bash, CSS, Go, HTML, Java, JS, JSON, Kotlin, Lua, Markdown, Python, Swift, TSX/TS, Vim, XML, YAML, and more.

## Completion

`nvim-cmp` with sources: `cmp_ai`, `nvim_lsp`, `luasnip`, `buffer`, `path`, plus `cmp-cmdline` for `:` and `/`. Snippets come from `friendly-snippets` via `LuaSnip`.

## AI

`tzachar/cmp-ai` + `olimorris/codecompanion.nvim` configured against an internal X5 endpoint (`https://api-copilot.x5.ru/aigw/v1`). Requires the `X5_API_KEY` environment variable. Adjust `lua/plugins/ai.lua` if you want to point at a different OpenAI-compatible endpoint.

## Debugging

`nvim-dap` + `nvim-dap-ui` + `nvim-dap-virtual-text`. The UI opens/closes automatically on session start/stop. Java DAP configurations are registered by `jdtls` for `main` classes and `@Test` methods.

## Tests

`neotest` with the `neotest-java` adapter — Maven and Gradle are detected automatically by the adapter.

## Database

`vim-dadbod` + `vim-dadbod-ui` + `vim-dadbod-completion`. Open the UI with `<leader>db`.

## Theme & UI

- Colorscheme: `gruvbox` (soft contrast, transparent background)
- Statusline: `lualine` with LSP progress
- File explorer: `nvim-tree`
- Buffer tabs: `bufferline.nvim`
- Symbols panel: `symbols-outline.nvim`
- Markdown rendering: `render-markdown.nvim`

## Keymaps

Leader is the default `\`. Highlights:

### Files / search (`fzf-lua`)

| Keys           | Action                |
| -------------- | --------------------- |
| `<leader>ff`   | Find files            |
| `<leader>fg`   | Live grep             |
| `<leader>fb`   | Buffers               |
| `<leader>fh`   | Help tags             |
| `<leader>fc`   | Commands              |
| `<leader>e`    | Toggle `nvim-tree`    |

### Buffers / windows

| Keys           | Action                |
| -------------- | --------------------- |
| `<S-l>` / `<S-h>` | Next / previous buffer |
| `<C-h/j/k/l>`  | Move between splits   |
| `<leader>w`    | Save                  |
| `<leader>q`    | Quit all (force)      |
| `<leader><space>` | Clear search highlight |

### Terminal

| Keys           | Action                       |
| -------------- | ---------------------------- |
| `<leader>th`   | Horizontal terminal split    |
| `<leader>tv`   | Vertical terminal split      |
| `<leader>tt`   | `ToggleTerm`                 |
| `<C-\>`        | `ToggleTerm` (default mapping) |
| `<Esc>` (term) | Exit terminal-insert mode    |

### LSP

| Keys           | Action                  |
| -------------- | ----------------------- |
| `gd`           | Go to definition        |
| `gD`           | Go to declaration       |
| `gr`           | References              |
| `gi`           | Implementation          |
| `gt`           | Type definition         |
| `K`            | Hover documentation     |
| `<leader>rn`   | Rename symbol           |
| `<leader>ca`   | Code action             |
| `<leader>f`    | Format buffer (LSP, or `google-java-format` in Java) |

### Diagnostics

| Keys           | Action                          |
| -------------- | ------------------------------- |
| `<leader>de`   | Show diagnostic on current line |
| `<leader>dq`   | Loclist of buffer diagnostics   |
| `<leader>dd`   | Document diagnostics (fzf)      |
| `<leader>dw`   | Workspace diagnostics (fzf)     |
| `[d` / `]d`    | Previous / next diagnostic      |

### Git

| Keys           | Action            |
| -------------- | ----------------- |
| `<leader>gs`   | `:Git` (fugitive) |
| `<leader>gc`   | `:Git commit`     |
| `<leader>gp`   | `:Git push`       |
| `<leader>gl`   | `:Git pull`       |

### Debugging (DAP)

| Keys           | Action                          |
| -------------- | ------------------------------- |
| `<F5>`         | Continue / start                |
| `<F10>`        | Step over                       |
| `<F11>`        | Step into                       |
| `<F12>`        | Step out                        |
| `<leader>b`    | Toggle breakpoint               |
| `<leader>B`    | Conditional breakpoint          |
| `<leader>xu`   | Toggle DAP UI                   |
| `<leader>xr`   | Toggle DAP REPL                 |
| `<leader>xc`   | Clear all breakpoints           |
| `<leader>xl`   | Re-run last session             |

### Tests (`neotest`)

| Keys           | Action                          |
| -------------- | ------------------------------- |
| `<leader>tr`   | Run nearest test                |
| `<leader>tf`   | Run current file                |
| `<leader>tl`   | Repeat last test                |
| `<leader>td`   | Debug nearest test              |
| `<leader>ts`   | Toggle summary tree             |
| `<leader>to`   | Show output                     |

### Java (`<leader>j`)

| Keys           | Action                          |
| -------------- | ------------------------------- |
| `<leader>jo`   | Organize imports                |
| `<leader>jv`   | Extract variable (normal/visual)|
| `<leader>jc`   | Extract constant                |
| `<leader>jm`   | Extract method (visual)         |
| `<leader>jr`   | Run test class                  |
| `<leader>jR`   | Run nearest test method         |
| `<leader>jb`   | Spring Boot — list beans        |
| `<leader>jp`   | Spring Boot — list endpoints    |

### Docker / Kubernetes (via `fzf-lua` + `toggleterm`)

| Keys           | Action                                  |
| -------------- | --------------------------------------- |
| `<leader>dps`  | Pick a container and tail its logs      |
| `<leader>dcu`  | Pick a Compose service and `up -d` it   |
| `<leader>cl`   | Pick a Compose service and tail logs    |
| `<leader>cd`   | `docker compose down`                   |
| `<leader>kk`   | Open `k9s` in a floating terminal       |

### AI

| Keys           | Action                                  |
| -------------- | --------------------------------------- |
| `<leader>ai`   | Toggle CodeCompanion chat               |
| `<leader>ad`   | Add visual selection to chat            |
| `<leader>aa`   | CodeCompanion actions menu              |

### Database

| Keys           | Action                |
| -------------- | --------------------- |
| `<leader>db`   | Toggle `DBUI`         |

## Options worth knowing

Set in `lua/config/options.lua`:

- Relative line numbers, system clipboard, persistent undo, no swap files
- 2-space indents, smart indent, smart case search
- True color, sign column always on, cursor line, 8-line scroll padding
- New splits go below / to the right
- 250 ms `updatetime`, 300 ms `timeoutlen`

## Notes

- `init_bak.lua` is a backup of an older single-file configuration kept around for reference. It is not loaded.
- `lazy-lock.json` is committed so plugin versions are reproducible — run `:Lazy update` to bump.
