local map = vim.keymap.set

-- Editor Basics

map("n", "<C-b>", "<C-v>", { noremap = true, desc = "Visual block mode" })

map("n", "<S-down>", "<C-d>zz", { desc = "Scroll down half and center" })
map("n", "<S-up>", "<C-u>zz", { desc = "Scroll up half and center" })

map(
    "n",
    "<C-S-down>",
    "<cmd>execute 'move .+' . v:count1<cr>==",
    { desc = "Move line down", silent = true }
)
map(
    "n",
    "<C-S-up>",
    "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==",
    { desc = "Move line up", silent = true }
)
map(
    "i",
    "<C-S-down>",
    "<esc><cmd>m .+1<cr>==gi",
    { desc = "Move line down", silent = true }
)
map("i", "<C-S-up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up", silent = true })
map(
    "v",
    "<C-S-down>",
    ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",
    { desc = "Move selection down", silent = true }
)
map(
    "v",
    "<C-S-up>",
    ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
    { desc = "Move selection up", silent = true }
)

map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keyword program" })

-- Search

map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

map(
    "n",
    "<leader>ur",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / clear hlsearch / diff update" }
)

map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Text Operations

map(
    "x",
    "p",
    'p:let @+=@0<CR>:let @"=@0<CR>',
    { noremap = true, silent = true, desc = "Paste without clobbering" }
)

map(
    "v",
    "<leader>rv",
    '"hy:%s/\\V<C-r>h/<C-r>h/gc<left><left><left>',
    { desc = "Replace visual selection" }
)
map(
    "n",
    "<leader>rw",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Replace word under cursor" }
)

-- Windows

map("n", "<C-v>", "<C-w>v", { desc = "Split window right" })
map("n", "<C-s>", "<C-w>s", { desc = "Split window below" })
map("n", "<C-c>", "<C-w>c", { desc = "Close current window" })
map("n", "<C-f>", "<C-w><C-w>", { desc = "Cycle windows" })

-- Tabs & Buffers

map("n", "<C-a>", ":$tabnew<CR>", { noremap = true, silent = true, desc = "New tab" })
map("n", "<C-q>", ":tabclose<CR>", { noremap = true, silent = true, desc = "Close tab" })
map(
    "n",
    "<leader>to",
    ":tabonly<CR>",
    { noremap = true, silent = true, desc = "Close other tabs" }
)
map("n", "<C-.>", ":tabn<CR>", { noremap = true, silent = true, desc = "Next tab" })
map("n", "<C-,>", ":tabp<CR>", { noremap = true, silent = true, desc = "Prev tab" })
map(
    "n",
    "<C-S-,>",
    ":-tabmove<CR>",
    { noremap = true, silent = true, desc = "Move tab left" }
)
map(
    "n",
    "<C-S-.>",
    ":+tabmove<CR>",
    { noremap = true, silent = true, desc = "Move tab right" }
)
map(
    "n",
    "<C-Tab>",
    ":bp<cr>zz",
    { noremap = true, silent = true, desc = "Previous buffer" }
)
map(
    "n",
    "<C-S-Tab>",
    ":bn<cr>zz",
    { noremap = true, silent = true, desc = "Next buffer" }
)
map(
    "n",
    "<leader>bd",
    ":bd<cr>",
    { noremap = true, silent = true, desc = "Delete buffer" }
)

-- Terminal

map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })


