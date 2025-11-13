-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.list = true
vim.opt.listchars = {
  space = "·", -- 空格显示为 ·
  tab = "»·", -- tab 显示为 »·
  trail = "•", -- 结尾空格显示为 •
  eol = "↲", -- 显示换行符
}
-- 文件路径: ~/.config/nvim/lua/config/options.lua
vim.opt.colorcolumn = "120" -- 在 120 字符处显示一条分界线
vim.opt.expandtab = true -- 使用空格替代 Tab
vim.opt.shiftwidth = 4 -- 自动缩进时，每级缩进 4 个空格
vim.opt.tabstop = 4 -- 1 个 Tab 视为 4 个空格
vim.opt.softtabstop = 4 -- 按退格键时，删除 4 个空格
vim.g.autoformat = false
vim.opt.number = true -- 显示行号
vim.opt.relativenumber = true -- 显示相对行号（可选）
vim.opt.shell = "/bin/zsh"
vim.g.root_spec = { "cwd"}

vim.api.nvim_set_keymap('n', '<leader>cp', ':let @+ = expand("%:p")<CR>', { noremap = true, silent = true })
vim.o.clipboard = "unnamedplus"

local function paste()
  return {
    vim.fn.split(vim.fn.getreg(""), "\n"),
    vim.fn.getregtype(""),
  }
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste,
  },
}


