return {
  {
    "polarmutex/git-worktree.nvim",
    config = function()
      require("git-worktree").setup({
        update_on_change = true,
        autopush = true,
      })
      require("telescope").load_extension("git_worktree")
    end,
    keys = {
      { "<leader>gW", [[<cmd>lua require('git-worktree').create_worktree()<CR>]], desc = "Create worktree" },
      {
        "<leader>gw",
        [[<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>]],
        desc = "Switch worktree",
      },
    },
  },
}
