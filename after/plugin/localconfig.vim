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
if !exists("g:localconfig_file")
  let s:options.file = 'config.vim'
else
  let s:options.file = g:localconfig_file
endif
if !exists('g:localconfig_directory')
  let s:options.directory = '.vim'
else
  let s:options.directory = g:localconfig_directory
endif
if exists('g:localconfig_autoreload')
  let s:options.auto_reload = g:localconfig_autoreload
else
  let s:options.auto_reload = 1
endif

" Acceptable values: 'none', 'filename', 'md5', 'sha1', 'sha256'
if exists('g:localconfig_whitelist_policy')
  let s:options.policy = g:localconfig_whitelist_policy
else
  let s:options.policy = 'sha256'
endif

if exists('g:localconfig_cache_directory')
  let s:options.cache_directory = g:localconfig_cache_directory
elseif has('nvim')
  let s:options.cache_directory = '~/.cache/nvim/localconfig'
else
  let s:options.cache_directory = '~/.cache/vim/localconfig'
end

if exists('g:localconfig_ask_before_load')
  let s:options.ask = g:localconfig_ask_before_load
else
  let s:options.ask = 0
end

call localconfig#LoadConfigFile(s:options)

" Register command
command -nargs=0 LocalConfig call localconfig#OpenLocalConfig(options)
command -nargs=0 LCCreateSignatureFile call localconfig#CreateSignatureFile(options)

let &cpo = s:save_cpo
unlet s:save_cpo
