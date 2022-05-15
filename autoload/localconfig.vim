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

function s:has_valid_permissions(file, debug)
  if a:debug
    echom "permissions for " . a:file . " : " . getfperm(a:file)
  endif
  return getfperm(a:file) == "rw-------"
endfunction

function s:create_cache_directory(dir_name)
  let dirname = expand(a:dir_name)
  if !mkdir(dirname, 'p')
    throw "Couldn't create directory " . dirname . "'. Check your permissions"
  endif
  if !setfperm(dirname, 'rwx------')
    throw "Couldn't set permissions of '" . dirname . "'"
  endif
endfunction

function s:compute_sha256(file)
  let str = s:sys_call_throw('sha256sum ' . a:file, "failed to compute SHA256 sum for '" . a:file . "'")
  return get(split(l:str, ' '), 0, '')
endfunction

function s:create_cache_file(file, content)
  return s:sys_call("echo '" . a:content . "' > " . a:file) && s:sys_call('chmod 600 ' . a:file)
endfunction

function s:mangle_file_name(file)
  return substitute(expand(a:file), '\/\+', '%', 'g')
endfunction

function s:compute_signature(file_name, policy)
  if a:policy == 'sha256'
    return s:compute_sha256(a:file_name)
  elseif a:policy == 'filename'
    return ''
  else
    throw "Invalid policy '" . policy . "'. Cannot compute file signature"
  endif
endfunction

" This is a test documentation
function s:create_signature_file(options)
  let l:full_file_name = a:options.full_file_name
  let l:cache_dir = a:options.cache_directory
  let l:file = s:mangle_file_name(l:full_file_name)
  let l:cache_filename = l:cache_dir . '/' . l:file
  let l:policy = a:options.policy

  if l:policy == ''
    return
  else
    echom "creating file " . l:cache_filename
    call s:create_cache_directory(l:cache_dir)
    call s:create_cache_file(l:cache_filename, s:compute_signature(l:full_file_name, l:policy))
  endif
endfunction

function s:is_signature_valid(options)
  let l:policy = a:options.policy
  let l:debug = a:options.traces == 2

  if l:debug
    echom "checking signature with policy '" . l:policy . "'"
  endif

  if l:policy == ''
    return v:true
  endif

  let l:file_name = a:options.full_file_name
  let l:cache_filename = a:options.cache_directory . '/' . s:mangle_file_name(l:file_name)

  if l:debug
    echom "Signature file is '" . l:cache_filename . "', exists? " . filereadable(l:cache_filename)
  endif

  if ! (filereadable(l:cache_filename) && s:has_valid_permissions(l:cache_filename, l:debug))
    return v:false
  endif

  let l:expected_signature = get(readfile(l:cache_filename), 0, '')
  let l:actual_signature = s:compute_signature(l:file_name, l:policy)

  if l:debug
    echom "Signatures expected/actual: " . l:expected_signature . " == " . l:actual_signature
  endif

  return l:expected_signature == l:actual_signature
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

" Do everything that needs doing when save happens
function localconfig#TriggerSaveConfig()
  try
    let l:file = s:cached_options.full_file_name
    let l:signature_was_valid = s:cached_options.signature_was_valid

    if l:signature_was_valid || confirm("File signature was invalid, do you want to generate it now?", "&yes\n&No", 2) == 1
      call s:create_signature_file(s:cached_options)
      let s:cached_options.signature_was_valid = v:true
    endif

    if s:cached_options.auto_reload && (l:signature_was_valid || confirm("Do you want to reload local configuration? ", "&yes\n&No", 2) == 1)
      exec "source " . l:file
    endif
  catch
    echoerr v:exception
  endtry
endfunction

" Open the local config file. If the local configuration folder ('.vim')
" doesn't exist, create it
function localconfig#OpenLocalConfig(options)
  try
    let l:local_config_dir_name = a:options.directory
    let l:local_config_file_name = a:options.file

    let l:project_dir = localconfig#GetProjectRoot(l:local_config_dir_name) . '/'
    let l:config_dir = l:project_dir . l:local_config_dir_name
    let l:config_file = l:config_dir . '/' . l:local_config_file_name
    let a:options.full_file_name = l:config_file

    let s:cached_options = a:options

    if filereadable(l:config_dir)
      throw l:project_dir . ' exists and is not a directory'

    elseif l:local_config_dir_name != ''
      call mkdir(l:config_dir, 'p')

    endif

    let s:cached_options.signature_was_valid = !filereadable(l:config_file) || s:is_signature_valid(a:options)

    execute 'edit' . l:config_file
  catch
    echoerr v:exception
  endtry
endfunction

function localconfig#LoadConfigFile(options)
  try
    let l:config_directory = a:options.directory
    let l:config_file = a:options.file
    let l:policy = a:options.policy

    let l:local_config = localconfig#GetProjectRoot(l:config_directory) . '/' . l:config_directory . '/' . l:config_file
    let a:options.full_file_name = l:local_config

    let s:cached_options = a:options
    let s:cached_options.signature_was_valid = v:true

    if !filereadable(l:local_config)
      return
    endif

    if ! s:is_signature_valid(a:options)
      throw "Invalid signature for configuration file " . a:options.full_file_name . ". It will not be loaded. Check that the signature file has the correct permissions (600) and matches the content of the configuration"
    endif

    execute 'source ' . l:local_config
    if a:options.traces > 0
      echom 'Loaded local config from ' . l:local_config
    endif
  catch
    let s:cached_options.signature_was_valid = v:false
    echoerr v:exception
  endtry
endfunction
