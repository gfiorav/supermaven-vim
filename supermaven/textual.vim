" textual.vim

function! s:show_textual_info() abort
    let lines = [
    \ 'Supermaven Plugin for Vim',
    \ 'Version: 0.0.1',
    \ 'Author: Guido Fioravantti'
    \]

    for line in lines
        echo line
    endfor
endfunction

command! SupermavenInfo call s:show_textual_info()
