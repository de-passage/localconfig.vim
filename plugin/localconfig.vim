function GetProjectRoot(local_config_dir_name)
  let l:current_dir = expand("%:p:h")
  let l:found_dir = finddir(".git/..", l:current_dir . ";")

  if l:found_dir == '' && a:local_config_dir_name != ''
    let l:found_dir = finddir(a:local_config_dir_name . "/..", current_dir . ";")
  endif

  if  l:found_dir == ''
    return l:current_dir
  endif
  return l:found_dir
endfunction

" Open the local config file. If the local configuration folder ('.vim')
" doesn't exist, create it
function OpenLocalConfig(local_config_dir)
  let l:local_config_dir_name = a:local_config_dir
  let l:local_config_file_name = 'config.vim'

  let l:project_dir = GetProjectRoot(l:local_config_dir_name) . '/'
  let l:config_dir = l:project_dir . l:local_config_dir_name
  let l:config_file = l:config_dir . '/' . l:local_config_file_name

  if isdirectory(l:config_dir)
    execute 'edit' . l:config_file
  elseif filereadable(l:project_dir . l:local_config_file_name)
    echoerr ".vim exists and is not a directory"
    return
  elsif l:local_config_dir_name != ''
    call system('mkdir '. l:config_dir )
    if v:shell_error == 0
      execute 'edit' . l:config_file
    else
      echoerr "Unexpected error while creating " . l:local_config_dir_name . " folder. Check your permissions & content of the current directory."
      return
    endif
  endif

  exec 'autocmd BufWritePost ' . l:config_file . ' source ' . l:config_file
endfunction
