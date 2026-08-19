" =============================================================================
" Terminal
" =============================================================================
"
" Provide a toggleable terminal using Vim's built-in terminal support.
"
" The terminal is toggled from .vimrc with:
"
"     <Leader>tt
"
" Behavior:
"
"   - The terminal opens in a horizontal window at the bottom.
"   - The terminal window is 12 lines high.
"   - Focus moves to the terminal when it is opened.
"   - Terminal-Job mode starts immediately so commands can be entered directly.
"   - Toggling the terminal closed hides its window without terminating the
"     shell, allowing the same terminal session to be restored later.
"   - Each tab page manages its terminal window independently.


" -----------------------------------------------------------------------------
" Terminal toggle
" -----------------------------------------------------------------------------

" Toggle the terminal window in the current tab page.
function! terminal#toggle()
    " Vim must have built-in terminal support.
    if !has('terminal')
        echohl WarningMsg
        echom 'Terminal support is not available in this Vim build'
        echohl None
        return
    endif

    " If the terminal is already visible in the current tab, hide its window
    " without deleting the buffer or terminating the running shell.
    for l:winnr in range(1, winnr('$'))
        let l:bufnr = winbufnr(l:winnr)

        if getbufvar(l:bufnr, '&buftype') ==# 'terminal'
            execute l:winnr . 'wincmd w'
            hide
            return
        endif
    endfor

    " Look for a previously created terminal buffer belonging to this tab.
    if exists('t:terminal_bufnr') && bufexists(t:terminal_bufnr)
        execute 'botright 12split'
        execute 'buffer ' . t:terminal_bufnr
    else
        " Create a new window at the bottom of the current tab.
        botright 12new

        " Start the terminal inside the window that was just created.
        "
        " ++curwin prevents :terminal from creating another split of its own.
        terminal ++curwin

        " Remember this terminal buffer for the current tab so that it can be
        " restored after its window has been hidden.
        let t:terminal_bufnr = bufnr('%')
    endif

    " Give the terminal a predictable height.
    resize 12

    " Display a simple label at the top of the terminal window.
    "
    " The winbar provides a clear visual boundary between the editor and terminal
    " without changing the global status-line appearance.
    if exists('+winbar')
        setlocal winbar=%=\ Terminal\ %=
    endif

    " Enter Terminal-Job mode so the shell is ready for input immediately.
    startinsert
endfunction