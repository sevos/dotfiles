-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("n", ";", ":")

-- remove <leader>- mapping
vim.keymap.set("n", "<leader>-", "<Nop>")

-- map <leader>_ to split window horizontally with description
vim.keymap.set("n", "<leader>_", "<cmd>split<CR>")
