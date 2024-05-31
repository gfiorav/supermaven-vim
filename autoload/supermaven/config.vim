" config.vim

let s:default_config = {
\ 'option1': v:true,
\ 'option2': 'default_value',
\}

let s:config = {}

function! s:setup(user_config) abort
    let s:config = extend(copy(s:default_config), a:user_config)
endfunction

function! supermaven#config#setup(user_config) abort
    call s:setup(a:user_config)
endfunction
