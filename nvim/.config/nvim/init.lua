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


    -- -----------------------------------------------------------------------------
    -- Telescope
    -- -----------------------------------------------------------------------------

    {
        "nvim-telescope/telescope.nvim",

        -- Telescope uses plenary.nvim for shared Lua utilities.
        -- nvim-web-devicons provides filetype icons when a Nerd Font is available.
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            local telescope = require("telescope")

            -- ---------------------------------------------------------------------
            -- External dependencies
            -- ---------------------------------------------------------------------

            -- Telescope can use external programs to find files and search text.
            --
            -- ripgrep:
            --     Provides `rg`, used by live_grep and grep_string.
            --
            -- fd-find:
            --     Provides fast file discovery.
            --
            --     Most systems use the executable name `fd`, but Debian and
            --     Raspberry Pi OS normally install it as `fdfind`.
            --
            -- Missing tools should produce a warning rather than preventing
            -- Neovim or Telescope from starting.

            local has_rg = vim.fn.executable("rg") == 1

            local fd_command = nil

            if vim.fn.executable("fd") == 1 then
                fd_command = "fd"
            elseif vim.fn.executable("fdfind") == 1 then
                fd_command = "fdfind"
            end


            -- Warn if ripgrep is unavailable.
            --
            -- File finding and buffer selection can still work, but project-wide
            -- text searching requires ripgrep.
            if not has_rg then
                vim.schedule(function()
                    vim.notify(
                        "Telescope: ripgrep (rg) is not installed. " ..
                        "Install it with: sudo apt install ripgrep",
                        vim.log.levels.WARN
                    )
                end)
            end


            -- Warn if neither fd nor fdfind is available.
            --
            -- Telescope can still find files using its fallback mechanisms,
            -- although fd generally provides faster file discovery.
            if not fd_command then
                vim.schedule(function()
                    vim.notify(
                        "Telescope: fd/fdfind is not installed. " ..
                        "Install it with: sudo apt install fd-find",
                        vim.log.levels.WARN
                    )
                end)
            end


            -- ---------------------------------------------------------------------
            -- Configuration
            -- ---------------------------------------------------------------------

            local opts = {
                defaults = {
                    -- Start pickers in Insert mode so searches can be typed
                    -- immediately.
                    initial_mode = "insert",
                },

                pickers = {},
            }


            -- Explicitly configure the file-finding executable when available.
            --
            -- This is particularly useful on Debian, where the executable is
            -- named `fdfind` rather than `fd`.
            --
            -- The arguments mean:
            --
            --     --type f        Only return files
            --     --hidden        Include hidden files
            --     --exclude .git  Do not search inside Git's internal directory
            --
            -- If fd/fdfind is unavailable, leave find_command unset and allow
            -- Telescope to choose its normal fallback.
            if fd_command then
                opts.pickers.find_files = {
                    find_command = {
                        fd_command,
                        "--type",
                        "f",
                        "--hidden",
                        "--exclude",
                        ".git",
                    },
                }
            end

            telescope.setup(opts)
        end,
    },


    -- -------------------------------------------------------------------------
    -- Git change indicators
    -- -------------------------------------------------------------------------

    {
        "lewis6991/gitsigns.nvim",

        config = function()
            local gitsigns = require("gitsigns")

            gitsigns.setup({
                -- Display Git changes in the sign column beside line numbers.
                --
                -- Added lines:    +
                -- Changed lines:  ~
                -- Deleted lines:  _
                signs = {
                    add          = { text = "+" },
                    change       = { text = "~" },
                    delete       = { text = "_" },
                    topdelete    = { text = "‾" },
                    changedelete = { text = "~" },
                    untracked    = { text = "┆" },
                },

                -- Display signs for untracked files as well.
                attach_to_untracked = true,

                -- Do not display inline Git blame information on every line.
                -- This can be enabled later if we decide it is useful.
                current_line_blame = false,

                -- Show changes even when the file has not yet been saved.
                update_debounce = 100,

                -- Configure buffer-local mappings only when Gitsigns attaches
                -- to a file tracked by Git.
                on_attach = function(bufnr)
                    local opts = { buffer = bufnr }

                    -- ---------------------------------------------------------
                    -- Hunk navigation
                    -- ---------------------------------------------------------

                    -- Jump to the next Git change.
                    --
                    --     ]h
                    vim.keymap.set("n", "]h", function()
                        gitsigns.nav_hunk("next")
                    end, vim.tbl_extend("force", opts, {
                        desc = "Next Git hunk",
                    }))

                    -- Jump to the previous Git change.
                    --
                    --     [h
                    vim.keymap.set("n", "[h", function()
                        gitsigns.nav_hunk("prev")
                    end, vim.tbl_extend("force", opts, {
                        desc = "Previous Git hunk",
                    }))

                    -- ---------------------------------------------------------
                    -- Inspecting changes
                    -- ---------------------------------------------------------

                    -- Show the original Git content for the current hunk in a
                    -- floating window, without modifying the file.
                    --
                    --     Space + g + p
                    vim.keymap.set("n", "<Leader>gp", gitsigns.preview_hunk,
                        vim.tbl_extend("force", opts, {
                            desc = "Preview Git hunk",
                        })
                    )

                    -- Show a side-by-side comparison of the current file against
                    -- the Git index.
                    --
                    --     Space + g + d
                    vim.keymap.set("n", "<Leader>gd", gitsigns.diffthis,
                        vim.tbl_extend("force", opts, {
                            desc = "Diff current file",
                        })
                    )

                    -- ---------------------------------------------------------
                    -- Staging and resetting changes
                    -- ---------------------------------------------------------

                    -- Stage the current hunk in Git's index.
                    --
                    -- This is equivalent to staging only the selected group of
                    -- changed lines, rather than staging the entire file.
                    --
                    --     Space + g + s
                    vim.keymap.set("n", "<Leader>gs", gitsigns.stage_hunk,
                        vim.tbl_extend("force", opts, {
                            desc = "Stage Git hunk",
                        })
                    )


                    -- Reset the current hunk in the working tree.
                    --
                    -- WARNING: This discards the unstaged changes in the hunk.
                    -- It does not remove changes already staged in Git's index.
                    --
                    --     Space + g + r
                    vim.keymap.set("n", "<Leader>gr", gitsigns.reset_hunk,
                        vim.tbl_extend("force", opts, {
                            desc = "Reset Git hunk",
                        })
                    )


                    -- Undo staging for the current hunk.
                    --
                    -- This removes the hunk from Git's index but preserves the
                    -- corresponding changes in the working tree.
                    --
                    --     Space + g + u
                    vim.keymap.set("n", "<Leader>gu", gitsigns.undo_stage_hunk,
                        vim.tbl_extend("force", opts, {
                            desc = "Unstage Git hunk",
                        })
                    )


                    -- ---------------------------------------------------------
                    -- Git blame
                    -- ---------------------------------------------------------

                    -- Display information about the commit that last changed
                    -- the line under the cursor.
                    --
                    -- This opens a floating window with blame information.
                    --
                    --     Space + g + b
                    vim.keymap.set("n", "<Leader>gb", gitsigns.blame_line,
                        vim.tbl_extend("force", opts, {
                            desc = "Show Git blame",
                        })
                    )


                    -- Toggle inline blame information for the current line.
                    --
                    -- The information is displayed as virtual text at the end
                    -- of the line, without modifying the file.
                    --
                    --     Space + g + B
                    vim.keymap.set("n", "<Leader>gB", gitsigns.toggle_current_line_blame,
                        vim.tbl_extend("force", opts, {
                            desc = "Toggle inline Git blame",
                        })
                    )

                end,
            })
        end,
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

                        -- Display errors, warnings, information, and hints reported
                        -- by the configured language servers (clangd, basedpyright,
                        -- and Ruff).
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

                        -- Display active LSP clients and LSP progress for the
                        -- current buffer.
                        --
                        -- The configured servers include clangd for C/C++ and
                        -- basedpyright and Ruff for Python.
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

                    -- Display diagnostics reported by Neovim's LSP clients.
                    --
                    -- This includes diagnostics from clangd for C/C++ and
                    -- basedpyright and Ruff for Python.
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



    -- -------------------------------------------------------------------------
    -- Sticky scroll (Tree-sitter context)
    -- -------------------------------------------------------------------------

    {
        "nvim-treesitter/nvim-treesitter-context",

        -- Tree-sitter context uses the installed language parsers to identify
        -- enclosing functions, classes, loops, and other syntax structures.
        --
        -- When scrolling through a long function or class, its declaration
        -- remains visible at the top of the editor window.
        --
        -- This is similar to VS Code's Sticky Scroll feature.
        --
        -- A Tree-sitter parser must be installed for the language.
        -- Languages without supported context queries may not show context.
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },

        config = function()
            local context = require("treesitter-context")

            context.setup({
                -- Enable sticky scroll when Neovim starts.
                enable = true,

                -- Show at most three lines of enclosing code context.
                --
                -- This prevents deeply nested code from occupying too much
                -- vertical space in the editor.
                max_lines = 3,

                -- Show context for the current cursor position.
                --
                -- "cursor" follows the structure containing the cursor.
                -- "topline" would instead follow the top visible line.
                mode = "cursor",

                -- Display line numbers beside the sticky context.
                line_numbers = true,

                -- Do not display sticky context in very small windows.
                --
                -- This is useful with the integrated terminal or other splits.
                min_window_height = 10,

                -- Only show context in the active editor window.
                multiwindow = false,
            })

            -- Toggle sticky scroll without restarting Neovim.
            --
            --     Space + u + s    Toggle sticky scroll
            vim.keymap.set("n", "<Leader>us", function()
                context.toggle()
            end, {
                desc = "Toggle sticky scroll",
            })
        end,
    },


    -- -------------------------------------------------------------------------
    -- Language Server Protocol
    -- -------------------------------------------------------------------------

    {
        "neovim/nvim-lspconfig",

        config = function()
            -- -----------------------------------------------------------------
            -- C and C++
            -- -----------------------------------------------------------------

            -- Enable clangd for C and C++.
            --
            -- clangd provides:
            --
            --   - diagnostics
            --   - completion
            --   - go to definition
            --   - references
            --   - hover documentation
            --   - symbol renaming
            --   - code actions
            --
            -- The clangd executable must be installed separately and available
            -- in PATH.
            vim.lsp.enable("clangd")


            -- -----------------------------------------------------------------
            -- Python
            -- -----------------------------------------------------------------

            -- Enable basedpyright for Python.
            --
            -- basedpyright provides:
            --
            --   - static type checking
            --   - diagnostics
            --   - completion
            --   - go to definition
            --   - references
            --   - hover documentation
            --   - symbol renaming
            --   - code actions
            --
            -- The basedpyright-langserver executable must be installed
            -- separately and available in PATH.
            vim.lsp.enable("basedpyright")


            -- -----------------------------------------------------------------
            -- Python formatting and linting: Ruff
            -- -----------------------------------------------------------------

            -- Ruff complements basedpyright rather than replacing it.
            --
            -- basedpyright:
            --     Type checking, completion, definitions, references, and
            --     general Python language intelligence.
            --
            -- Ruff:
            --     Code formatting, lint diagnostics, and import-related
            --     code actions.
            --
            -- Ruff provides a built-in language server through:
            --
            --     ruff server
            --
            -- Install the executable separately:
            --
            --     pipx install ruff
            --
            -- The `ruff` executable must be available in PATH.
            --
            -- nvim-lspconfig already supplies the default Ruff server
            -- configuration, so we only need to enable it.
            vim.lsp.enable("ruff")
        end,
    },

})



-- =============================================================================
-- Color scheme selection and toggleable transparency
-- =============================================================================

-- Available color schemes.
--
-- F7 and F8 cycle through this list.
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

-- Start with Kanagawa Dragon.
local colorscheme_index = 7

-- Transparency is disabled by default.
--
-- Transparency means that selected Neovim highlight groups do not draw
-- a background. Actual window opacity is controlled by the terminal emulator.
local transparency_enabled = false

-- Original highlight definitions for the currently selected theme.
--
-- These are captured when transparency is enabled and restored when it is
-- disabled. The snapshot is discarded whenever the theme changes.
local saved_highlights = {}

-- Incremented whenever a theme change invalidates a pending transparency
-- update. This prevents a scheduled update for an older theme from running
-- after a newer theme has been selected.
local theme_generation = 0

-- -------------------------------------------------------------------------
-- Select which highlight groups should become transparent
-- -------------------------------------------------------------------------

local transparent_editor_groups = {
    Normal = true,
    NormalNC = true,
    SignColumn = true,
    EndOfBuffer = true,
    LineNr = true,
    FoldColumn = true,

    -- Optional editor backgrounds.
    CursorLine = true,
    CursorLineNr = true,
    ColorColumn = true,
}

local function should_be_transparent(name)
    -- Main editor.
    if transparent_editor_groups[name] then
        return true
    end

    -- File explorer.
    if name:match("^NvimTree") then
        return true
    end

    -- Sticky scroll.
    if name:match("^TreesitterContext") then
        return true
    end

    -- Bufferline: tabs, separators, diagnostics, and indicators.
    if name:match("^BufferLine") then
        return true
    end

    -- Lualine: make most of the status line transparent, but preserve
    -- the colored backgrounds of the mode indicator and line numbers.
    --
    -- In the current Lualine layout:
    --   Section A displays the editor mode.
    --   Section Z displays the cursor's line/column information.
    --
    -- These sections use dark foreground text on distinctive backgrounds,
    -- so removing their backgrounds would make the text difficult to read.
    --
    -- Lualine highlight names typically follow this pattern:
    --   lualine_a_normal
    --   lualine_a_insert
    --   lualine_z_normal
    --   lualine_z_insert
    --
    -- Preserve all mode variants, not just Normal mode.
    if name:match("^lualine_") then
        -- Keep the mode indicator (section A) opaque.
        if name:match("^lualine_a_") then
            return false
        end

        -- Keep the line/column indicator (section Z) opaque.
        if name:match("^lualine_z_") then
            return false
        end

        -- Make all other Lualine sections transparent.
        return true
    end

    return false
end

-- -------------------------------------------------------------------------
-- Save and modify highlight definitions
-- -------------------------------------------------------------------------

-- Apply transparency to all currently defined matching highlight groups.
--
-- We save each group's original definition, including any highlight link.
-- For transparent rendering, we resolve linked groups into concrete colors
-- and remove only their background attributes.
--
-- Saving the original link is important: restoring a linked group as a
-- standalone definition could otherwise change how the theme behaves.
local function apply_transparency()
    if not transparency_enabled then
        return
    end

    -- Neovim returns a table of all defined highlight groups.
    local groups = vim.api.nvim_get_hl(0, {})

    for name, _ in pairs(groups) do
        if should_be_transparent(name) then
            -- Save the original definition only once per transparency cycle.
            if saved_highlights[name] == nil then
                saved_highlights[name] = vim.api.nvim_get_hl(0, {
                    name = name,
                    link = true,
                })
            end

            -- Resolve links to obtain the visible foreground and styles.
            local hl = vim.api.nvim_get_hl(0, {
                name = name,
                link = false,
            })

            -- Remove GUI and terminal background colors.
            hl.bg = nil
            hl.ctermbg = nil

            -- Do not inherit a reverse-video background.
            --
            -- Reverse-video highlights swap foreground and background;
            -- leaving reverse enabled can make a supposedly transparent
            -- element appear opaque.
            hl.reverse = nil
            hl.standout = nil

            vim.api.nvim_set_hl(0, name, hl)
        end
    end
end

-- Restore the highlight definitions saved for the active theme.
--
-- This does not reload the color scheme, so it avoids unnecessarily
-- replacing plugin-generated colors.
local function restore_highlights()
    for name, hl in pairs(saved_highlights) do
        vim.api.nvim_set_hl(0, name, hl)
    end

    saved_highlights = {}
end

-- -------------------------------------------------------------------------
-- Coordinate theme changes with transparency
-- -------------------------------------------------------------------------

-- Called when the color scheme changes.
--
-- This handles both our F7/F8 mappings and manual :colorscheme commands.
--
-- Schedule transparency until the current color-scheme operation finishes,
-- allowing plugins to process their ColorScheme callbacks first.
local function on_colorscheme_changed()
    theme_generation = theme_generation + 1
    local generation = theme_generation

    -- Highlights from the previous theme must never be restored over
    -- the newly selected theme.
    saved_highlights = {}

    if not transparency_enabled then
        return
    end

    vim.schedule(function()
        -- Ignore stale callbacks from earlier theme changes.
        if generation ~= theme_generation then
            return
        end

        apply_transparency()
    end)
end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = on_colorscheme_changed,
    desc = "Keep transparency consistent when changing color schemes",
})

-- Apply a color scheme while preserving the transparency preference.
--
-- If transparency is currently enabled, first restore the original
-- highlights for the old theme. Then load the new theme.
--
-- The ColorScheme autocmd discards the old snapshot and captures the
-- new theme's highlights after its callbacks have run.
local function apply_colorscheme()
    local colorscheme = colorschemes[colorscheme_index]

    if transparency_enabled then
        restore_highlights()
    end

    vim.cmd.colorscheme(colorscheme)

    vim.schedule(function()
        vim.notify("Color scheme: " .. colorscheme)
    end)
end

-- -------------------------------------------------------------------------
-- Toggle transparency
-- -------------------------------------------------------------------------

--     Space + u + t    Toggle transparency
--
-- ON:
--   Capture the current theme's highlights and clear their backgrounds.
--
-- OFF:
--   Restore the highlights saved for the current theme.
--
-- The selected color scheme does not change.
vim.keymap.set("n", "<Leader>ut", function()
    transparency_enabled = not transparency_enabled

    if transparency_enabled then
        apply_transparency()
    else
        -- Invalidate any scheduled transparency update.
        theme_generation = theme_generation + 1

        restore_highlights()
    end

    vim.notify(
        "Transparency: " .. (transparency_enabled and "on" or "off")
    )
end, {
    desc = "Toggle transparency",
})

-- -------------------------------------------------------------------------
-- Color scheme navigation
-- -------------------------------------------------------------------------

--     F7    Previous color scheme
vim.keymap.set("n", "<F7>", function()
    colorscheme_index =
        (colorscheme_index - 2) % #colorschemes + 1

    apply_colorscheme()
end, {
    desc = "Previous color scheme",
})

--     F8    Next color scheme
vim.keymap.set("n", "<F8>", function()
    colorscheme_index =
        colorscheme_index % #colorschemes + 1

    apply_colorscheme()
end, {
    desc = "Next color scheme",
})

-- -------------------------------------------------------------------------
-- Initial color scheme
-- -------------------------------------------------------------------------

-- Load the default theme only after all functions and autocmds above have
-- been defined.
--
-- Transparency starts disabled, so the theme loads with its normal colors.
apply_colorscheme()


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
    python = "python",
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

            -- Require tree-sitter-cli version 0.26.1 or newer.
            --
            -- Compare version components from left to right:
            --
            --     1.0.0   > 0.26.1
            --     0.27.0  > 0.26.1
            --     0.26.1  = 0.26.1
            --     0.26.0  < 0.26.1
            --     0.25.9  < 0.26.1
            local version_ok =
                major > 0
                or (major == 0 and minor > 26)
                or (major == 0 and minor == 26 and patch >= 1)

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
-- Diagnostics
-- =============================================================================

-- Show diagnostics for the current line in a floating window.
--
-- This is useful when a diagnostic message is too long to display completely
-- inline.
--
--     Space + d
vim.keymap.set("n", "<Leader>d", vim.diagnostic.open_float, {
    desc = "Show line diagnostics",
})


-- Move to the previous diagnostic in the current buffer and display its
-- message in a floating window.
--
--     [d
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, {
    desc = "Previous diagnostic",
})


-- Move to the next diagnostic in the current buffer and display its message
-- in a floating window.
--
--     ]d
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, {
    desc = "Next diagnostic",
})


-- =============================================================================
-- Telescope
-- =============================================================================

-- Telescope provides searchable pickers for files, project text, open buffers,
-- help documentation, and information supplied by language servers.
--
-- All mappings use Space + f as a common prefix:
--
--     Space + f + f    Find files
--     Space + f + g    Search project text
--     Space + f + w    Search word under cursor
--     Space + f + b    Find open buffers
--     Space + f + h    Search help documentation
--     Space + f + d    Search diagnostics
--     Space + f + s    Search document symbols
--     Space + f + r    Search LSP references

local builtin = require("telescope.builtin")


-- Find files in the current working directory.
--
-- Useful when the desired filename is known but its directory is not.
vim.keymap.set("n", "<Leader>ff", builtin.find_files, {
    desc = "Find files",
})


-- Search for text across files in the current working directory.
--
-- This uses ripgrep and updates the results as the query changes.
vim.keymap.set("n", "<Leader>fg", builtin.live_grep, {
    desc = "Search project text",
})


-- Search for the word currently under the cursor.
--
-- Useful for finding occurrences of a variable, function, or identifier
-- without typing its name manually.
vim.keymap.set("n", "<Leader>fw", builtin.grep_string, {
    desc = "Search word under cursor",
})


-- Switch between currently open buffers.
--
-- Complements Bufferline's Alt+Left and Alt+Right navigation when many
-- buffers are open.
vim.keymap.set("n", "<Leader>fb", builtin.buffers, {
    desc = "Find open buffers",
})


-- Search Neovim's help topics interactively.
vim.keymap.set("n", "<Leader>fh", builtin.help_tags, {
    desc = "Search help",
})


-- Search diagnostics from open buffers.
--
-- Complements Space+d, [d, and ]d, which are better for inspecting and
-- navigating individual diagnostics.
vim.keymap.set("n", "<Leader>fd", builtin.diagnostics, {
    desc = "Search diagnostics",
})


-- Search symbols reported by the language server for the current document.
--
-- For example, clangd can report C++ classes and functions, while
-- basedpyright can report Python classes and functions.
vim.keymap.set("n", "<Leader>fs", builtin.lsp_document_symbols, {
    desc = "Search document symbols",
})


-- Search references to the symbol under the cursor using the attached LSP.
--
-- Unlike plain text searching, references are resolved by the language server.
vim.keymap.set("n", "<Leader>fr", builtin.lsp_references, {
    desc = "Search LSP references",
})


-- =============================================================================
-- Formatting
-- =============================================================================

-- Format the current buffer using Neovim's built-in LSP client.
--
--     Space + f + m    Format current buffer
--
-- Neovim does not format the code itself. Instead, it sends a formatting
-- request to an attached language server that supports document formatting.
--
-- The formatter used therefore depends on the current filetype and the
-- language servers configured for that file.
--
-- -------------------------------------------------------------------------
-- C and C++
-- -------------------------------------------------------------------------
--
-- clangd provides document formatting using the clang-format engine.
--
-- clangd looks for a `.clang-format` file in the directory containing the
-- source file or one of its parent directories.
--
-- If a `.clang-format` file is found, its settings determine the formatting
-- style, including indentation, brace placement, spacing, and line length.
--
-- If no `.clang-format` file is found, clangd uses its fallback style,
-- which is LLVM by default.
--
-- A project can define its own style in a `.clang-format` file.
-- No separate clang-format executable is required for formatting through
-- clangd, because clangd includes the formatting engine.
--
-- -------------------------------------------------------------------------
-- Python
-- -------------------------------------------------------------------------
--
-- basedpyright provides Python language intelligence and type checking,
-- but it does not provide document formatting.
--
-- Ruff is therefore enabled as a second Python language server.
-- Ruff handles formatting and also provides lint diagnostics.
--
-- Ruff formatting can be configured per project using:
--
--     pyproject.toml
--     ruff.toml
--     .ruff.toml
--
-- Without a project configuration, Ruff uses its own default formatting
-- rules.
--
-- -------------------------------------------------------------------------
-- Other languages
-- -------------------------------------------------------------------------
--
-- This mapping is not restricted to C, C++, or Python.
--
-- It can format any buffer for which an attached language server supports
-- the LSP document-formatting capability.
--
-- For example, formatting Lua, Bash, or another language would require
-- configuring a suitable language server or formatter integration.
--
-- Tree-sitter provides syntax parsing and highlighting, not formatting.
-- Installing a Tree-sitter parser alone is therefore insufficient.
--
-- -------------------------------------------------------------------------
-- Behavior
-- -------------------------------------------------------------------------
--
-- Formatting is manual: it happens only when this shortcut is pressed.
-- Files are not automatically formatted when saved.
--
-- The request is synchronous, so Neovim waits for the formatter to finish.
-- A timeout prevents an unresponsive server from blocking indefinitely.
--
-- If no attached language server supports formatting, display a warning
-- rather than silently doing nothing.

vim.keymap.set("n", "<Leader>fm", function()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Find attached language servers that support whole-document formatting.
    local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        method = "textDocument/formatting",
    })

    if #clients == 0 then
        vim.notify(
            "No LSP formatter available for this buffer",
            vim.log.levels.WARN
        )
        return
    end

    -- Request formatting from an attached server.
    --
    -- At present:
    --
    --     C/C++   -> clangd
    --     Python  -> Ruff
    --
    -- For other languages, Neovim uses an attached server that supports
    -- document formatting.
    vim.lsp.buf.format({
        bufnr = bufnr,
        async = false,
        timeout_ms = 3000,
    })
end, {
    desc = "Format current buffer",
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

        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- Ruff and basedpyright both attach to Python files.
        --
        -- Prefer basedpyright for hover documentation (the K mapping),
        -- while keeping Ruff available for formatting, lint diagnostics,
        -- and code actions.
        --
        -- This does not disable Ruff's formatting or diagnostics.
        if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end


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


        -- ---------------------------------------------------------------------
        -- Completion
        -- ---------------------------------------------------------------------

        -- Enable Neovim's built-in LSP completion only for language servers
        -- that advertise completion support.
        --
        -- Examples:
        --
        --     C/C++    clangd
        --     Python   basedpyright
        --
        -- Ruff also attaches to Python buffers, but its primary responsibilities
        -- here are formatting, linting, and code actions.
        --
        -- Checking the capability avoids trying to enable completion for
        -- servers that do not provide it.
        --
        -- Completion uses Neovim's built-in Insert-mode completion menu.
        if client
            and client:supports_method("textDocument/completion", args.buf)
        then
            vim.lsp.completion.enable(
                true,
                args.data.client_id,
                args.buf,
                {
                    -- Automatically show suggestions while typing.
                    autotrigger = true,
                }
            )
        end

    end,
})
