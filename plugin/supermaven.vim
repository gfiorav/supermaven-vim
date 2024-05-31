" plugin/supermaven.vim

runtime autoload/supermaven/util.vim
runtime autoload/supermaven/config.vim
runtime supermaven/binary_fetcher.vim
runtime supermaven/binary_handler.vim
runtime supermaven/completion_preview.vim
runtime supermaven/document_listener.vim
runtime supermaven/textual.vim
runtime supermaven/init.vim

" Call setup function with your desired configuration
call supermaven#config#setup({})
