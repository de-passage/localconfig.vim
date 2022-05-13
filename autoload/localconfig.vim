" Get the project root based on the given directory and the git root
function localconfig#GetProjectRoot(local_config_dir_name)
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
function localconfig#OpenLocalConfig(options)
  let l:local_config_dir_name = a:options.directory
  let l:local_config_file_name = a:options.file

  let l:project_dir = GetProjectRoot(l:local_config_dir_name) . '/'
  let l:config_dir = l:project_dir . l:local_config_dir_name
  let l:config_file = l:config_dir . '/' . l:local_config_file_name

  if isdirectory(l:config_dir)
    execute 'edit' . l:config_file
  elseif filereadable(l:project_dir . l:local_config_file_name)
    echoerr l:project_dir . " exists and is not a directory"
    return

  elseif l:local_config_dir_name != ''
    call system('mkdir '. l:config_dir )
    if v:shell_error == 0
      execute 'edit' . l:config_file
    else
      echoerr "Unexpected error while creating " . l:local_config_dir_name . " folder. Check your permissions & content of the current directory."
      return
    endif
  endif

  if auto_reload == 1
    exec 'autocmd BufWritePost ' . l:config_file . ' source ' . l:config_file
  endif
endfunction

function localconfig#LoadConfigFile(options)
  let l:config_directory = a:options.directory
  let l:config_file = a:options.file
  let l:policy = a:options.policy

  let l:local_config = localconfig#GetProjectRoot(l:config_directory) . "/" . l:config_directory . "/" . l:config_file

  if !filereadable(l:local_config)
    return
  endif

  let l:load_file = 0
  if l:policy == 'none'
    let l:load_file = 1
  elseif l:policy == 'filename'
    let load_file = 1
  elseif l:policy == 'sha256'
    let load_file = 1
  endif

  if l:load_file == 1
    execute 'source ' . l:local_config
    echom "Loaded local config from " . l:local_config
  endif

endfunction
