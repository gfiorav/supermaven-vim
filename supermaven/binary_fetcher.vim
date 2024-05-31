" binary_fetcher.vim

function! supermaven#binary_fetcher#platform() abort
    if has('mac')
        return 'macosx'
    elseif has('unix')
        return 'linux'
    elseif has('win32')
        return 'windows'
    endif
    return ''
endfunction

function! supermaven#binary_fetcher#get_arch() abort
    if has('mac') && system('uname -m') =~ 'arm64\|aarch64'
        return 'aarch64'
    elseif system('uname -m') =~ 'x86_64'
        return 'x86_64'
    endif
    return ''
endfunction

function! supermaven#binary_fetcher#discover_binary_url() abort
    let platform = supermaven#binary_fetcher#platform()
    let arch = supermaven#binary_fetcher#get_arch()
    let url = 'https://supermaven.com/api/download-path?platform=' . platform . '&arch=' . arch . '&editor=neovim'

    let response = ''
    if platform ==# 'windows'
        let response = system(['powershell', '-Command', 'Invoke-WebRequest', '-Uri', url, '-UseBasicParsing', '|', 'Select-Object', '-ExpandProperty', 'Content'])
        let response = substitute(response, '\r\n', '', 'g')
    else
        let response = system('curl -s "' . url . '"')
    endif

    let json = json_decode(response)
    if json == v:null
        echoerr 'Error: Unable to find download URL for Supermaven binary'
        return v:null
    endif

    return json['downloadUrl']
endfunction

function! supermaven#binary_fetcher#local_binary_path() abort
    if supermaven#binary_fetcher#platform() ==# 'windows'
        return supermaven#binary_fetcher#local_binary_parent_path() . '/sm-agent.exe'
    else
        return supermaven#binary_fetcher#local_binary_parent_path() . '/sm-agent'
    endif
endfunction

function! supermaven#binary_fetcher#local_binary_parent_path() abort
    return $HOME . '/.supermaven/binary/v15/' . supermaven#binary_fetcher#platform() . '-' . supermaven#binary_fetcher#get_arch()
endfunction

function! supermaven#binary_fetcher#fetch_binary() abort
    let local_binary_path = supermaven#binary_fetcher#local_binary_path()
    if filereadable(local_binary_path)
        return local_binary_path
    else
        if !isdirectory(supermaven#binary_fetcher#local_binary_parent_path())
            call mkdir(supermaven#binary_fetcher#local_binary_parent_path(), 'p')
        endif
    endif

    let url = supermaven#binary_fetcher#discover_binary_url()
    if url == v:null
        return v:null
    endif

    echo 'Downloading Supermaven binary, please wait...'
    if supermaven#binary_fetcher#platform() ==# 'windows'
        let response = system(['powershell', '-Command', 'Invoke-WebRequest', '-Uri', url, '-OutFile', local_binary_path])
    else
        let response = system('curl -o ' . local_binary_path . ' ' . url)
    endif

    if v:shell_error != 0
        echoerr 'Error: sm-agent download failed'
        return v:null
    endif

    call system(['chmod', '755', local_binary_path])
    echo 'Downloaded binary sm-agent to ' . local_binary_path
    return local_binary_path
endfunction
