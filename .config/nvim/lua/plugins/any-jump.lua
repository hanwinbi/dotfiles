return {
  -- 其他插件
  {
    'pechorin/any-jump.vim',
    config = function()
      -- 配置 any-jump
      vim.g.any_jump_disable_maps = 0  -- 启用默认快捷键
      vim.g.any_jump_auto_preview = 1  -- 自动预览
    end
  }
}

