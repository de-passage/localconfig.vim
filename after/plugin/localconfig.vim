let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

if &cp || exists('g:loaded_localconfig_plugin_after') && g:loaded_localconfig_plugin_after
  finish
endif

let g:loaded_localconfig_plugin_after = 1

" Plugin starts here
let s:options = {}

" Retrieve user config
if !exists("g:localconfig_file") || trim(g:localconfig_file) == ''
  let s:options.file = 'config.vim'

else
  let s:options.file = trim(g:localconfig_file)
endif
if !exists('g:localconfig_directory')
  let s:options.directory = '.vim'
else
  let s:options.directory = trim(g:localconfig_directory)
endif
if exists('g:localconfig_autoreload')
  let s:options.auto_reload = g:localconfig_autoreload
else
  let s:options.auto_reload = 1
endif

if exists('g:localconfig_whitelist_policy') && index(["", "sha256", "filename"], g:localconfig_whitelist_policy) >= 0
  let s:options.policy = g:localconfig_whitelist_policy
else
  let s:options.policy = 'sha256'
endif

if exists('g:localconfig_cache_directory')
  let s:options.cache_directory = expand(g:localconfig_cache_directory)
elseif has('nvim')
  let s:options.cache_directory = expand('~/.config/nvim/localconfig')
else
  let s:options.cache_directory = expand('~/.config/vim/localconfig')
end

if exists('g:localconfig_ask_before_load')
  let s:options.ask = g:localconfig_ask_before_load
else
  let s:options.ask = 0
end

if exists('g:localconfig_traces')
  let s:options.traces = index(['silent', 'info', 'debug'], g:localconfig_traces)
  if s:options.traces < 0
    let s:options.traces = 0
  endif
else
  let s:options.traces = 1
endif

try
  call localconfig#LoadConfigFile(s:options)
catch
  echoerr v:exception
finally

  " Register command
  command -nargs=0 LocalConfig call localconfig#OpenLocalConfig(s:options)
  augroup LocalConfigTriggerSaveConfigAugroup
    autocmd!
    execute 'autocmd BufWritePost ' . s:options.full_file_name . ' call localconfig#TriggerSaveConfig()'
  augroup END

  let &cpo = s:save_cpo
  unlet s:save_cpo
endtry
