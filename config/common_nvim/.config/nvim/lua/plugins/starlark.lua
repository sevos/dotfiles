return {
  -- Load the Starlark plugin
  {
    "cappyzawa/starlark.vim",
    config = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "Tiltfile",
        command = "set filetype=starlark",
      })
    end,
  },
}
