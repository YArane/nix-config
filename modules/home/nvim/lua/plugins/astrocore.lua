-- Custom keymaps via AstroCore
-- See: https://docs.astronvim.com/configuration/customizing_plugins/
return {
  "AstroNvim/astrocore",
  opts = {
    autocmds = {
      markdown_wrap = {
        {
          event = "FileType",
          pattern = "markdown",
          desc = "Enable line wrap in markdown files",
          callback = function()
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
          end,
        },
      },
    },
    mappings = {
      n = {
        -- diable default bindings
        ["<C-q>"] = false,
        ["<C-s>"] = false,

        -- buffer navigation
        ["<S-l>"] = {
          function()
            require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1)
          end,
          desc = "Next buffer",
        },
        ["<S-h>"] = {
          function()
            require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1))
          end,
          desc = "Previous buffer",
        },
        ["<BS>"] = { "<C-o>", desc = "Go back in jumplist" },
      },
    },
  },
}
