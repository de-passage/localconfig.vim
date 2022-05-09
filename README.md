# localconfig.vim
Tiny plugin loading a per-project configuration file

## Rationale

I found myself in a situation where I had to work on several different projects using the same technologies but using incompatible scripts and procedure to compile, run tests, and generally speaking work on the code.

I wrote a bit of vimscript to solve the problem, then realized that there's an `'exrc'` option that solves most of the same problem. This is a tad more complete so I'll keep it here and improve it when I can.

## Security advisory

This plugin is dangerous as it will load the file on each startup without asking. The configuration file is a vimscript file that is sourced at startup and can do **ANYTHING**. A devious attacker could say add/modify the configuration file on a shared directory/remote repository and have you run malicious code with the same privileges as your current user. 

## Features

+ Autoload of configuration file from any project subdirectory
+ Project root detection : `:call GetProjectRoot(".vim")`
+ Edit configuration with autoreload on save : `:LocalConfig` 

## Configuration

Default configuration is as follow:
```vim
" Name of the configuration file
let g:local_config_file = 'config.vim'

" Name of the configuration directory.
" Set it to an empty string to use the root itself rather than a subdirectory to store the configuration
" In this case, root detection is solely based on git and will fallback to the current directory if not found
let g:local_config_directory = '.vim'
```

## Roadmap 

PR welcome! 

Things I'd like to add:
+ Support for other VCSs. I only use git so feel free to chime in if you know how they work
+ SHA-based whitelist: allow the user to register a script's signature with the plugin and only source files matching the whitelist.  
