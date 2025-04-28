return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        cmd = {
          "clangd",
          "--compile-commands-dir=/repo/hanbi/source/sw/y/build/apps/cross_lt_lag_app/",
          "--vfsoverlay=/repo/hanbi/tools/vfs_overlay.yaml",
        },
        filetypes = { "c", "cpp" },
      },
    },
  },
}
