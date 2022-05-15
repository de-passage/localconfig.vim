# localconfig.vim
Small plugin loading a per-project configuration file

## Rationale

I found myself in a situation where I had to work on several different projects using the same technologies but using incompatible scripts and procedure to compile, run tests, and generally speaking work on the code.

I wrote a bit of vimscript to solve the problem, then realized that there's an `'exrc'` option that solves most of the same problem. This is a tad more complete so I'll keep it here and improve it when I can. There are other plugins doing the same thing, but as far as I know, all of them work with whitelists based on file name only, which isn't as secure as it could be (also I started developping this before checking them out).

## Features

+ Autoload of configuration file from any project subdirectory
+ Checksum based whitelist of acceptable configuration files
+ Project root detection : `:call localconfig#GetProjectRoot(".vim")`
+ Edit configuration with autoreload and whitelist update on save : `:LocalConfig`. Unsafe files trigger a prompt before loading.

## Configuration

Default configuration is as follow:
```vim
" Name of the configuration file
let g:localconfig_file = 'config.vim'

" Name of the configuration directory.
" Set it to an empty string to use the root itself rather than a subdirectory to store the configuration
" In this case, root detection is solely based on git and will fallback to the current directory if not found
let g:localconfig_directory = '.vim'

" Automatically reload the configuration file after saving.
let g:localconfig_autoreload = v:true

" Whitelist policy. Acceptable values are:
" 'sha256': the default, checks the content of the configuration file against the previously computed checksum before loading the file
" 'filename': only check the file name against the whitelist of configuration files
" '': STRONGLY DISCOURAGED, deactivate completely the whitelist system
let g:localconfig_whitelist_policy = "sha256"

" Directory in which the whitelist is stored.
let g:localconfig_cache_directory = '~/.config/nvim/localconfig'

" Trace level. Acceptable values are:
" 'silent': No trace at all. Errors still show up
" 'info': An info message will let you know that a configuration file was loaded. Recommended
" 'debug': Use this if you get inexplicable error messages. Details the important steps of the file verification process
let g:localconfig_traces = "info"
```

## Security

Loading arbitrary vimscript files is dangerous. They run with the user's privileges and can do ANYTHING the user can. Including silently loading a public rsa key into your `.ssh/authorized_keys` file for example, giving whomever last touched the file remote access to your account.

To avoid this issue while retaining the usefulness of a local configuration that may be shared between users (through git for example), this plugin manages a whitelist of files that can be loaded along with the signature of their last known content. In case of mismatch, for example if the file is not registered in the whitelist or if someone else modified it, an error will be shown and the file won't be loaded.

It may happen that you see the error showing up when nothing nefarious has happened. A colleague may have changed the file, you may have edited it from without Vim, or the whitelist was somehow corrupted. In this event, simply open the file from Vim (with this plugin active), **review it carefully**, then save it. A prompt will offer you to generate the signature file. Press 'y' to accept, then 'y' again to load the file immediately. You'll have to repeat this for all of your configuration files if you change the some part of the plugin configuration that deals with whitelist management.

Avoid sourcing other files from the local configuration file, no verification will be done on those. I'll provide something to solve this problem in the future.

## Roadmap

PR welcome!

Things I'd like to add:
+ Support for other VCSs. I only use git so feel free to chime in if you know how they work
+ Windows support. In this state it won't work correctly
+ Expose some of the internal mechanisms to allow whitelisting and checking other files from vimscript
