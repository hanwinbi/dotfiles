return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      cpp = { "clang-format" },
      c = { "clang-format" },
    },
    format_on_save = false, -- 保存时自动格式化
  },
}
