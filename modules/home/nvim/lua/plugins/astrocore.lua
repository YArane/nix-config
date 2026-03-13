-- Custom keymaps via AstroCore
-- See: https://docs.astronvim.com/configuration/customizing_plugins/
return {
  "AstroNvim/astrocore",
  opts = {
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
