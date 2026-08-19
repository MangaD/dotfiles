" =============================================================================
" Leader key
" =============================================================================

" Use Space as the leader key for custom mappings.
"
" The leader key acts as a prefix for related custom commands. For example:
"
"     Space + t + n    Open a new tab page
"     Space + t + c    Close the current tab page
"
" Define this before any mappings that use <Leader>.
let mapleader = " "


" =============================================================================
" Filetypes and syntax
" =============================================================================

" Enable filetype detection, filetype plugins, and filetype-specific indentation.
filetype plugin indent on

" Enable syntax highlighting.
syntax enable


" =============================================================================
" General editing
" =============================================================================

" Show absolute line numbers.
set number

" Use relative line numbers alongside the current absolute line number.
" Useful for motions such as 5j, 8k, and relative line-based commands.
"set relativenumber

" Highlight the line containing the cursor.
set cursorline

" Briefly highlight matching brackets.
set showmatch

" Show the cursor position in the ruler or status area.
set ruler

" Enable Vim's enhanced command-line completion menu.
"
" This affects completion for commands entered after `:`, such as file names,
" commands, options, buffers, and other context-dependent values.
"
" For example:
"
"     :edit src/<Tab>
"     :colorscheme <Tab>
"
" When multiple matches are available, Vim displays them as completion
" candidates rather than requiring their names to be entered manually.
set wildmenu

" Configure how command-line completion behaves when Tab is pressed.
"
" Completion proceeds in two stages:
"
"     longest:full
"         Complete the longest text shared by all matching candidates and
"         display the available matches.
"
"     full
"         Subsequent Tab presses cycle through the individual matches.
"
" For example, if a directory contains:
"
"     source.cpp
"     source.hpp
"     sounds.cpp
"
" entering:
"
"     :edit so<Tab>
"
" first expands the common portion as far as possible. Further Tab presses can
" then cycle through the available matching files.
set wildmode=longest:full,full

" Allow switching away from modified buffers without saving them first.
set hidden

" Prompt for confirmation when an operation would otherwise fail because of
" unsaved changes.
"
" For example, when attempting to quit a modified buffer, Vim can present a
" choice to save or discard the changes instead of simply reporting an error.
set confirm

" Automatically detect when a file has been modified outside Vim.
"
" When Vim determines that an unmodified buffer's file has changed on disk, it
" reloads the file rather than continuing to display stale contents.
"
" Vim performs these checks at certain safe points, such as when returning to
" the editor after executing an external command.
set autoread

" Make Backspace behave naturally throughout Insert mode.
"
"     indent    Allow Backspace over automatic indentation.
"     eol       Allow Backspace to join the current line with the previous one.
"     start     Allow Backspace past the position where Insert mode started.
"
" Modern Vim installations commonly behave this way already, but setting it
" explicitly makes the intended behavior portable and predictable.
set backspace=indent,eol,start

" Enable mouse support in all modes.
set mouse=a

" Use the `+` register as Vim's default register for yank, delete, change, and
" paste operations, integrating them with the system clipboard when Vim has
" clipboard support.
"
" This is separate from the OSC 52 mapping below. Native clipboard integration
" is used when available, while <Leader>y provides an explicit OSC 52 path for
" environments such as remote sessions, tmux, and containers.
set clipboard=unnamedplus


" -----------------------------------------------------------------------------
" OSC 52 clipboard
" -----------------------------------------------------------------------------
"
" Copy the current visual selection to the local terminal clipboard:
"
"     <Leader>y
"
" The implementation lives in:
"
"     ~/.vim/autoload/osc52.vim
"
" Calling osc52#copy() causes Vim to load that autoload file automatically the
" first time the function is used.
"
" Steps:
"
"   1. `y` yanks the visual selection into Vim's unnamed register (`"`).
"   2. osc52#copy() sends the contents of that register to the local clipboard.
"   3. `gv` restores the previous visual selection.
"
" The selection therefore remains highlighted after the copy operation.
vnoremap <Leader>y y:call osc52#copy(@")<CR>gv


" =============================================================================
" Tab pages
" =============================================================================

" Always show Vim's tab line at the top of the editor.
"
" Values:
"
"     0    Never show the tab line
"     1    Show it only when more than one tab page exists
"     2    Always show it
"
" Tab pages are technically containers for one or more Vim windows rather than
" individual buffers. In this configuration they can also be used as a simple,
" visible way to keep several files available across the top of the editor.
set showtabline=2


" -----------------------------------------------------------------------------
" Command-line files
" -----------------------------------------------------------------------------

" When Vim starts with multiple file arguments, display each file in its own
" tab page.
"
" This makes:
"
"     vim file1.cpp file2.cpp file3.hpp
"
" behave like:
"
"     vim -p file1.cpp file2.cpp file3.hpp
"
" With zero or one file argument, Vim's normal startup behavior is unchanged.
"
" Note that this applies to every argument in the argument list. For example,
" `vim *.cpp` will create one tab page for every matching C++ file.
autocmd VimEnter * if argc() > 1 | tab all | endif


" =============================================================================
" Mappings
" =============================================================================

" -----------------------------------------------------------------------------
" Saving
" -----------------------------------------------------------------------------

" Save the current buffer with Ctrl+s.
"
" The mapping works in Normal, Insert, and Visual modes:
"
"     Ctrl+s    Write the current buffer
"
" In Insert mode, the buffer is written without permanently leaving Insert mode.
" In Visual mode, the current selection remains active after saving.
"
" Note:
" Some terminals use Ctrl+s for XON/XOFF software flow control. If Ctrl+s
" freezes terminal output instead of reaching Vim, check:
"
"     stty -a
"
" If `ixon` is enabled, it can be disabled for the current terminal with:
"
"     stty -ixon
"
" Ctrl+q traditionally resumes output when XON/XOFF flow control is enabled.

" Normal mode: write the current buffer.
nnoremap <C-s> :write<CR>

" Insert mode: write without permanently leaving Insert mode.
inoremap <C-s> <C-o>:write<CR>

" Visual mode: write and restore the current selection.
vnoremap <C-s> :write<CR>gv


" -----------------------------------------------------------------------------
" Move lines
" -----------------------------------------------------------------------------

" Move the current line down or up.
"
" Two equivalent sets of shortcuts are provided:
"
"     Alt+j       Move down
"     Alt+k       Move up
"
"     Alt+Down    Move down
"     Alt+Up      Move up
"
" The Vim-style j/k mappings are convenient when keeping your hands on the
" normal movement keys, while the arrow-key mappings provide a more intuitive
" alternative.
"
" :move .+1
"     Moves the current line below the following line.
"
" :move .-2
"     Moves the current line above the preceding line.
"
" == reindents the moved line according to the indentation rules for the
" current file.
nnoremap <A-j>    :move .+1<CR>==
nnoremap <A-k>    :move .-2<CR>==
nnoremap <A-Down> :move .+1<CR>==
nnoremap <A-Up>   :move .-2<CR>==


" Move a visually selected block of lines down or up.
"
" The same shortcuts used in Normal mode work while lines are selected:
"
"     Alt+j       Move selection down
"     Alt+k       Move selection up
"
"     Alt+Down    Move selection down
"     Alt+Up      Move selection up
"
" '> and '< refer to the last and first lines of the visual selection.
"
" After moving the lines:
"
"     gv    restores the visual selection
"     =     reindents the selected lines
"     gv    restores the selection again
"
" Keeping the lines selected makes it possible to press the shortcut repeatedly
" to continue moving the entire block.
vnoremap <A-j>    :move '>+1<CR>gv=gv
vnoremap <A-k>    :move '<-2<CR>gv=gv
vnoremap <A-Down> :move '>+1<CR>gv=gv
vnoremap <A-Up>   :move '<-2<CR>gv=gv


" -----------------------------------------------------------------------------
" Tab navigation
" -----------------------------------------------------------------------------

" Vim already provides the following native tab-page mappings:
"
"     gt    Move to the next tab page
"     gT    Move to the previous tab page
"
" Keep those native mappings and also provide familiar arrow-key alternatives:
"
"     Alt+Left     Previous tab page
"     Alt+Right    Next tab page
"
" Some terminal emulators may intercept Alt+Left or Alt+Right before they reach
" Vim. The native gt and gT mappings remain available in that case.
nnoremap <A-Left>  :tabprevious<CR>
nnoremap <A-Right> :tabnext<CR>


" -----------------------------------------------------------------------------
" Creating and closing tabs
" -----------------------------------------------------------------------------

" Open a new empty tab page.
"
"     Space + t + n
nnoremap <Leader>tn :tabnew<CR>

" Close the current tab page.
"
"     Space + t + c
"
" Vim will refuse to discard unsaved changes unless explicitly forced.
nnoremap <Leader>tc :tabclose<CR>


" -----------------------------------------------------------------------------
" Moving tabs
" -----------------------------------------------------------------------------

" Move the current tab page one position to the left.
"
"     Space + t + h
nnoremap <Leader>th :-tabmove<CR>

" Move the current tab page one position to the right.
"
"     Space + t + l
nnoremap <Leader>tl :+tabmove<CR>


" =============================================================================
" Searching
" =============================================================================

" Ignore case when searching.
set ignorecase

" Make searches case-sensitive when the pattern contains uppercase characters.
set smartcase

" Show matches while the search pattern is being typed.
set incsearch

" Highlight all matches of the current search pattern.
set hlsearch


" =============================================================================
" Tabs and indentation
" =============================================================================

" Display tab characters as four columns wide.
set tabstop=4

" Use four columns for indentation commands such as >> and <<.
set shiftwidth=4

" Treat Tab and Backspace as four columns while editing.
set softtabstop=4

" Insert actual tab characters instead of spaces.
set noexpandtab

" Preserve indentation from the previous line.
set autoindent

" Historical setting:
" smartindent is an older general-purpose indentation engine.
" Filetype-specific indentation from `filetype plugin indent on` is preferred.
"set smartindent


" =============================================================================
" Whitespace
" =============================================================================

" Display otherwise invisible whitespace characters.
set list

" Configure how invisible characters are displayed.
"
" lead      Leading spaces
" tab       Tab characters
" trail     Trailing spaces
" extends   Text continues beyond the right edge
" precedes  Text continues beyond the left edge
set listchars=lead:·,tab:→\ ,trail:·,extends:>,precedes:<


" =============================================================================
" Display and scrolling
" =============================================================================

" Do not visually wrap long lines.
set nowrap

" Keep five lines visible above and below the cursor when possible.
set scrolloff=5

" Keep five columns visible to the left and right when scrolling horizontally.
" This is especially useful because line wrapping is disabled.
set sidescrolloff=5

" Show a vertical guide at column 85.
set colorcolumn=85

" Enable 24-bit terminal colors when supported by this Vim build.
if has("termguicolors")
    set termguicolors
endif


" =============================================================================
" Colorscheme
" =============================================================================

" Use a dark background.
"
" Colorschemes can use this setting to select colors intended for dark
" terminals.
set background=dark

" Use Vim's built-in Koehler colorscheme when available.
"
" Koehler provides a modern dark appearance without requiring an external
" plugin, keeping this configuration portable between machines.
"
" `silent!` prevents Vim from failing during startup on installations that do
" not provide the colorscheme.
silent! colorscheme koehler


" -----------------------------------------------------------------------------
" Transparent background
" -----------------------------------------------------------------------------

" Make the initially loaded colorscheme use the terminal's background.
"
" Vim itself does not create transparency. The terminal emulator must have
" transparency enabled separately. Setting these background colors to NONE
" prevents Vim from painting an opaque background in the corresponding areas,
" allowing the terminal background to show through.
"
" These settings are intentionally applied only once, after the colorscheme
" selected above has been loaded. They are NOT reapplied when another
" colorscheme is selected with F7 or F8. This allows colorscheme cycling to
" display each theme exactly as it defines itself, including its background
" colors.
highlight Normal       ctermbg=NONE guibg=NONE
silent! highlight NormalNC     ctermbg=NONE guibg=NONE
highlight SignColumn   ctermbg=NONE guibg=NONE
highlight LineNr       ctermbg=NONE guibg=NONE
highlight CursorLineNr ctermbg=NONE guibg=NONE
highlight CursorLine   ctermbg=NONE guibg=NONE
silent! highlight EndOfBuffer  ctermbg=NONE guibg=NONE


" -----------------------------------------------------------------------------
" Colorscheme notification
" -----------------------------------------------------------------------------

" Display the currently selected colorscheme after Vim has completed any
" redraws caused by applying it.
"
" `echomsg` also stores the message in :messages, so the selected theme can
" still be checked later even if another message eventually replaces it.
function! s:ShowColorscheme(scheme, timer)
    redraw

    echohl ModeMsg
    echomsg 'Colorscheme: ' . a:scheme
    echohl None
endfunction


" -----------------------------------------------------------------------------
" Colorscheme selector
" -----------------------------------------------------------------------------

" Return a sorted list of all colorschemes available in Vim's runtime path.
"
" `globpath()` searches every colors/ directory in 'runtimepath'.
" The resulting file paths are reduced to their filename without the .vim
" extension and duplicates are removed.
function! s:GetColorschemes()
    let l:files = globpath(&runtimepath, 'colors/*.vim', 0, 1)
    let l:schemes = map(l:files, 'fnamemodify(v:val, ":t:r")')

    return uniq(sort(l:schemes))
endfunction


" Switch to the next or previous available colorscheme.
"
" Direction:
"
"      1    Next colorscheme
"     -1    Previous colorscheme
"
" The list wraps around in both directions.
function! s:CycleColorscheme(direction)
    let l:schemes = s:GetColorschemes()

    if empty(l:schemes)
        echohl WarningMsg
        echom 'No colorschemes found'
        echohl None
        return
    endif

    " Determine the currently active colorscheme.
    let l:current = get(g:, 'colors_name', '')

    " Find it in the available colorscheme list.
    let l:index = index(l:schemes, l:current)

    " If the current colorscheme is unknown, start at the beginning.
    if l:index == -1
        let l:index = 0
    else
        " Move forwards or backwards and wrap around the list.
        let l:index = (l:index + a:direction + len(l:schemes))
                    \ % len(l:schemes)
    endif

    let l:scheme = l:schemes[l:index]

    " Apply the selected colorscheme.
    execute 'colorscheme ' . fnameescape(l:scheme)

    " Applying a colorscheme can trigger redraws or messages that immediately
    " overwrite normal `echo` output.
    "
    " Schedule our notification after the colorscheme command and the key
    " mapping have finished processing.
    if has('timers')
        call timer_start(
                    \ 50,
                    \ function('<SID>ShowColorscheme', [l:scheme])
                    \ )
    else
        " Fall back to an immediate message on Vim builds without timer support.
        redraw
        echohl ModeMsg
        echomsg 'Colorscheme: ' . l:scheme
        echohl None
    endif
endfunction


" Cycle through the available colorschemes.
"
"     F7    Previous colorscheme
"     F8    Next colorscheme
nnoremap <F7> :call <SID>CycleColorscheme(-1)<CR>
nnoremap <F8> :call <SID>CycleColorscheme(1)<CR>


" =============================================================================
" Highlighting
" =============================================================================

" Use subdued colors for ordinary line numbers.
highlight LineNr ctermfg=240 guifg=#5c6370

" Give the current line number a brighter color and bold emphasis.
highlight CursorLineNr ctermfg=179 cterm=bold guifg=#e5c07b gui=bold

" Use a subdued color for visible whitespace characters.
highlight SpecialKey ctermfg=240 guifg=#5c6370

" Historical setting:
" NonText also controls characters such as end-of-buffer markers.
" It is left disabled to avoid changing unrelated interface elements.
"highlight NonText ctermfg=240 guifg=#5c6370


" =============================================================================
" Persistent undo
" =============================================================================

" Keep undo history across Vim sessions when supported.
"
" Vim chooses its configured undo directory automatically. An explicit
" `undodir` can be added later if undo files should be stored in a dedicated
" location such as ~/.vim/undo/.
if has("persistent_undo")
    set undofile
endif


" =============================================================================
" Completion
" =============================================================================

" Show the completion menu even when only one match is available.
"
" noinsert prevents Vim from inserting a match automatically.
" noselect prevents Vim from selecting a match automatically.
set completeopt=menuone,noinsert,noselect


" =============================================================================
" Language-specific settings
" =============================================================================

" Use Vim's built-in C indentation rules for C and C++ files.
autocmd FileType c,cpp setlocal cindent


" =============================================================================
" Machine-specific configuration
" =============================================================================

" Load optional Vim settings that should not be stored in the shared dotfiles
" repository.
"
" ~/.vimrc.local can contain machine-specific paths, terminal-specific
" behavior, private settings, experimental mappings, or other configuration
" that should apply only to the current machine.
"
" Settings in this file are loaded last, so they can intentionally override
" values defined earlier in the main .vimrc.
if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif
