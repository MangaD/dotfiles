-- =============================================================================
-- Leader keys
-- =============================================================================

-- Use Space as the main leader key.
--
-- The leader key acts as a prefix for custom shortcuts, allowing related
-- commands to be grouped under memorable key sequences.
--
-- For example:
--
--     Space + r + n    Rename symbol
--     Space + c + a    Code action
--
-- The leader key should be configured before plugins and mappings are loaded so
-- every `<leader>` mapping consistently resolves to Space.
vim.g.mapleader = " "

-- Use Space as the local leader key as well.
--
-- `<localleader>` is intended for mappings that apply only to a particular
-- filetype, buffer, or plugin. We do not currently use it, but defining it now
-- keeps future mappings predictable.
vim.g.maplocalleader = " "


-- =============================================================================
-- Clipboard
-- =============================================================================

-- Use OSC 52 for clipboard integration.
--
-- OSC 52 allows Neovim to copy text through the terminal, which is especially
-- useful when Neovim is running on a remote machine over SSH or inside tmux.
local osc52 = require("vim.ui.clipboard.osc52")

vim.g.clipboard = {
    name = "OSC 52",

    copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
    },

    paste = {
        ["+"] = osc52.paste("+"),
        ["*"] = osc52.paste("*"),
    },
}

-- Use the system clipboard by default for normal yank, delete, and paste
-- operations.
vim.opt.clipboard = "unnamedplus"


-- =============================================================================
-- General editing
-- =============================================================================

-- Show absolute line numbers.
vim.opt.number = true

-- Highlight the line containing the cursor.
vim.opt.cursorline = true

-- Do not visually wrap long lines.
vim.opt.wrap = false

-- Show a vertical guide at column 85.
vim.opt.colorcolumn = "85"

-- Enable true-color support.
vim.opt.termguicolors = true

-- Keep some context visible above and below the cursor while scrolling.
vim.opt.scrolloff = 5

-- Keep some context visible while scrolling horizontally.
vim.opt.sidescrolloff = 5


-- =============================================================================
-- Tabs and indentation
-- =============================================================================

-- Default indentation used when the indentation style cannot be inferred from
-- the current file.
--
-- `guess-indent.nvim` examines existing files and overrides these values
-- locally when it can determine their indentation style.

-- Display tab characters as four columns wide.
vim.opt.tabstop = 4

-- Use four columns when shifting indentation.
vim.opt.shiftwidth = 4

-- Treat Tab and Backspace as four columns while editing.
vim.opt.softtabstop = 4

-- Insert real tab characters instead of spaces.
vim.opt.expandtab = false

-- Preserve indentation from the previous line.
vim.opt.autoindent = true


-- =============================================================================
-- Searching
-- =============================================================================

-- Ignore case when searching...
vim.opt.ignorecase = true

-- ...unless the search contains uppercase characters.
vim.opt.smartcase = true

-- Show matches while entering a search pattern.
vim.opt.incsearch = true

-- Highlight all matches of the current search.
vim.opt.hlsearch = true


-- =============================================================================
-- Whitespace
-- =============================================================================

-- Display otherwise invisible whitespace characters.
vim.opt.list = true

vim.opt.listchars = {
    lead = "·",
    tab = "→ ",
    trail = "·",
    extends = ">",
    precedes = "<",
}


-- =============================================================================
-- Completion
-- =============================================================================

-- Show the completion menu without automatically inserting or selecting an
-- entry.
vim.opt.completeopt = {
    "menuone",
    "noinsert",
    "noselect",
}


-- =============================================================================
-- Persistent undo
-- =============================================================================

-- Keep undo history when closing and reopening files.
vim.opt.undofile = true


-- =============================================================================
-- Mappings
-- =============================================================================

-- Move the current line down or up.
--
-- Both Vim-style keys and arrow keys are available:
--
--     Alt+j       Move down
--     Alt+k       Move up
--     Alt+Down    Move down
--     Alt+Up      Move up
vim.keymap.set("n", "<A-j>", ":move .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":move .-2<CR>==")
vim.keymap.set("n", "<A-Down>", ":move .+1<CR>==")
vim.keymap.set("n", "<A-Up>", ":move .-2<CR>==")

-- Move visually selected lines while keeping the selection active.
vim.keymap.set("v", "<A-j>", ":move '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":move '<-2<CR>gv=gv")
vim.keymap.set("v", "<A-Down>", ":move '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-Up>", ":move '<-2<CR>gv=gv")


-- -----------------------------------------------------------------------------
-- Saving
-- -----------------------------------------------------------------------------

-- Save the current file using the familiar Ctrl+s shortcut.
--
-- The mapping is available in Normal, Insert, and Visual modes:
--
--     Ctrl+s    Save current file
--
-- In Insert mode, the file is saved without permanently leaving Insert mode.
-- In Visual mode, the selection remains active after saving.
--
-- Note:
-- Some terminals use Ctrl+s for XON/XOFF software flow control. If Ctrl+s
-- appears to freeze the terminal instead of reaching Neovim, check whether
-- flow control is enabled with:
--
--     stty -a
--
-- If `ixon` is enabled, it can be disabled for the current terminal with:
--
--     stty -ixon
--
-- Ctrl+q traditionally resumes terminal output when XON/XOFF flow control is
-- enabled. Do not disable flow control globally unless it actually interferes
-- with the mapping in the terminal environment being used.

-- Normal mode: save the current file.
vim.keymap.set(
    "n",
    "<C-s>",
    "<cmd>write<CR>",
    { desc = "Save file" }
)

-- Insert mode: save without permanently leaving Insert mode.
vim.keymap.set(
    "i",
    "<C-s>",
    "<C-o><cmd>write<CR>",
    { desc = "Save file" }
)

-- Visual mode: save and restore the current Visual selection.
vim.keymap.set(
    "v",
    "<C-s>",
    "<cmd>write<CR>gv",
    { desc = "Save file" }
)


-- =============================================================================
-- Integrated terminal
-- =============================================================================

-- Keep track of the terminal buffer so the same terminal can be reopened
-- instead of creating a new shell every time.
local terminal_buf = nil

local function toggle_terminal()
    -- If the terminal is currently visible, close its window but keep the
    -- terminal process and buffer alive.
    if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
        local windows = vim.fn.win_findbuf(terminal_buf)

        if #windows > 0 then
            vim.api.nvim_win_close(windows[1], false)
            return
        end

        -- The terminal still exists but is hidden, so reopen it at the bottom.
        vim.cmd("botright 12split")
        vim.api.nvim_win_set_buf(0, terminal_buf)
        vim.cmd("startinsert")
        return
    end

    -- No terminal exists yet. Create one in a bottom split and remember its
    -- buffer so it can be toggled later.
    vim.cmd("botright 12split")
    vim.cmd("terminal")

    terminal_buf = vim.api.nvim_get_current_buf()

    vim.cmd("startinsert")
end

-- Toggle the integrated terminal.
--
--     Ctrl+\    Show/hide terminal
vim.keymap.set(
    "n",
    "<C-\\>",
    toggle_terminal,
    { desc = "Toggle terminal" }
)

-- Allow the same shortcut to hide the terminal while typing in it.
vim.keymap.set(
    "t",
    "<C-\\>",
    function()
        vim.cmd("stopinsert")
        toggle_terminal()
    end,
    { desc = "Toggle terminal" }
)

-- Escape leaves Terminal mode and returns to Normal mode.
vim.keymap.set(
    "t",
    "<Esc>",
    [[<C-\><C-n>]],
    { desc = "Leave terminal mode" }
)


-- =============================================================================
-- Plugin manager
-- =============================================================================

-- Bootstrap lazy.nvim if it has not been installed yet.
--
-- lazy.nvim manages the plugins used below and records installed plugin
-- versions in lazy-lock.json.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)


-- =============================================================================
-- Plugins
-- =============================================================================

require("lazy").setup({

    -- -------------------------------------------------------------------------
    -- Color schemes
    -- -------------------------------------------------------------------------

    -- VS Code-inspired color scheme.
    {
        "Mofiqul/vscode.nvim",

        priority = 1000,

        config = function()
            require("vscode").setup({
                style = "dark",
                italic_comments = false,
                transparent = false,
            })

            -- This is the default color scheme applied when Neovim starts.
            vim.cmd.colorscheme("vscode")
        end,
    },

    -- Catppuccin.
    --
    -- A modern pastel color scheme with several variants:
    --
    --     catppuccin-latte       Light
    --     catppuccin-frappe      Dark
    --     catppuccin-macchiato   Dark
    --     catppuccin-mocha       Dark
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
    },

    -- Tokyo Night.
    --
    -- A modern dark color scheme inspired by nighttime city colors.
    --
    -- Available variants include:
    --
    --     tokyonight-night
    --     tokyonight-storm
    --     tokyonight-moon
    --     tokyonight-day
    {
        "folke/tokyonight.nvim",
        priority = 1000,
    },

    -- Kanagawa.
    --
    -- A darker, warmer color scheme inspired by traditional Japanese colors.
    --
    -- Available variants include:
    --
    --     kanagawa-wave
    --     kanagawa-dragon
    --     kanagawa-lotus
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
    },

    -- Gruvbox.
    --
    -- A classic Vim color scheme with warm, retro-looking colors and strong
    -- contrast. This implementation provides modern Neovim integration while
    -- retaining the traditional Gruvbox appearance.
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
    },


    -- -------------------------------------------------------------------------
    -- File explorer
    -- -------------------------------------------------------------------------

    {
        "nvim-tree/nvim-tree.lua",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            require("nvim-tree").setup({
                view = {
                    -- Keep the explorer on the left, similar to VS Code.
                    side = "left",

                    -- Width of the file explorer.
                    width = 30,
                },

                renderer = {
                    -- Show icons for files, folders, and Git state.
                    icons = {
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = true,
                        },
                    },
                },
            })

            -- Toggle the explorer with Ctrl+n.
            vim.keymap.set(
                "n",
                "<C-n>",
                "<cmd>NvimTreeToggle<CR>",
                { desc = "Toggle file explorer" }
            )
        end,
    },


    -- -------------------------------------------------------------------------
    -- File and folder icons
    -- -------------------------------------------------------------------------

    {
        "nvim-tree/nvim-web-devicons",
    },


    -- -------------------------------------------------------------------------
    -- Status line
    -- -------------------------------------------------------------------------

    {
        "nvim-lualine/lualine.nvim",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            -- Display the indentation style currently active for this buffer.
            --
            -- `expandtab` tells us whether Neovim inserts spaces or real tab
            -- characters.
            --
            -- `shiftwidth` tells us the indentation width. Since guess-indent.nvim
            -- adjusts these options per buffer, this reflects the indentation that
            -- was actually detected for the current file.
            local function indentation()
                if vim.bo.expandtab then
                    return "Spaces: " .. vim.bo.shiftwidth
                end

                return "Tab Size: " .. vim.bo.tabstop
            end


            -- Display the operating-system icon together with the current file's
            -- line-ending convention.
            --
            --     Unix/Linux     LF
            --     Windows        CRLF
            --     classic Mac    CR
            --
            -- The icons require a Nerd Font.
            -- CR is included for completeness, although it is rarely encountered
            -- in modern files.
            local function line_ending()
                local formats = {
                    unix = " LF",
                    dos = " CRLF",
                    mac = " CR",
                }

                return formats[vim.bo.fileformat] or vim.bo.fileformat
            end


            require("lualine").setup({
                options = {
                    theme = "auto",

                    -- Keep the visual style relatively simple.
                    section_separators = "",
                    component_separators = "|",

                    -- Make the status line available in all normal editor windows.
                    globalstatus = true,
                },

                sections = {
                    -- Left side --------------------------------------------------

                    lualine_a = {
                        -- Current Neovim mode:
                        --
                        -- NORMAL, INSERT, VISUAL, etc.
                        "mode",
                    },

                    lualine_b = {
                        -- Current Git branch.
                        "branch",

                        -- Number of added, modified, and removed lines according to
                        -- Git.
                        "diff",

                        -- Errors, warnings, information, and hints.
                        --
                        -- These become especially useful once LSP support is
                        -- configured.
                        "diagnostics",
                    },

                    lualine_c = {
                        -- Current filename.
                        --
                        -- path = 1 displays the path relative to the working
                        -- directory rather than only the basename.
                        {
                            "filename",
                            path = 1,

                            symbols = {
                                modified = " [+]",
                                readonly = " [RO]",
                                unnamed = "[No Name]",
                                newfile = " [New]",
                            },
                        },
                    },


                    -- Right side -------------------------------------------------

                    lualine_x = {
                        -- Number of search matches while a highlighted search is active.
                        --
                        -- Example:
                        --
                        --     3/17
                        --
                        -- meaning the cursor is on the third of 17 matches.
                        "searchcount",

                        -- Number of characters or lines currently selected in Visual mode.
                        --
                        -- Hidden when there is no active Visual selection.
                        "selectioncount",

                        -- Text encoding used by the current file.
                        --
                        -- Usually:
                        --
                        --     utf-8
                        "encoding",

                        -- Operating-system icon and line-ending convention.
                        --
                        -- This is our custom component rather than Lualine's built-in
                        -- `fileformat`, so that both the icon and explicit line-ending format are
                        -- shown.
                        --
                        -- Examples:
                        --
                        --      LF
                        --      CRLF
                        --      CR
                        line_ending,

                        -- Indentation style currently active for this buffer.
                        --
                        -- guess-indent.nvim adjusts the relevant Neovim options per buffer, so
                        -- this reflects the indentation detected for the current file.
                        --
                        -- Examples:
                        --
                        --     Spaces: 4
                        --     Spaces: 2
                        --     Tab Size: 4
                        indentation,

                        -- Size of the current file.
                        --
                        -- Lualine automatically formats the value using an appropriate unit.
                        --
                        -- Examples:
                        --
                        --     842 B
                        --     12.4K
                        --     1.8M
                        "filesize",

                        -- Filetype detected for the current buffer.
                        --
                        -- Examples:
                        --
                        --     lua
                        --     c
                        --     cpp
                        --     markdown
                        "filetype",

                        -- Active LSP clients and LSP progress for the current buffer.
                        --
                        -- This will become useful once Language Server Protocol support is
                        -- configured.
                        "lsp_status",
                    },

                    lualine_y = {
                        -- Percentage through the current file.
                        --
                        -- Examples:
                        --
                        --     Top
                        --     42%
                        --     Bot
                        "progress",
                    },

                    lualine_z = {
                        -- Current cursor position as line:column.
                        "location",
                    },
                },
            })
        end,
    },


    -- -------------------------------------------------------------------------
    -- Buffer tabs
    -- -------------------------------------------------------------------------

    {
        "akinsho/bufferline.nvim",

        version = "*",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            require("bufferline").setup({
                options = {
                    -- Display open buffers rather than Vim tab pages.
                    --
                    -- A buffer represents an open file in Neovim, so this
                    -- produces behavior closer to VS Code's editor tabs.
                    mode = "buffers",

                    -- Display diagnostics reported by Neovim's LSP client.
                    --
                    -- This will become useful later when LSP support is added.
                    -- Until then, it has no significant effect.
                    diagnostics = "nvim_lsp",

                    -- Show filetype icons provided by nvim-web-devicons.
                    show_buffer_icons = true,

                    -- Show a close button on each individual buffer.
                    show_buffer_close_icons = true,

                    -- Do not show an additional close button at the far right
                    -- of the entire buffer line.
                    show_close_icon = false,

                    -- Separate buffers using a thin line rather than decorative
                    -- or slanted separators.
                    separator_style = "thin",

                    -- Hide buffers that should not be represented as editor tabs.
                    custom_filter = function(bufnr)
                        -- Terminal buffers belong to the integrated terminal panel rather
                        -- than the editor's list of open files.
                        if vim.bo[bufnr].buftype == "terminal" then
                            return false
                        end

                        return true
                    end,

                    -- Keep the file explorer visually separate from the buffer
                    -- tabs.
                    --
                    -- When nvim-tree is open on the left, this reserves the
                    -- corresponding portion of the buffer line and displays
                    -- "Explorer" above it.
                    offsets = {
                        {
                            filetype = "NvimTree",
                            text = "Explorer",
                            text_align = "center",
                            separator = true,
                        },
                    },
                },
            })


            -- -----------------------------------------------------------------
            -- Buffer navigation
            -- -----------------------------------------------------------------

            -- Move to the previous or next open buffer.
            --
            -- These behave similarly to moving between editor tabs in VS Code:
            --
            --     Alt+Left     Previous buffer
            --     Alt+Right    Next buffer
            vim.keymap.set(
                "n",
                "<A-Left>",
                "<cmd>BufferLineCyclePrev<CR>",
                { desc = "Previous buffer" }
            )

            vim.keymap.set(
                "n",
                "<A-Right>",
                "<cmd>BufferLineCycleNext<CR>",
                { desc = "Next buffer" }
            )

            -- Move the current buffer left or right in the buffer line.
            --
            -- This changes only the visual/order position of the buffer in Bufferline;
            -- it does not modify the file or move any editor windows.
            --
            --     Alt+Shift+Left     Move buffer left
            --     Alt+Shift+Right    Move buffer right
            vim.keymap.set(
                "n",
                "<A-S-Left>",
                "<cmd>BufferLineMovePrev<CR>",
                { desc = "Move buffer left" }
            )

            vim.keymap.set(
                "n",
                "<A-S-Right>",
                "<cmd>BufferLineMoveNext<CR>",
                { desc = "Move buffer right" }
            )

            -- Close the current buffer while preserving the surrounding window layout.
            --
            -- Unlike a plain `:bdelete`, BufDel is designed to remove the buffer without
            -- unexpectedly collapsing editor windows or closing sidebars such as
            -- nvim-tree.
            --
            --     Alt+w    Close current buffer
            vim.keymap.set(
                "n",
                "<A-w>",
                "<cmd>BufDel<CR>",
                { desc = "Close current buffer" }
            )
        end,
    },


    -- -------------------------------------------------------------------------
    -- Safe buffer deletion
    -- -------------------------------------------------------------------------

    {
        "ojroques/nvim-bufdel",

        config = function()
            require("bufdel").setup({
                -- When closing a buffer, switch the editor window to another
                -- available buffer instead of closing the window itself.
                --
                -- This helps preserve layouts containing components such as
                -- nvim-tree and the integrated terminal.
                next = "tabs",

                -- Do not force-close buffers containing unsaved changes.
                quit = false,
            })
        end,
    },


    -- -------------------------------------------------------------------------
    -- Indentation detection
    -- -------------------------------------------------------------------------

    {
        "NMAC427/guess-indent.nvim",

        config = function()
            require("guess-indent").setup({
                -- Use the detected indentation style for each buffer.
                --
                -- The plugin examines the contents of a file when it is opened and
                -- determines whether indentation uses tabs or spaces and, for
                -- spaces, the likely indentation width.
                --
                -- The result is applied locally to that buffer, so different files
                -- can use different indentation styles without changing the global
                -- Neovim configuration.
            })
        end,
    },


    -- -----------------------------------------------------------------------------
    -- Tree-sitter parser management
    -- -----------------------------------------------------------------------------

    {
        "nvim-treesitter/nvim-treesitter",

        -- The current nvim-treesitter implementation is intended to be available
        -- from startup rather than lazy-loaded.
        lazy = false,

        -- Keep installed parsers synchronized with the installed
        -- nvim-treesitter version whenever the plugin is updated.
        build = ":TSUpdate",

        config = function()
            require("nvim-treesitter").setup({})
        end,
    },


    -- -----------------------------------------------------------------------------
    -- Language Server Protocol
    -- -----------------------------------------------------------------------------

    {
        "neovim/nvim-lspconfig",

        config = function()
            -- Enable the clangd configuration provided by nvim-lspconfig.
            --
            -- clangd provides C and C++ language intelligence including:
            --
            --   - diagnostics
            --   - go to definition
            --   - references
            --   - hover documentation
            --   - symbol renaming
            --   - code actions
            --
            -- The clangd executable must be installed separately and available in
            -- PATH. Neovim does not install language servers itself.
            vim.lsp.enable("clangd")
        end,
    },

})


-- =============================================================================
-- Color scheme selection
-- =============================================================================

local colorschemes = {
    "vscode",
    "catppuccin-mocha",
    "catppuccin-macchiato",
    "tokyonight-night",
    "tokyonight-moon",
    "kanagawa-wave",
    "kanagawa-dragon",
    "gruvbox",
}

local colorscheme_index = 7
vim.cmd.colorscheme(colorschemes[colorscheme_index])


-- Apply the currently selected color scheme and display its name.
--
-- The notification is scheduled after the theme has finished loading because
-- some color schemes trigger redraws that can otherwise hide the message.
local function apply_colorscheme()
    local colorscheme = colorschemes[colorscheme_index]

    vim.cmd.colorscheme(colorscheme)

    vim.schedule(function()
        vim.notify("Color scheme: " .. colorscheme)
    end)
end


-- Switch to the previous color scheme.
--
--     F7    Previous theme
vim.keymap.set(
    "n",
    "<F7>",
    function()
        colorscheme_index =
            (colorscheme_index - 2) % #colorschemes + 1

        apply_colorscheme()
    end,
    { desc = "Previous color scheme" }
)


-- Switch to the next color scheme.
--
--     F8    Next theme
vim.keymap.set(
    "n",
    "<F8>",
    function()
        colorscheme_index =
            colorscheme_index % #colorschemes + 1

        apply_colorscheme()
    end,
    { desc = "Next color scheme" }
)


-- =============================================================================
-- Tree-sitter
-- =============================================================================

-- Map Neovim filetypes to their corresponding Tree-sitter language/parser
-- names.
--
-- Most names are identical, but some differ. Keeping the mapping explicit also
-- lets us control exactly which filetypes use Tree-sitter highlighting.
local treesitter_languages = {
    bash = "bash",
    c = "c",
    cpp = "cpp",
    gitconfig = "git_config",
    gitignore = "gitignore",
    lua = "lua",
    markdown = "markdown",
    sshconfig = "ssh_config",
    vim = "vim",
    help = "vimdoc",
}


-- -----------------------------------------------------------------------------
-- Dependency checks
-- -----------------------------------------------------------------------------

-- Check whether the external tools required to install Tree-sitter parsers are
-- available.
--
-- nvim-treesitter requires:
--
--   - tar
--   - curl
--   - tree-sitter-cli >= 0.26.1
--   - a C compiler
--
-- These tools are required for installing/building parsers. Existing parsers
-- may still work when one of these tools is missing, so missing dependencies
-- produce a warning rather than preventing Tree-sitter from loading.
local function check_treesitter_dependencies()
    local missing = {}


    -- -------------------------------------------------------------------------
    -- tar
    -- -------------------------------------------------------------------------

    if vim.fn.executable("tar") ~= 1 then
        table.insert(missing, "tar")
    end


    -- -------------------------------------------------------------------------
    -- curl
    -- -------------------------------------------------------------------------

    if vim.fn.executable("curl") ~= 1 then
        table.insert(missing, "curl")
    end


    -- -------------------------------------------------------------------------
    -- tree-sitter CLI
    -- -------------------------------------------------------------------------

    if vim.fn.executable("tree-sitter") ~= 1 then
        table.insert(
            missing,
            "tree-sitter-cli >= 0.26.1"
        )
    else
        -- `tree-sitter --version` normally returns something similar to:
        --
        --     tree-sitter 0.26.3
        --
        -- Extract the semantic version and verify the required minimum.
        local output =
            vim.fn.system({ "tree-sitter", "--version" })

        local major, minor, patch =
            output:match("(%d+)%.(%d+)%.(%d+)")

        if major and minor and patch then
            major = tonumber(major)
            minor = tonumber(minor)
            patch = tonumber(patch)

            local version_ok =
                major > 0
                or minor > 26
                or (minor == 26 and patch >= 1)

            if not version_ok then
                table.insert(
                    missing,
                    string.format(
                        "tree-sitter-cli >= 0.26.1 (found %d.%d.%d)",
                        major,
                        minor,
                        patch
                    )
                )
            end
        else
            table.insert(
                missing,
                "tree-sitter-cli >= 0.26.1 "
                    .. "(unable to determine installed version)"
            )
        end
    end


    -- -------------------------------------------------------------------------
    -- C compiler
    -- -------------------------------------------------------------------------

    -- Accept any commonly available C compiler rather than requiring a
    -- particular implementation.
    local compilers = {
        "cc",
        "gcc",
        "clang",
    }

    local compiler_found = false

    for _, compiler in ipairs(compilers) do
        if vim.fn.executable(compiler) == 1 then
            compiler_found = true
            break
        end
    end

    if not compiler_found then
        table.insert(
            missing,
            "C compiler (cc, gcc, or clang)"
        )
    end


    -- -------------------------------------------------------------------------
    -- Report missing dependencies
    -- -------------------------------------------------------------------------

    if #missing > 0 then
        vim.schedule(function()
            vim.notify(
                "Tree-sitter dependencies missing:\n\n"
                    .. "  • "
                    .. table.concat(missing, "\n  • ")
                    .. "\n\n"
                    .. "Parser installation or updates may fail.\n"
                    .. "Run :checkhealth nvim-treesitter for details.",
                vim.log.levels.WARN,
                {
                    title = "Tree-sitter",
                }
            )
        end)

        return false
    end

    return true
end

check_treesitter_dependencies()


-- -----------------------------------------------------------------------------
-- Highlighting
-- -----------------------------------------------------------------------------

-- Remember which missing parsers have already produced a notification during
-- this Neovim session.
--
-- Without this, opening several files of the same type could repeatedly show
-- the same warning.
local parser_warning_shown = {}


-- Enable Tree-sitter highlighting when a compatible parser is available.
--
-- If the parser is missing or cannot be loaded, the buffer remains usable and
-- Neovim falls back to its normal syntax highlighting.
vim.api.nvim_create_autocmd("FileType", {
    pattern = vim.tbl_keys(treesitter_languages),

    callback = function(args)
        local filetype = vim.bo[args.buf].filetype
        local language = treesitter_languages[filetype]

        if not language then
            return
        end

        -- Try to create the parser before enabling highlighting.
        --
        -- On Neovim 0.12+, get_parser() returns nil plus an error when the
        -- parser cannot be created, allowing us to handle the failure without
        -- aborting the FileType autocmd.
        local parser, err =
            vim.treesitter.get_parser(args.buf, language)

        if not parser then
            if not parser_warning_shown[language] then
                parser_warning_shown[language] = true

                vim.schedule(function()
                    vim.notify(
                        "Tree-sitter parser unavailable for "
                            .. filetype
                            .. ".\n\n"
                            .. tostring(err)
                            .. "\n\n"
                            .. "Install or reinstall it with:\n"
                            .. "  :TSInstall "
                            .. language
                            .. "\n\n"
                            .. "Then update parsers with:\n"
                            .. "  :TSUpdate",
                        vim.log.levels.WARN,
                        {
                            title = "Tree-sitter",
                        }
                    )
                end)
            end

            return
        end

        -- A compatible parser exists, so enable Tree-sitter highlighting for
        -- this buffer.
        vim.treesitter.start(args.buf, language)
    end,
})


-- =============================================================================
-- Language Server Protocol
-- =============================================================================

-- Configure mappings whenever an LSP server attaches to a buffer.
--
-- Making these mappings buffer-local means they only exist where an LSP
-- server is actually available.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = {
            buffer = args.buf,
        }


        -- ---------------------------------------------------------------------
        -- Navigation
        -- ---------------------------------------------------------------------

        -- Go to the definition of the symbol under the cursor.
        --
        --     gd    Go to definition
        vim.keymap.set(
            "n",
            "gd",
            vim.lsp.buf.definition,
            vim.tbl_extend("force", opts, {
                desc = "Go to definition",
            })
        )

        -- Find all references to the symbol under the cursor.
        --
        -- Results are shown using Neovim's location/quickfix interface.
        --
        --     gr    Find references
        vim.keymap.set(
            "n",
            "gr",
            vim.lsp.buf.references,
            vim.tbl_extend("force", opts, {
                desc = "Find references",
            })
        )


        -- ---------------------------------------------------------------------
        -- Information
        -- ---------------------------------------------------------------------

        -- Display documentation and type information for the symbol under the
        -- cursor.
        --
        --     K    Hover documentation
        vim.keymap.set(
            "n",
            "K",
            vim.lsp.buf.hover,
            vim.tbl_extend("force", opts, {
                desc = "Hover documentation",
            })
        )


        -- ---------------------------------------------------------------------
        -- Refactoring
        -- ---------------------------------------------------------------------

        -- Rename the symbol under the cursor throughout the project.
        --
        --     Space + r + n
        vim.keymap.set(
            "n",
            "<leader>rn",
            vim.lsp.buf.rename,
            vim.tbl_extend("force", opts, {
                desc = "Rename symbol",
            })
        )

        -- Show code actions available at the current cursor position.
        --
        -- Depending on the language server this may offer actions such as
        -- applying fixes, adding includes, or performing refactorings.
        --
        --     Space + c + a
        vim.keymap.set(
            { "n", "v" },
            "<leader>ca",
            vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, {
                desc = "Code action",
            })
        )
    end,
})
