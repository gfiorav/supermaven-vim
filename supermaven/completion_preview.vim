" completion_preview.vim

function! s:show_preview() abort
    if exists('v:completed_item') && !empty(v:completed_item)
        if has_key(v:completed_item, 'documentation') && !empty(v:completed_item.documentation)
            echo v:completed_item.documentation
        endif
    endif
endfunction

augroup SuperMavenCompletionPreview
    autocmd!
    autocmd CompleteDone * call <SID>show_preview()
augroup END
