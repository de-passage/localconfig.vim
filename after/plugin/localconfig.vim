let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

if &cp || exists("g:loaded_localconfig_plugin_after") && g:loaded_localconfig_plugin_after
  finish
endif
let g:loaded_localconfig_plugin_after = 1

" Plugin starts here

" Retrieve user config
if !exists("g:localconfig_file")
  let s:local_config_file = "config.vim"
else
  let s:local_config_file = g:localconfig_file
endif
if !exists("g:localconfig_directory")
  let s:local_config_directory = ".vim"
else
  let s:local_config_directory = g:localconfig_directory
endif
if exists('g:localconfig_autoreload')
  let s:auto_reload = g:localconfig_autoreload
else
  let s:auto_reload = 1
endif

" Acceptable values: 'none', 'filename', 'md5', 'sha1', 'sha256'
if exists('g:localconfig_whitelist_policy')
  let s:whitelist_policy = g:localconfig_whitelist_policy
else
  let s:whilelist_policy = 'sha256'
endif

if exists('g:localconfig_cache_directory')
  let s:cache_directory = g:localconfig_cache_directory
elseif has('nvim')
  let s:cache_directory = "~/.cache/nvim/localconfig"
else
  let s:cache_directory = "~/.cache/vim/localconfig"
end

if exists('g:localconfig_ask_before_load')
  let s:ask = g:localconfig_ask_before_load
else
  let s:ask = 0
end

call localconfig#LoadConfigFile(s:local_config_directory, s:local_config_file, s:whilelist_policy, s:ask)

" Register command
command -nargs=0 LocalConfig call localconfig#OpenLocalConfig(s:local_config_directory, s:local_config_file, s:auto_reload)

let &cpo = s:save_cpo
unlet s:save_cpo
