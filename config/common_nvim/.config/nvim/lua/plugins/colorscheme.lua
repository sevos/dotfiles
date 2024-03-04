return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local custom_ayu_dark = require("lualine.themes.ayu_dark")

      -- Change the background of lualine_c section for normal mode
      custom_ayu_dark.normal.c.bg = nil
      require("lualine").setup({
        options = {
          theme = custom_ayu_dark,
          component_separators = "|",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {
            { "mode", separator = { left = "" }, right_padding = 2 },
          },
          lualine_z = {
            { "location", separator = { right = "" }, left_padding = 2 },
          },
        },
        -- sections = {
        --   lualine_a = {
        --     { "mode", separator = { left = "" }, right_padding = 2 },
        --   },
        --   lualine_b = { "filename", "branch" },
        --   lualine_c = { "fileformat" },
        --   lualine_x = {},
        --   lualine_y = { "filetype", "progress" },
        --   lualine_z = {
        --     { "location", separator = { right = "" }, left_padding = 2 },
        --   },
        -- },
        -- inactive_sections = {
        --   lualine_a = { "filename" },
        --   lualine_b = {},
        --   lualine_c = {},
        --   lualine_x = {},
        --   lualine_y = {},
        --   lualine_z = { "location" },
        -- },
        -- tabline = {},
        -- extensions = {},
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
