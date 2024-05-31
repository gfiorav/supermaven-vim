" binary_handler.vim

let s:binary_path = supermaven#binary_fetcher#fetch_binary()
let s:state_map = {}
let s:current_state_id = 0
let s:last_provide_time = 0
let s:buffer = 0
let s:cursor = []
let s:max_state_id_retention = 50
let s:ignore_filetypes = {}
let s:service_message_displayed = 0

function! supermaven#binary_handler#start_binary(ignore_filetypes) abort
    let s:ignore_filetypes = a:ignore_filetypes
    let stdin = jobstart([s:binary_path, 'stdio'], {'rpc': v:true})
    let stdout = jobstart([s:binary_path, 'stdio'], {'rpc': v:true})
    let stderr = jobstart([s:binary_path, 'stdio'], {'rpc': v:true})
    let s:last_text = ''
    let s:last_path = ''
    let s:last_context = {}
    let s:wants_polling = 0
    call jobstart([s:binary_path, 'stdio'], {
    \ 'on_exit': function('supermaven#binary_handler#on_exit'),
    \ 'on_stdout': function('supermaven#binary_handler#on_stdout'),
    \ 'on_stderr': function('supermaven#binary_handler#on_stderr'),
    \})
endfunction

function! supermaven#binary_handler#on_exit(job_id, data, event) abort
    echom "sm-agent exited with code " . a:data
endfunction

function! supermaven#binary_handler#on_stdout(job_id, data, event) abort
    call map(a:data, 'supermaven#binary_handler#process_line(v:val)')
endfunction

function! supermaven#binary_handler#on_stderr(job_id, data, event) abort
    echom "Error: " . join(a:data, "\n")
endfunction

function! supermaven#binary_handler#process_line(line) abort
    if stridx(a:line, 'SM-MESSAGE ') == 0
        let message = json_decode(strpart(a:line, 11))
        call supermaven#binary_handler#process_message(message)
    else
        echom "Unknown message: " . a:line
    endif
endfunction

function! supermaven#binary_handler#process_message(message) abort
    if a:message.kind == 'response'
        " Update state_id, etc.
    elseif a:message.kind == 'metadata'
        " Update metadata
    elseif a:message.kind == 'activation_request'
        let s:activate_url = a:message.activateUrl
        call timer_start(0, {-> supermaven#binary_handler#open_popup(s:activate_url)})
    elseif a:message.kind == 'activation_success'
        let s:activate_url = ''
        echom "Supermaven was activated successfully."
        call timer_start(0, 'supermaven#binary_handler#close_popup')
    elseif a:message.kind == 'service_tier'
        if !s:service_message_displayed
            echom "Supermaven " . a:message.display . " is running."
            let s:service_message_displayed = 1
        endif
        call timer_start(0, 'supermaven#binary_handler#close_popup')
    endif
endfunction

function! supermaven#binary_handler#open_popup(message) abort
    " Open popup window with message
endfunction

function! supermaven#binary_handler#close_popup() abort
    " Close popup window
endfunction

" User commands
command! SupermavenUseFree call supermaven#binary_handler#use_free_version()
command! SupermavenLogout call supermaven#binary_handler#logout()
command! SupermavenUsePro call supermaven#binary_handler#use_pro()

function! supermaven#binary_handler#use_free_version() abort
    " Send free version usage message
endfunction

function! supermaven#binary_handler#logout() abort
    let s:service_message_displayed = 0
    " Send logout message
endfunction

function! supermaven#binary_handler#use_pro() abort
    if !empty(s:activate_url)
        echom "Visit " . s:activate_url . " to set up Supermaven Pro"
        call supermaven#binary_handler#open_popup(s:activate_url)
    else
        echom "Could not find an activation URL."
    endif
endfunction
