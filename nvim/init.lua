vim.loader.enable()
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("options")
require("autocmds")
require("keybinds")
require("plugins")
