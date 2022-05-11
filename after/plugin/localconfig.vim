let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

if &cp || exists("g:loaded_localconfig_plugin_after") && g:loaded_localconfig_plugin_after
  finish
endif
let g:loaded_localconfig_plugin_after = 1

" Plugin starts here

" Retrieve user config
if !exists("g:local_config_file")
  let s:local_config_file = "config.vim"
else
  let s:local_config_file = g:local_config_file
endif
if !exists("g:local_config_directory")
  let s:local_config_directory = ".vim"
else
  let s:local_config_directory = g:local_config_directory
endif

" Find local configuration file
let s:local_config = GetProjectRoot(s:local_config_directory) . "/" . s:local_config_directory . "/" . s:local_config_file

" And load it
if filereadable(s:local_config)
  execute 'source ' . s:local_config
  echom "Loaded local config from " . s:local_config
endif

" Register command
command -nargs=0 LocalConfig call OpenLocalConfig(s:local_config_directory, s:local_config_file)

let &cpo = s:save_cpo
unlet s:save_cpo
