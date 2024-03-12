return {
  { "tpope/vim-rails", lazy = false },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "mwagg/neotest-minitest",
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
          running = {
            concurrent = false,
          },
        },
      })
    end,
  },
}
