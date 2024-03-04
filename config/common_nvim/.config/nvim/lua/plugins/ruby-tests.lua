return {
  { "tpope/vim-rails", lazy = false },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "zidhuss/neotest-minitest",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-minitest")({
            test_cmd = function()
              return vim.tbl_flatten({
                "bundle",
                "exec",
                "rails",
                "test",
              })
            end,
          }),
        },
      })
    end,
  },
}
