function s:sys_call(cmd)
  call system(a:cmd)
  if v:shell_error == 0
    return v:true
  else
    return v:false
  endif
endfunction

function s:sys_call_throw(cmd, msg)
  let l:result = system(a:cmd)
  if v:shell_error != 0
    throw a:msg
  else
    return l:result
  endif
endfunction

function s:create_directory(dir_name)
  return s:sys_call('mkdir -p '. a:dir_name)
endfunction

function s:get_permissions(file)
  return s:sys_call_throw('stat -c %a ' . a:file, "failed to get permissions for '" . a:file . "'")
endfunction

function s:has_valid_permissions(file)
  return s:get_permissions(a:file) == "600"
endfunction

function s:create_cache_directory(dir_name)
  if s:create_directory(a:dir_name)
    return s:sys_call('chmod 700 ' . a:dir_name)
  endif
  return v:false
endfunction

function s:compute_sha256(file)
  let str = s:sys_call_throw('sha256sum ' . a:file, "failed to compute SHA256 sum for '" . a:file . "'")
  return get(split(l:str, ' '), 0, '')
endfunction

function s:create_cache_file(file, content)
  return s:sys_call("echo '" . a:content . "' > " . a:file) && s:sys_call('chmod 600 ' . a:file)
endfunction

function s:mangle_file_name(file)
  return substitute(a:file, '\/\+', '%%', 'g')
endfunction

function s:create_signature_file(options)
  let l:full_file_name = a:options.full_file_name
  let l:cache_dir = a:options.cache_directory
  let l:file = s:mangle_file_name(l:full_file_name)
  let l:cache_filename = l:cache_dir . '/' . l:file
  let l:method = a:options.policy

  if !s:create_cache_directory(cache_dir)
    throw "Couldn't create cache directory '" . l:cache_dir . "'"
  endif

  if l:method == ''
    return
  else
    if l:method == 'sha256'
      call s:create_cache_file(l:cache_filename, s:compute_sha256(l:full_file_name))
    elseif l:method == 'filename'
      call s:create_cache_file(l:cache_filename, '')
    endif
  endif
endfunction

" Get the project root based on the given directory and the git root
function localconfig#GetProjectRoot(local_config_dir_name)
  let l:current_dir = expand('%:p:h')
  let l:found_dir = finddir('.git/..', l:current_dir . ';')

  if l:found_dir == '' && a:local_config_dir_name != ''
    let l:found_dir = finddir(a:local_config_dir_name . '/..', current_dir . ';')
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

  let l:project_dir = localconfig#GetProjectRoot(l:local_config_dir_name) . '/'
  let l:config_dir = l:project_dir . l:local_config_dir_name
  let l:config_file = l:config_dir . '/' . l:local_config_file_name
  let a:options.full_file_name = l:config_file

  if isdirectory(l:config_dir)
    execute 'edit' . l:config_file
  elseif filereadable(l:project_dir . l:local_config_file_name)
    echoerr l:project_dir . ' exists and is not a directory'
    return

  elseif l:local_config_dir_name != ''
    if s:create_directory(l:config_dir)
      execute 'edit' . l:config_file
    else
      echoerr 'Unexpected error while creating ' . l:local_config_dir_name . ' folder. Check your permissions & content of the current directory.'
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

  let l:local_config = localconfig#GetProjectRoot(l:config_directory) . '/' . l:config_directory . '/' . l:config_file
  let a:options.full_file_name = l:local_config

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
    echom 'Loaded local config from ' . l:local_config
  endif

endfunction
