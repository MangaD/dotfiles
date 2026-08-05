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

" Enable enhanced command-line completion.
set wildmenu

" Complete the longest common match first, then show all available matches.
set wildmode=longest:full,full

" Allow switching away from modified buffers without saving them first.
set hidden

" Enable mouse support in all modes.
set mouse=a

" Use the system clipboard for normal yank, delete, change, and paste commands.
" This requires Vim to have clipboard support.
set clipboard=unnamedplus


" =============================================================================
" Mappings
" =============================================================================

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
