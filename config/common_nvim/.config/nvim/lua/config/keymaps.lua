-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("n", ";", ":")

-- remove <leader>- mapping
vim.keymap.set("n", "<leader>-", "<Nop>")

-- map <leader>_ to split window horizontally with description
vim.keymap.set("n", "<leader>_", "<cmd>split<CR>")

vim.keymap.set("n", "<leader>o", "<C-o>")

-- -- use kj to exit insert mode
-- -- I auto save with
-- --  ~/github/dotfiles-latest/neovim/nvim-lazyvim/lua/plugins/auto-save.lua
vim.keymap.set("i", "kj", "<ESC>", { desc = "Exit insert mode with kj" })

-- use gh to move to the beginning of the line in normal mode
-- use gl to move to the end of the line in normal mode
vim.keymap.set("n", "gh", "^", { desc = "Go to the beginning of the line" })
vim.keymap.set("n", "gl", "$", { desc = "go to the end of the line" })
vim.keymap.set("v", "gh", "^", { desc = "Go to the beginning of the line in visual mode" })
vim.keymap.set("v", "gl", "$", { desc = "Go to the end of the line in visual mode" })

-- yank selected text into system clipboard
-- Vim/Neovim has two clipboards: unnamed register (default) and system clipboard.
-- Yanking with `y` goes to the unnamed register, accessible only within Vim.
-- The system clipboard allows sharing data between Vim and other applications.
-- Yanking with `"+y` copies text to both the unnamed register and system clipboard.
-- The `"+` register represents the system clipboard.
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })

-- yank/copy to end of line
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })
