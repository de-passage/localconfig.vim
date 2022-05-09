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

let s:local_config = GetProjectRoot(s:local_config_directory) . "/" . s:local_config_directory . "/" . s:local_config_file

if filereadable(s:local_config)
  execute 'source ' . s:local_config
  echom "Loaded local config from " . s:local_config
endif

command -nargs=0 LocalConfig call LocalConfig(<sid>local_config)
