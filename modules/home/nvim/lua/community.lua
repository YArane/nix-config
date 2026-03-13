-- AstroCommunity: import community plugin packs
-- See available packs: https://github.com/AstroNvim/astrocommunity
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.helm" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.nix" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
}
