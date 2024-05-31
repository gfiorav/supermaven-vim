" init.vim

let s:binary = 'supermaven#binary_handler'
let s:completion_preview = 'supermaven#completion_preview'
let s:util = 'supermaven#util'
let s:listener = 'supermaven#document_listener'
let s:config = 'supermaven#config'

function init#setup(args) abort
    let config_settings = call(s:config . '#setup_config', [a:args])

    if get(config_settings, 'disable_inline_completion', 0)
        let g:completion_preview_disable_inline_completion = 1
    elseif !get(config_settings, 'disable_keymaps', 0)
        if has_key(config_settings.keymaps, 'accept_suggestion')
            let accept_suggestion_key = config_settings.keymaps.accept_suggestion
            call map([accept_suggestion_key], 'inoremap <silent> ' . v:val . ' <SID>on_accept_suggestion')
        endif

        if has_key(config_settings.keymaps, 'accept_word')
            let accept_word_key = config_settings.keymaps.accept_word
            call map([accept_word_key], 'inoremap <silent> ' . v:val . ' <SID>on_accept_suggestion_word')
        endif

        if has_key(config_settings.keymaps, 'clear_suggestion')
            let clear_suggestion_key = config_settings.keymaps.clear_suggestion
            call map([clear_suggestion_key], 'inoremap <silent> ' . v:val . ' <SID>on_dispose_inlay')
        endif
    endif

    call s:binary . '#start_binary', [get(config_settings, 'ignore_filetypes', [])]

    if has_key(config_settings, 'color') && has_key(config_settings.color, 'suggestion_color') && has_key(config_settings.color, 'cterm')
        augroup SupermavenColor
            autocmd!
            autocmd VimEnter,ColorScheme * call init#setup_highlight_group(config_settings.color.suggestion_color, config_settings.color.cterm)
        augroup END
    endif
endfunction

function init#setup_highlight_group(suggestion_color, cterm) abort
    call nvim_set_hl(0, 'SupermavenSuggestion', {'fg': a:suggestion_color, 'ctermfg': a:cterm})
    let g:completion_preview_suggestion_group = 'SupermavenSuggestion'
endfunction
