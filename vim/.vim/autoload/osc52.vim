" =============================================================================
" OSC 52 clipboard
" =============================================================================
"
" Autoload implementation for:
"
"     osc52#copy(text)
"
" Copy text from Vim to the clipboard of the local terminal.
"
" There are two possible paths:
"
"   1. Reachable tmux server
"
"      If Vim is running inside tmux AND the current process can actually
"      communicate with that tmux server, use:
"
"          tmux load-buffer -w -
"
"      tmux then forwards the copied text to the outer terminal clipboard.
"
"   2. Direct OSC 52
"
"      Otherwise, emit an OSC 52 escape sequence directly to /dev/tty.
"
"      This is particularly useful for setups such as:
"
"          terminal
"            -> tmux
"              -> docker
"                -> Vim
"
"      A Docker container may inherit $TMUX from the host environment without
"      having access to the host's tmux socket. In that case, merely checking
"      whether $TMUX exists is not sufficient.
"
"      Instead, we test whether `tmux` can actually communicate with the server.
"      If it cannot, Vim falls back to emitting OSC 52 directly. The escape
"      sequence travels through the container's PTY to the outer tmux pane,
"      where tmux can forward it to the terminal clipboard.
"
" Requirements:
"
"   - `base64` and `tr` for direct OSC 52 mode.
"   - `/dev/tty` must be available. For Docker this normally means using `-t`,
"     for example:
"
"         docker run -it ...
"
"   - For the tmux path, the `tmux` executable must be available and the tmux
"     server socket must be reachable.
"
"   - The outer terminal emulator must permit OSC 52 clipboard writes.
"
"   - When OSC 52 passes through tmux, tmux must be configured to allow
"     clipboard forwarding.
"
function! osc52#copy(text)

    " -------------------------------------------------------------------------
    " tmux
    " -------------------------------------------------------------------------
    "
    " $TMUX tells us that the environment originated inside tmux, but it does
    " NOT guarantee that this process can still reach the tmux server.
    "
    " This distinction matters inside containers. For example, Docker may
    " inherit $TMUX while the tmux socket itself remains outside the container.
    "
    " Therefore, first check for $TMUX and then verify that a simple tmux
    " command can actually communicate with the server.
    if exists('$TMUX') && !empty($TMUX)

        " Suppress output: we only care about the command's exit status.
        call system('tmux list-sessions >/dev/null 2>&1')

        if !v:shell_error
            " The tmux server is reachable.
            "
            " Load the selected text into a tmux buffer. `-w` tells tmux to
            " also send the buffer through its clipboard mechanism, ultimately
            " forwarding it to the external terminal.
            call system('tmux load-buffer -w -', a:text)

            if v:shell_error
                echohl ErrorMsg
                echomsg 'OSC 52: tmux clipboard copy failed'
                echohl None
            endif

            return
        endif

        " $TMUX exists, but the server is not reachable.
        "
        " This commonly happens inside Docker. Fall through to the direct
        " OSC 52 implementation below instead of treating it as an error.
    endif


    " -------------------------------------------------------------------------
    " Direct terminal OSC 52
    " -------------------------------------------------------------------------
    "
    " Encode the copied text as Base64.
    "
    " OSC 52 requires the clipboard payload to be Base64 encoded. `tr` removes
    " any newline characters that the local `base64` implementation may insert.
    let l:encoded = system('base64 | tr -d "\n"', a:text)

    if v:shell_error
        echohl ErrorMsg
        echomsg 'OSC 52: failed to encode clipboard contents'
        echohl None
        return
    endif


    " Construct an OSC 52 clipboard escape sequence:
    "
    "     ESC ] 52 ; c ; DATA BEL
    "
    " where:
    "
    "     ESC       starts the Operating System Command sequence
    "     52        selects clipboard manipulation
    "     c         selects the system clipboard
    "     DATA      is the Base64-encoded clipboard contents
    "     BEL       terminates the OSC sequence
    "
    " printf interprets:
    "
    "     \033      as ESC
    "     \a        as BEL
    "
    " Write the sequence directly to the controlling terminal rather than to
    " Vim's normal stdout. This allows it to travel through PTYs such as Docker
    " and tmux to the terminal emulator.
    let l:cmd = "printf '\\033]52;c;" . l:encoded . "\\a' > /dev/tty"
    call system(l:cmd)

    if v:shell_error
        echohl ErrorMsg
        echomsg 'OSC 52: failed to write to terminal'
        echohl None
    endif
endfunction