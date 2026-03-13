# CLAUDE.md — AstroNvim v5 Companion

You are helping customize an AstroNvim v5 neovim configuration managed through Nix
Home Manager. Follow idiomatic AstroNvim v5 patterns in all suggestions.

---

## This Config's Directory Structure

```
modules/home/nvim/
├── init.lua                    ← bootstraps lazy.nvim, loads AstroNvim + plugins
└── lua/
    ├── community.lua           ← AstroCommunity pack imports
    └── plugins/
        └── user.lua            ← custom plugin specs (lazy.nvim format)
```

**Where to put things:**

| I want to...                        | Put it in...                         |
|-------------------------------------|--------------------------------------|
| Add a community language pack       | `lua/community.lua`                  |
| Add/override a plugin               | new file in `lua/plugins/` (one per plugin) |
| Configure AstroCore (options, maps) | `lua/plugins/astrocore.lua`          |
| Configure AstroLSP                  | `lua/plugins/astrolsp.lua`           |
| Configure AstroUI                   | `lua/plugins/astroui.lua`            |
| Install tools via Mason             | `lua/plugins/mason.lua`              |

**One plugin spec per file** in `lua/plugins/`. lazy.nvim auto-imports everything in
that directory. Name the file after the plugin or concern (e.g., `astrocore.lua`,
`treesitter.lua`, `telescope.lua`).

**Note:** `community.lua` lives at `lua/community.lua`, not inside `lua/plugins/`.
It is loaded via a separate `{ import = "community" }` line in `init.lua`. If you add
new top-level directories of specs, they need their own `import` line in `init.lua`.

---

## AstroNvim v5 Architecture

AstroNvim v5 is built on **lazy.nvim** and three core configuration plugins:

- **AstroCore** — vim options (`vim.opt`), keymaps, autocmds, user commands. Use this
  instead of raw `vim.opt` or `vim.keymap.set`.
- **AstroUI** — icons, highlight groups, status line / winbar / tabline (via heirline).
- **AstroLSP** — LSP server config, integrates nvim-lspconfig + mason + none-ls.

Each is configured as a lazy.nvim plugin spec with an `opts` table.

---

## Plugin Spec Patterns

All customization uses lazy.nvim plugin specs. Two `opts` formats:

### Table form (simple merge)

```lua
-- lua/plugins/astrocore.lua
return {
  "AstroNvim/astrocore",
  opts = {
    options = {
      opt = {
        relativenumber = true,
        scrolloff = 8,
      },
    },
  },
}
```

lazy.nvim deep-merges this with AstroNvim's defaults via `vim.tbl_deep_extend`.

**Gotcha:** Table-form deep merge works for dictionary-like tables but **replaces**
list-like tables entirely. Exception: AstroNvim enables `opts_extend` for
`ensure_installed` on treesitter and mason-tool-installer, so those lists DO extend
with table form. For other lists, use the function form.

**Gotcha:** Table-form `opts` resolves immediately in Lua. This can break lazy loading
if the table references a module that isn't loaded yet. Use function form if you need
to `require()` anything.

### Function form (full control)

```lua
-- lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    if not opts.ensure_installed then
      opts.ensure_installed = {}
    end
    vim.list_extend(opts.ensure_installed, {
      "lua", "nix", "python",
    })
  end,
}
```

Use the function form when you need to append to a list, conditionally modify values,
or require a module. Always check that nested tables exist before indexing into them.

**Useful helpers from AstroCore:**
- `require("astrocore").list_insert_unique(list, items)` — appends only unique values
  (modifies in place)
- `require("astrocore").extend_tbl(base, override)` — deep merge (returns new table,
  must be returned from the function)

### Extending vs overriding

lazy.nvim **extends** these keys: `cmd`, `event`, `ft`, `keys`, `opts`, `dependencies`.
All other keys **overwrite** the default. When in doubt, use the function form of `opts`.

### Extending a plugin's `config` function

When a plugin has a custom config in AstroNvim, call the default first:

```lua
return {
  "L3MON4D3/LuaSnip",
  config = function(plugin, opts)
    require("astronvim.plugins.configs.luasnip")(plugin, opts)
    -- your additions after the default config runs
    require("luasnip").filetype_extend("javascript", { "javascriptreact" })
  end,
}
```

### Disabling a default plugin

```lua
return {
  { "max397574/better-escape.nvim", enabled = false },
}
```

---

## Keymaps

Configure keymaps through AstroCore, not raw `vim.keymap.set`:

```lua
-- lua/plugins/astrocore.lua
return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {  -- normal mode
        ["<Leader>w"] = { "<cmd>w<cr>", desc = "Save file" },
        ["<Leader>q"] = { "<cmd>q<cr>", desc = "Quit" },
      },
      i = {  -- insert mode
        ["<C-s>"] = { "<cmd>w<cr>", desc = "Save file" },
      },
      t = {  -- terminal mode
        -- ...
      },
    },
  },
}
```

**This config's leader key is `,`** (set in `init.lua`).

**v5 note:** Do NOT use the string `"<leader>"` inside mapping key strings. Use
`"<Leader>"` (capital L) or the literal key. The lowercase form broke in v5.

---

## LSP, Formatters, and Linters

### Installing tools with Mason

In v5, use **mason-tool-installer.nvim** (NOT mason-lspconfig's `ensure_installed`):

```lua
-- lua/plugins/mason.lua
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ensure_installed = {
      "lua-language-server",   -- LSP for Lua
      "stylua",                -- formatter for Lua
      "nil",                   -- LSP for Nix (or "nixd")
      "prettier",              -- formatter for JS/TS/etc.
    },
  },
}
```

**Critical:** Use Mason package names (hyphenated), not lspconfig server names.
Run `:Mason` in neovim to browse available packages and verify names.

### Configuring LSP servers

```lua
-- lua/plugins/astrolsp.lua
return {
  "AstroNvim/astrolsp",
  opts = {
    config = {
      lua_ls = {               -- lspconfig server name (underscored)
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
          },
        },
      },
    },
  },
}
```

### Formatters and linters (none-ls)

```lua
-- lua/plugins/none-ls.lua
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require("null-ls")
    opts.sources = vim.list_extend(opts.sources or {}, {
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.prettier,
    })
  end,
}
```

---

## AstroCommunity Packs

Community packs bundle treesitter parsers, LSP servers, formatters, and plugins for a
language in one import. Always prefer a community pack over manual setup when one exists.

```lua
-- lua/community.lua
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.nix" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.typescript" },
  -- Browse: https://github.com/AstroNvim/astrocommunity
}
```

Community packs can be extended/overridden by adding your own specs for the same
plugins in `lua/plugins/`. User specs take precedence.

---

## Default Plugins (ships with AstroNvim v5)

Do NOT install these separately — they're already included:

| Plugin              | Purpose                                    |
|---------------------|--------------------------------------------|
| lazy.nvim           | Plugin manager                             |
| nvim-lspconfig      | LSP configurations                         |
| nvim-treesitter     | Syntax highlighting and parsing            |
| telescope.nvim      | Fuzzy finder                               |
| neo-tree.nvim       | File explorer                              |
| heirline.nvim       | Status line, winbar, tabline               |
| which-key.nvim      | Keymap discovery (`<Leader>` menu)         |
| nvim-cmp            | Completion engine                          |
| LuaSnip             | Snippet engine                             |
| mini.icons          | Icons (replaced nvim-web-devicons in v5)   |
| snacks.nvim         | Dashboard, notifications, indent guides    |
| mason.nvim          | LSP/tool installer                         |
| none-ls.nvim        | Formatter/linter bridge                    |
| gitsigns.nvim       | Git gutter signs                           |

---

## v5 Breaking Changes (from v4)

Be aware of these when reading older tutorials or migration guides:

- **mini.icons** replaced `nvim-web-devicons` + `lspkind.nvim`
- **snacks.nvim** replaced `alpha-nvim` (dashboard), `dressing.nvim` (UI),
  `indent-blankline.nvim` (indent guides)
- **mason-tool-installer.nvim** replaced separate `ensure_installed` in
  mason-lspconfig / mason-nvim-dap / mason-null-ls
- **`<leader>` mapping syntax** changed — use `<Leader>` (capital L)

---

## Lazy Loading Events

AstroNvim provides custom events for lazy loading plugins at the right time:

- **`User AstroFile`** — fires when the first real file is opened (use for file-related
  plugins like vim-illuminate)
- **`User AstroGitFile`** — fires when a file in a git repo is opened (use for git
  plugins like gitsigns)

```lua
return {
  { "RRethy/vim-illuminate", event = "User AstroFile" },
  { "lewis6991/gitsigns.nvim", event = "User AstroGitFile" },
}
```

---

## Anti-Patterns — Do NOT Do These

- **Don't install default plugins again** — check the table above before adding a plugin
- **Don't use `vim.opt` or `vim.keymap.set` directly** — use AstroCore `opts`
- **Don't put all plugins in one file** — one spec per file in `lua/plugins/`
- **Don't use mason-lspconfig's `ensure_installed`** — use mason-tool-installer
- **Don't configure LSP in `on_attach`** — use AstroLSP's `opts.config` table
- **Don't duplicate what community packs provide** — check astrocommunity first

---

## Nix Integration Notes

This config is managed by Home Manager via `editor.nix`:

- Files in `modules/home/nvim/` are symlinked into `~/.config/nvim/` (recursive mode)
- **`git add` new files** before `sudo nixos-rebuild switch --flake .#wsl` — Nix flakes
  only see tracked files
- **lazy-lock.json** is written to `~/.local/share/nvim/` (not the config dir) because
  the config dir contains read-only Nix store symlinks
- **System dependencies** (gcc, ripgrep, fd, tree-sitter, etc.) are declared in
  `editor.nix`, not installed manually
- **Mason binaries** work because `editor.nix` provides curl, wget, unzip, tar, gzip
  which Mason needs to download tools
