" document_listener.vim

function! s:on_read()
    echo "File read: " . expand('%:p')
endfunction

augroup SuperMavenDocumentListener
    autocmd!
    autocmd BufReadPost * call s:on_read()
augroup END
