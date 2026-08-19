" =============================================================================
" File explorer
" =============================================================================
"
" Provide a temporary sidebar-style file explorer using Vim's built-in netrw
" plugin.
"
" The explorer is toggled from .vimrc with:
"
"     <Leader>e
"
" Behavior:
"
"   - The explorer opens as a vertical sidebar on the far left.
"   - The explorer is 30 columns wide.
"   - Focus returns to the editor immediately after the explorer is opened.
"   - Pressing Enter on a directory continues browsing inside the explorer.
"   - Pressing Enter on a file opens that file in a new tab page.
"   - After a file has been opened, the originating explorer window closes.
"   - Each tab page can therefore summon its own temporary explorer with
"     <Leader>e when needed.


" -----------------------------------------------------------------------------
" Netrw configuration
" -----------------------------------------------------------------------------

" Hide netrw's informational banner to keep the explorer compact.
let g:netrw_banner = 0

" Display directories using netrw's tree-style view.
let g:netrw_liststyle = 3

" Prefer the left side when netrw creates a vertical split.
let g:netrw_altv = 0

" Open files selected with Enter in a new tab page.
"
" Directories continue to be browsed inside the existing netrw window.
let g:netrw_browse_split = 3


" -----------------------------------------------------------------------------
" Netrw mappings
" -----------------------------------------------------------------------------

" Replace netrw's normal Enter mapping with a small wrapper.
"
" The wrapper delegates the actual selection to netrw, preserving its normal
" handling of directories, files, special entries, tree listings, and escaped
" filenames. It only adds one behavior: if netrw opens a new tab page, the
" explorer window from which the file was selected is closed afterward.
"
" g:Netrw_UserMaps is netrw's supported mechanism for installing custom
" buffer-local mappings.
let g:Netrw_UserMaps = [
            \ ['<CR>', 'explorer#open'],
            \ ]


" -----------------------------------------------------------------------------
" Explorer toggle
" -----------------------------------------------------------------------------

" Toggle the netrw file explorer in the current tab page.
"
" If an explorer is already visible in this tab, close it.
"
" Otherwise:
"
"   1. Remember the currently focused editor window.
"   2. Open netrw in a vertical split.
"   3. Move the explorer to the far left.
"   4. Resize it to 30 columns.
"   5. Return focus to the original editor window.
"
" Explorers belonging to other tab pages are deliberately ignored.
function! explorer#toggle()
    " Search only the windows in the current tab page for an existing netrw
    " explorer.
    for l:winnr in range(1, winnr('$'))
        if getbufvar(winbufnr(l:winnr), '&filetype') ==# 'netrw'
            execute l:winnr . 'wincmd w'
            close
            return
        endif
    endfor

    " Remember the editor window that currently has focus.
    let l:editor_window = win_getid()

    " Open netrw in a vertical split.
    silent Vexplore

    " Keep the explorer on the far left and give it a predictable width.
    wincmd H
    vertical resize 30

    " Return focus to the window from which the explorer was opened.
    call win_gotoid(l:editor_window)
endfunction


" -----------------------------------------------------------------------------
" Opening files
" -----------------------------------------------------------------------------

" Handle Enter inside a netrw explorer.
"
" Netrw itself performs the selection. With g:netrw_browse_split set to 3,
" selecting a normal file creates a new tab page, while selecting a directory
" continues browsing in the existing explorer.
"
" The tab page before and after the netrw operation is compared to distinguish
" those two cases without attempting to parse netrw's displayed filenames.
function! explorer#open(islocal)
    " Remember the explorer window and tab from which the selection originated.
    let l:explorer_window = win_getid()
    let l:source_tab = tabpagenr()

    " Delegate the actual selection to netrw's normal Enter handler.
    "
    " feedkeys() with the 'm' flag allows the <Plug> mapping to be expanded.
    " The 'x' flag processes the generated input immediately so that we can
    " inspect the resulting tab and window before this function returns.
    call feedkeys("\<Plug>NetrwLocalBrowseCheck", 'mx')

    " If the current tab did not change, netrw handled something such as a
    " directory internally. Leave the explorer open.
    if tabpagenr() == l:source_tab
        return ''
    endif

    " A new tab was created, which means a file was opened. Remember its window
    " so that focus can be restored after closing the old explorer.
    let l:file_window = win_getid()

    " Return to the originating explorer window and close it.
    "
    " win_gotoid() can locate the window even though it belongs to the previous
    " tab page.
    if win_gotoid(l:explorer_window)
        close
    endif

    " Return focus to the newly opened file.
    call win_gotoid(l:file_window)

    return ''
endfunction