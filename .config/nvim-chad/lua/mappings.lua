require "nvchad.mappings"

local map = vim.keymap.set

-- bundled example (very useful, actually)
map("n", ";", ":", { desc = "CMD enter command mode" })
map('n', '<Leader>dd', ':lua vim.diagnostic.config { virtual_text = false }<CR>', { desc = "Diagnostics Disabled"})
map('n', '<Leader>de', ':lua vim.diagnostic.config { virtual_text = true }<CR>', { desc = "Diagnostics Enabled"})

