local gh = function(x) return "https://github.com/" .. x end
local map = vim.keymap.set
vim.g.snacks_animate = false

-- EAGER PLUGINS (needed at startup)

vim.pack.add({
    gh("nvim-lua/plenary.nvim"),
    gh("onsails/lspkind.nvim"),
    gh("nvim-tree/nvim-web-devicons"),
    gh("rafamadriz/friendly-snippets"),
    gh("neovim/nvim-lspconfig"),
    gh("saghen/blink.lib"),
    gh("saghen/blink.cmp"),
    gh("romus204/tree-sitter-manager.nvim"),
    gh("nvim-mini/mini.pairs"),
    { src = gh("catppuccin/nvim"), name = "catppuccin" },
    gh("folke/snacks.nvim"),
})

-- catppuccin

require("catppuccin").setup({
    compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
    flavour = "mocha",
    term_colors = true,
    styles = {
        comments = { "italic" },
        conditionals = { "bold" },
        loops = { "bold" },
        functions = { "bold" },
        keywords = { "bold" },
        strings = {},
        variables = {},
        numbers = { "bold" },
        booleans = { "bold" },
        properties = { "italic" },
        types = { "bold" },
        operators = {},
    },
    default_integrations = false,
    auto_integrations = true,
    integrations = {
        native_lsp = {
            enabled = true,
            virtual_text = {
                errors = { "italic" },
                hints = { "italic" },
                warnings = { "italic" },
                information = { "italic" },
                ok = { "italic" },
            },
            underlines = {
                errors = { "underline" },
                hints = { "underline" },
                warnings = { "underline" },
                information = { "underline" },
                ok = { "underline" },
            },
            inlay_hints = {
                background = true,
            },
        },
    },
})
vim.cmd.colorscheme("catppuccin-nvim")

require("mini.pairs").setup()
require("nvim-web-devicons").setup({})

-- LSP

vim.lsp.config("lua_ls", {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath("config") and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) then
                return
            end

            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                runtime = {
                    version = "LuaJIT",
                    path = {
                        "lua/?.lua",
                        "lua/?/init.lua",
                    },
                },
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                    },
                },
            })
        end
    end,
    settings = {
        Lua = {},
    },
})
vim.lsp.enable("lua_ls")
vim.lsp.enable("fish_lsp")

-- snacks

require("snacks").setup({
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = {
        enabled = false,
        -- enabled = true,
        -- char = "▏",
        -- scope = {
        --     char = "▏",
        -- },
    },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = true },
    gh = { enabled = true },
    profiler = { enabled = false },
})

-- snacks picker keymaps

-- stylua: ignore start
map("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Smart find files" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<A-o>", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<A-S-o>", function() Snacks.picker.files({ hidden = true }) end, { desc = "Find files (hidden)" })
map("n", "<A-b>", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<A-g>", function() Snacks.picker.grep() end, { desc = "Live grep" })
map("n", "<A-r>", function() Snacks.picker.recent() end, { desc = "Recent files" })
map("n", "<S-z>", function() Snacks.picker.zoxide() end, { desc = "Zoxide" })
map("n", "<leader>/", function() Snacks.picker.lines() end, { desc = "Buffer lines" })
map({ "n", "x" }, "<leader>*", function() Snacks.picker.grep_word() end, { desc = "Grep word/selection" })
map("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git status" })
map("n", "<leader>gc", function() Snacks.picker.git_log() end, { desc = "Git log" })
map("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git branches" })
map("n", "<leader>gL", function() Snacks.picker.git_log_line() end, { desc = "Git log line" })
map("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git diff (hunks)" })
map("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git stash" })
map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git log file" })
map("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto definition" })
map("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto declaration" })
map("n", "gr", function() Snacks.picker.lsp_references() end, { nowait = true, desc = "References" })
map("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto implementation" })
map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto type definition" })
map("n", "<leader>s", function() Snacks.picker.lsp_symbols() end, { desc = "Document symbols" })
map("n", "<leader>S", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "Workspace symbols" })
map("n", "<leader>dd", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer diagnostics" })
map("n", "<leader>dw", function() Snacks.picker.diagnostics() end, { desc = "Workspace diagnostics" })
map("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "Command history" })
map("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands" })
map("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks" })
map("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps" })
map("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix list" })
map("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "Undo history" })
map("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume picker" })
map("n", "<leader>fk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Help pages" })
-- stylua: ignore end

-- blink.cmp

local cmp = require("blink.cmp")
cmp.build():wait(60000)
cmp.setup({
    keymap = { preset = "super-tab" },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    completion = {
        ghost_text = {
            enabled = true,
        },
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        list = {
            selection = {
                preselect = function(ctx) return not require("blink.cmp").snippet_active({ direction = 1 }) end,
            },
        },
        menu = {
            draw = {
                components = {
                    kind_icon = {
                        text = function(ctx)
                            local icon = ctx.kind_icon
                            if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                if dev_icon then icon = dev_icon end
                            else
                                icon = require("lspkind").symbolic(ctx.kind, {
                                    mode = "symbol",
                                })
                            end
                            return icon .. ctx.icon_gap
                        end,
                        highlight = function(ctx)
                            local hl = ctx.kind_hl
                            if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                                if dev_icon then hl = dev_hl end
                            end
                            return hl
                        end,
                    },
                },
            },
        },
    },
    cmdline = {
        completion = {
            menu = { auto_show = true },
            ghost_text = { enabled = true },
        },
    },
    fuzzy = { implementation = "rust" },
})

-- treesitter

require("tree-sitter-manager").setup({
    ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "go",
    },
    auto_install = true,
})

-- ============================================================================
-- LAZY: conform
-- ============================================================================

-- stylua: ignore start
local conform_setup = function()
    vim.pack.add({ gh("stevearc/conform.nvim") })
    require("conform").setup({
        formatters_by_ft = {
            lua = { "stylua" },
            markdown = { "prettier" },
            fish = { "fish_indent" },
            python = { "ruff" },
            json = { "prettier" },
        },
        default_format_opts = {
            lsp_format = "fallback",
            async = true,
        },
    })
    map("n", "<leader>f", function() require("conform").format() end, { desc = "Format buffer" })
    map("n", "<leader>w", function() require("conform").format() vim.cmd("w") end, { noremap = true, silent = true, desc = "Format and save" })
end

map("n", "<leader>f", function() conform_setup() require("conform").format() end, { desc = "Format buffer" })
map("n", "<leader>w", function() conform_setup() require("conform").format() vim.cmd("w") end, { noremap = true, silent = true, desc = "Format and save" })
-- stylua: ignore end

-- ============================================================================
-- LAZY: gitsigns
-- ============================================================================

do
    local g = vim.api.nvim_create_augroup("LazyGitsigns", { clear = true })
    vim.api.nvim_create_autocmd("BufReadPre", {
        group = g,
        once = true,
        callback = function()
            vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
            require("gitsigns").setup({
                signs = {
                    add = { text = "▎" },
                    change = { text = "▎" },
                    delete = { text = "" },
                    topdelete = { text = "" },
                    changedelete = { text = "▎" },
                    untracked = { text = "▎" },
                },
                signs_staged = {
                    add = { text = "▎" },
                    change = { text = "▎" },
                    delete = { text = "" },
                    topdelete = { text = "" },
                    changedelete = { text = "▎" },
                },
            })
        end,
    })
end

-- stylua: ignore start
map("n", "]h", function()
    if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else require("gitsigns").nav_hunk("next") end
end, { desc = "Next hunk" })
map("n", "[h", function()
    if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else require("gitsigns").nav_hunk("prev") end
end, { desc = "Prev hunk" })
map("n", "]H", function() require("gitsigns").nav_hunk("last") end, { desc = "Last hunk" })
map("n", "[H", function() require("gitsigns").nav_hunk("first") end, { desc = "First hunk" })
map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
map("n", "<leader>ghS", function() require("gitsigns").stage_buffer() end, { desc = "Stage buffer" })
map("n", "<leader>ghu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Undo stage hunk" })
map("n", "<leader>ghR", function() require("gitsigns").reset_buffer() end, { desc = "Reset buffer" })
map("n", "<leader>ghp", function() require("gitsigns").preview_hunk_inline() end, { desc = "Preview hunk" })
map("n", "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end, { desc = "Blame line" })
map("n", "<leader>ghB", function() require("gitsigns").blame() end, { desc = "Blame buffer" })
map("n", "<leader>ghd", function() require("gitsigns").diffthis() end, { desc = "Diff this" })
map("n", "<leader>ghD", function() require("gitsigns").diffthis("~") end, { desc = "Diff this ~" })
map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
-- stylua: ignore end

-- ============================================================================
-- LAZY: harpoon
-- ============================================================================

-- stylua: ignore start
local harpoon_setup = function()
    vim.pack.add({ { src = gh("ThePrimeagen/harpoon"), version = "harpoon2" } })
    local harpoon = require("harpoon")
    harpoon:setup({
        settings = {
            save_on_toggle = true,
            sync_on_ui_close = true,
        },
    })
    map("n", "<leader>a", function() require("harpoon"):list():add() end, { desc = "Add to harpoon" })
    map("n", "<A-;>", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, { desc = "Harpoon menu" })
    map("n", "<A-h>", function() require("harpoon"):list():select(1) end, { desc = "Harpoon file 1" })
    map("n", "<A-t>", function() require("harpoon"):list():select(2) end, { desc = "Harpoon file 2" })
    map("n", "<A-n>", function() require("harpoon"):list():select(3) end, { desc = "Harpoon file 3" })
    map("n", "<A-s>", function() require("harpoon"):list():select(4) end, { desc = "Harpoon file 4" })
    return harpoon
end

map("n", "<leader>a", function() harpoon_setup():list():add() end, { desc = "Add to harpoon" })
map("n", "<A-;>", function() local h = harpoon_setup() h.ui:toggle_quick_menu(h:list()) end, { desc = "Harpoon menu" })
map("n", "<A-h>", function() harpoon_setup():list():select(1) end, { desc = "Harpoon file 1" })
map("n", "<A-t>", function() harpoon_setup():list():select(2) end, { desc = "Harpoon file 2" })
map("n", "<A-n>", function() harpoon_setup():list():select(3) end, { desc = "Harpoon file 3" })
map("n", "<A-s>", function() harpoon_setup():list():select(4) end, { desc = "Harpoon file 4" })
-- stylua: ignore end

-- ============================================================================
-- LAZY: spectre
-- ============================================================================

-- stylua: ignore start
local spectre_setup = function()
    vim.pack.add({ gh("nvim-pack/nvim-spectre") })
    map("n", "gs", '<cmd>lua require("spectre").toggle()<CR>', { desc = "Toggle Spectre" })
    map("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = "Search word" })
    map("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Search visual selection" })
    map("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', { desc = "Search file" })
end

map("n", "gs", function() spectre_setup() require("spectre").toggle() end, { desc = "Toggle Spectre" })
map("n", "<leader>sw", function() spectre_setup() require("spectre").open_visual({ select_word = true }) end, { desc = "Search word" })
map("v", "<leader>sw", function() spectre_setup() require("spectre").open_visual() end, { desc = "Search visual selection" })
map("n", "<leader>sp", function() spectre_setup() require("spectre").open_file_search({ select_word = true }) end, { desc = "Search file" })
-- stylua: ignore end

-- ============================================================================
-- LAZY: trouble
-- ============================================================================

-- stylua: ignore start
local trouble_setup = function()
    vim.pack.add({ gh("folke/trouble.nvim") })
    require("trouble").setup({ focus = true })
    vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        callback = function() vim.cmd([[Trouble qflist open]]) end,
    })
    map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
    map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics (Trouble)" })
    map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
    map("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "LSP references (Trouble)" })
    map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location list (Trouble)" })
    map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list (Trouble)" })
    map("n", "[q", function() if require("trouble").is_open() then require("trouble").prev({ skip_groups = true, jump = true }) else local ok, err = pcall(vim.cmd.cprev) if not ok then vim.notify(err, vim.log.levels.ERROR) end end end, { desc = "Previous trouble/quickfix item" })
    map("n", "]q", function() if require("trouble").is_open() then require("trouble").next({ skip_groups = true, jump = true }) else local ok, err = pcall(vim.cmd.cnext) if not ok then vim.notify(err, vim.log.levels.ERROR) end end end, { desc = "Next trouble/quickfix item" })
end

map("n", "<leader>xx", function() trouble_setup() vim.cmd("Trouble diagnostics toggle") end, { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", function() trouble_setup() vim.cmd("Trouble diagnostics toggle filter.buf=0") end, { desc = "Buffer diagnostics (Trouble)" })
map("n", "<leader>cs", function() trouble_setup() vim.cmd("Trouble symbols toggle focus=false") end, { desc = "Symbols (Trouble)" })
map("n", "<leader>cl", function() trouble_setup() vim.cmd("Trouble lsp toggle focus=false win.position=right") end, { desc = "LSP references (Trouble)" })
map("n", "<leader>xL", function() trouble_setup() vim.cmd("Trouble loclist toggle") end, { desc = "Location list (Trouble)" })
map("n", "<leader>xQ", function() trouble_setup() vim.cmd("Trouble qflist toggle") end, { desc = "Quickfix list (Trouble)" })
map("n", "[q", function() trouble_setup() if require("trouble").is_open() then require("trouble").prev({ skip_groups = true, jump = true }) else local ok, err = pcall(vim.cmd.cprev) if not ok then vim.notify(err, vim.log.levels.ERROR) end end end, { desc = "Previous trouble/quickfix item" })
map("n", "]q", function() trouble_setup() if require("trouble").is_open() then require("trouble").next({ skip_groups = true, jump = true }) else local ok, err = pcall(vim.cmd.cnext) if not ok then vim.notify(err, vim.log.levels.ERROR) end end end, { desc = "Next trouble/quickfix item" })
-- stylua: ignore end

-- ============================================================================
-- LAZY: smart-splits
-- ============================================================================

-- stylua: ignore start
local smart_splits_setup = function()
    vim.pack.add({ gh("mrjones2014/smart-splits.nvim") })
    map("n", "<A-Left>", function() require("smart-splits").resize_left() end, { desc = "Resize left" })
    map("n", "<A-Down>", function() require("smart-splits").resize_down() end, { desc = "Resize down" })
    map("n", "<A-Up>", function() require("smart-splits").resize_up() end, { desc = "Resize up" })
    map("n", "<A-Right>", function() require("smart-splits").resize_right() end, { desc = "Resize right" })
    map("n", "<C-Left>", function() require("smart-splits").move_cursor_left() end, { desc = "Move to left split" })
    map("n", "<C-Down>", function() require("smart-splits").move_cursor_down() end, { desc = "Move to below split" })
    map("n", "<C-Up>", function() require("smart-splits").move_cursor_up() end, { desc = "Move to above split" })
    map("n", "<C-Right>", function() require("smart-splits").move_cursor_right() end, { desc = "Move to right split" })
    map("n", "<C-\\>", function() require("smart-splits").move_cursor_previous() end, { desc = "Move to previous split" })
    map("n", "<leader><leader>Left", function() require("smart-splits").swap_buf_right() end, { desc = "Swap buffer right" })
    map("n", "<leader><leader>Down", function() require("smart-splits").swap_buf_down() end, { desc = "Swap buffer down" })
    map("n", "<leader><leader>Up", function() require("smart-splits").swap_buf_up() end, { desc = "Swap buffer up" })
    map("n", "<leader><leader>Right", function() require("smart-splits").swap_buf_left() end, { desc = "Swap buffer left" })
end

map("n", "<A-Left>", function() smart_splits_setup() require("smart-splits").resize_left() end, { desc = "Resize left" })
map("n", "<A-Down>", function() smart_splits_setup() require("smart-splits").resize_down() end, { desc = "Resize down" })
map("n", "<A-Up>", function() smart_splits_setup() require("smart-splits").resize_up() end, { desc = "Resize up" })
map("n", "<A-Right>", function() smart_splits_setup() require("smart-splits").resize_right() end, { desc = "Resize right" })
map("n", "<C-Left>", function() smart_splits_setup() require("smart-splits").move_cursor_left() end, { desc = "Move to left split" })
map("n", "<C-Down>", function() smart_splits_setup() require("smart-splits").move_cursor_down() end, { desc = "Move to below split" })
map("n", "<C-Up>", function() smart_splits_setup() require("smart-splits").move_cursor_up() end, { desc = "Move to above split" })
map("n", "<C-Right>", function() smart_splits_setup() require("smart-splits").move_cursor_right() end, { desc = "Move to right split" })
map("n", "<C-\\>", function() smart_splits_setup() require("smart-splits").move_cursor_previous() end, { desc = "Move to previous split" })
map("n", "<leader><leader>Left", function() smart_splits_setup() require("smart-splits").swap_buf_right() end, { desc = "Swap buffer right" })
map("n", "<leader><leader>Down", function() smart_splits_setup() require("smart-splits").swap_buf_down() end, { desc = "Swap buffer down" })
map("n", "<leader><leader>Up", function() smart_splits_setup() require("smart-splits").swap_buf_up() end, { desc = "Swap buffer up" })
map("n", "<leader><leader>Right", function() smart_splits_setup() require("smart-splits").swap_buf_left() end, { desc = "Swap buffer left" })
-- stylua: ignore end

-- ============================================================================
-- LAZY: render-markdown
-- ============================================================================

do
    local g = vim.api.nvim_create_augroup("LazyRenderMarkdown", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        group = g,
        once = true,
        callback = function()
            vim.pack.add({ gh("MeanderingProgrammer/render-markdown.nvim") })
            require("render-markdown").setup({
                latex = { enabled = false },
                file_types = { "markdown", "copilot-chat" },
                pipe_table = {
                    preset = "round",
                    min_width = 15,
                },
                completions = { lsp = { enabled = true }, blink = { enabled = true } },
                render_modes = true,
                checkbox = {
                    enabled = true,
                    render_modes = false,
                    bullet = false,
                    right_pad = 1,
                    unchecked = {
                        icon = "󰄱 ",
                        highlight = "RenderMarkdownUnchecked",
                        scope_highlight = nil,
                    },
                    checked = {
                        icon = "󰱒 ",
                        highlight = "RenderMarkdownChecked",
                        scope_highlight = "@markup.strikethrough",
                    },
                    custom = {
                        todo = {
                            raw = "[/]",
                            rendered = "󰥔 ",
                            highlight = "RenderMarkdownTodo",
                            scope_highlight = nil,
                        },
                    },
                },
            })
        end,
    })
end

-- ============================================================================
-- LAZY: mkdnflow
-- ============================================================================

do
    local g = vim.api.nvim_create_augroup("LazyMkdnflow", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        group = g,
        once = true,
        callback = function()
            vim.pack.add({ gh("jakewvincent/mkdnflow.nvim") })
            require("mkdnflow").setup({
                perspective = {
                    priority = "root",
                    root_tell = "start_page.md",
                },
                links = {
                    style = "markdown",
                    transform_explicit = function(text)
                        text = text:gsub(" ", "-")
                        text = text:lower()
                        return text
                    end,
                },
                to_do = {
                    highlight = false,
                    statuses = {
                        not_started = { marker = " " },
                        in_progress = { marker = "-" },
                        complete = { marker = { "X", "x" } },
                    },
                    status_order = { "not_started", "in_progress", "complete" },
                    status_propagation = { up = true, down = true },
                    sort = {
                        on_status_change = false,
                        recursive = false,
                        cursor_behavior = { track = true },
                    },
                },
                tables = {
                    trim_whitespace = true,
                    format_on_move = true,
                    style = {
                        cell_padding = 1,
                        separator_padding = 1,
                        outer_pipes = true,
                        mimic_alignment = true,
                    },
                },
                mappings = {
                    MkdnFoldSection = false,
                    MkdnUnfoldSection = false,
                },
            })
        end,
    })
end

-- ============================================================================
-- LAZY: neogit
-- ============================================================================

map("n", "<leader>gg", function()
    vim.pack.add({
        gh("NeogitOrg/neogit"),
        gh("sindrets/diffview.nvim"),
        gh("esmuellert/codediff.nvim"),
        gh("m00qek/baleia.nvim"),
    })
    require("neogit").setup({
        integrations = {
            snacks = true,
            diffview = true,
        },
        diff_viewer = "diffview",
        graph_style = "kitty",
        kind = "tab",
        signs = {
            item = { "", "" },
            section = { "", "" },
        },
    })
    vim.cmd("Neogit")
    map("n", "<leader>gg", "<cmd>Neogit<CR>", { desc = "Neogit" })
end, { desc = "Neogit" })

-- ============================================================================
-- UTILITY COMMAND: LazyLoadAll
-- ============================================================================

vim.api.nvim_create_user_command("UpdateAll", function()
    vim.pack.add({
        gh("stevearc/conform.nvim"),
        gh("lewis6991/gitsigns.nvim"),
        { src = gh("ThePrimeagen/harpoon"), version = "harpoon2" },
        gh("MeanderingProgrammer/render-markdown.nvim"),
        gh("jakewvincent/mkdnflow.nvim"),
        gh("nvim-pack/nvim-spectre"),
        gh("folke/trouble.nvim"),
        gh("mrjones2014/smart-splits.nvim"),
        gh("NeogitOrg/neogit"),
        gh("sindrets/diffview.nvim"),
        gh("esmuellert/codediff.nvim"),
        gh("m00qek/baleia.nvim"),
    })
    vim.pack.update()
end, { desc = "Load all lazy plugins and update" })
