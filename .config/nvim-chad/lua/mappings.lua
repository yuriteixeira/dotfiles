-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/mappings.lua
require "nvchad.mappings"

local map = vim.keymap.set
local del = vim.keymap.del


-- bundled example (very useful, actually)

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader>dd", ":lua vim.diagnostic.config { virtual_text = false }<CR>", { desc = "Diagnostics Disabled" })
map("n", "<leader>de", ":lua vim.diagnostic.config { virtual_text = true }<CR>", { desc = "Diagnostics Enabled" })


-- my overrides
del("n", "<tab>")
del("n", "<s-tab>")


-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/mappings.lua#L70C5-L75
map(
  "n",
  "<leader>ff",
  "<cmd>Telescope find_files follow=true hidden=true<CR>",
  { desc = "telescope find all files" }
)


-- my own additions
map("n", "<leader><leader>", ":b#<CR>", { desc = "Buffers: Toggle current buffer with last opened one" })
map("n", "<leader>ti", ":IBLToggle<CR>", { desc = "Indent Lines: Toggle" })
map("n", "<leader>tk", ":Telescope keymaps<CR>", { desc = "Telescope: Keymaps" })
