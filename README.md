# Goldsmith

Go development environment for Neovim utilizing the builtin LSP and other features and plugins specific to Neovim.

## Features / TODO
- [x] goimports
    - [x] run automatically upon save with gopls
- [x] treesitter navigation - uses [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
    - [x] jump to next/previous function/method
- [x] treesitter text objects - uses [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
    - [x] function (af/if)
    - [x] comment (ac)
- [x] GoDoc - for viewing installed documentation
    - [x] package name completion
    - [x] retrieve documentation for individual functions/methods
- [x] GoImports - manually run goimports (via gopls)
- [x] GoBuild  - go build
- [x] GoRun - go run
- [x] GoFormat - manually run formatter(s)
- [x] GoGet - run go get
- [x] GoInstall - run go install
- [x] GoLint - for manually running linter(s) (via nvim-lint)
- [x] GoInstallBinaries - install all needed 3rd-party tools
- [x] plugin documentation
    - [x] vim doc
    - [x] list of all needed/supported [n]vim plugins
- [x] structs
    - [x] field tag editing (gomodifytags) - asynchronous
- [x] checkhealth
- [x] interface support
    - [x] impl (https://github.com/josharian/impl)
- [x] fixplurals (https://github.com/davidrjenni/reftools) 
    - [x] :GoFixPlurals
- [x] go.mod 
    - [x] editing (such as replace etc...)
    - [x] formatting :GoModFmt
    - [x] tidy :GoModTidy
    - [x] :GoModCheck - check for upgrades for all listed packages
- [ ] testing support
    - [x] GoAddTests
    - [x] GoAddTest
    - [ ] make :GoTest a wrapper around vim-test? or vim-ultest? both? none?
    - [x] use `gotests` to generate skeleton testing file
        - [x] GoAddTests (-all support)
        - [x] GoAddTest (-only support) - works on current function if no arg
        - [x] completion for test names w/GoAddTest
        - [x] template support
        - [x] parallel option
        - [x] exported option
    - [x] alternate file support
        - [x] GoAlt - switch to test file and back to source
        - [x] should not require a new window
- [ ] LSP config related
    - [x] help config gopls
    - [x] help config efm
    - [x] help config nvim-lint
    - [ ] configuration items to control above
    - [ ] vim docs for all
    - [ ] show source of warning/errors/etc... in vtext (i.e. show that 'efm' is the source)
- [ ] general work
    - [ ] config for all autocmds
    - [ ] far better config validation; mechanism to warn of major config changes
    - [ ] disable commands that don't have deps installed
    - [ ] errorformats for at least some of the commands
    - [ ] need command to create basic revive config
    - [x] make certain async commands operate on correct buffer
- [ ] README should have basic install instructions once ready for release

## Details
Written in Lua so it only works with NeoVim. This is meant to be both useful (to me, at least) and to work as a testbed
for working with Lua in NeoVim. This is the first thing I have ever written using Lua. I have written a fair amount of
VimScript, but have never made a dedicated package I wished to share.

## Documentation
Please see the documentation [here](https://github.com/WhoIsSethDaniel/goldsmith.nvim/blob/main/doc/goldsmith.txt) for much more information.

## Similar Projects
* [go.nvim](https://github.com/ray-x/go.nvim)
* [nvim-go](https://github.com/crispgm/nvim-go)
