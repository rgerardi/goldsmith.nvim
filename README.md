# Goldsmith

Go development environment for Neovim utilizing the builtin LSP and other features and plugins specific to Neovim.

## Features
* :GoDoc command (see below)
* auto-run goimports upon save
* jump to next/previous function/method. Utilizes treesitter.

## Commands
To view documentation in a window use GoDoc:
```
:GoDoc [opts] <doc> 
```
e.g. 
```
view documentation for the 'fmt' package
:GoDoc fmt

use any option you can pass to 'go doc'
view all documentation for the 'fmt' package
:GoDoc -all fmt

view the source code for the 'fmt' package
:GoDoc -src fmt
```

## Mappings
You can map jumping to the next/previous function/method. The following maps ]] to jump to the
next function/method and [[ to jump to the previous function/method:
```
vim.api.nvim_set_keymap( 'n', ']]', '<Plug>(goldsmith-next-function)', { silent = true })
vim.api.nvim_set_keymap( 'n', '[[', '<Plug>(goldsmith-prev-function)', { silent = true })
```

## Configuration
By default help pages are open in a horizontal window. One way to change this is to set
```
let g:goldsmith_open_split = 'vertical'
```
This will open help pages in a vertical window.

## Details
Written in Lua so it only works with NeoVim. This is meant to be both useful (to me, at least) and to work as a testbed
for working with Lua in NeoVim. This is the first thing I have ever written using Lua. I have written a fair amount of
VimScript, but have never made a dedicated package I wished to share.

## TODO
* documentation
    * floating window support
    * keyword support
    * retrieve documentation for individual functions/methods
    * vendor dir support for completion
    * LSP support
* many other things
