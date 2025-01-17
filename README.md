# Goldsmith
Go development environment for Neovim utilizing the builtin LSP and other features and plugins specific to Neovim.

# Features
view all screencasts [here](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1)

* codelens support [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1#codelens-support)
* flag and update out-of-date dependencies in your current Go module [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1#go-module-check-for-updates)
* automatically run goimports on save [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-1#run-goimports-on-save)
* auto-highlight the current symbol under the cursor throughout the current buffer [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-2#symbol-highlighting)
* treesitter navigation utilizing the nvim-treesitter-textobjects plugin
* treesitter text objects utilizing the nvim-treesitter-textobjects plugin
* convert JSON to Go structs directly in your code, or paste from outside the editor [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-5#convert-json-to-go-struct)
* view Go documentation using the :GoDoc command and Go help with :GoHelp [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-2#documentation-and-help)
* manually update imports using the :GoImports command [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-2#manual-goimports-support)
* use :checkhealth to see if your Goldsmith setup should work correctly [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#use-checkhealth-to-check-goldsmith-setup)
* format your code on demand using :GoFormat or have Goldsmith automatically format your code on save [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#manual-formatting-using-goformat)
* integration with [Telescope](https://github.com/nvim-telescope/telescope.nvim) for a number of file picking needs [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-6#telescope-integration)
* run extra linters and/or formatters using null-ls: currently has support for golines, gofmt, gofumpt, revive, golangci-lint, and staticcheck
* see the source of the diagnostic when running extra linters
* Goldsmith can completely configure everything for you, if you want (see the [Configurations](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Configurations) wiki for more)
* generate test stubs automatically using `gotests` [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#switch-to-alternate-file--generate-stub-tests)
* create implementation stubs for your interfaces using :GoImpl [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-4#create-interface-implementation-stubs)
* :GoFillStruct utilizes LSP to fill the current struct
* switch to the 'alternate' file quickly [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-3#switch-to-alternate-file--generate-stub-tests)
* struct tag editing: add / remove / update struct tags and options [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-4#struct-tag-editing)
* use common go subcommands from within Neovim with: :GoBuild, :GoInstall, :GoGet, :GoRun, and others [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-4#using-gobuild-and-gorun)
* coverage support: annotate the current buffer and store coverage data for all files affected [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-5#coverage-report)
* statusline integration: see the status of running jobs and of coverage data for the current buffer [screencast](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Features-5#statusline-integration)
* edit the go.mod file from within Neovim with: :GoModTidy, :GoModCheck, :GoModRetract, :GoModReplace, and others
* use the excellent builtin testing framework to run individual tests, package tests, or all your tests
* all the great Neovim LSP functions are available as Vim commands
* most commands are completely asynchronous
* support for [lspinstall](https://github.com/kabouzeid/nvim-lspinstall) and [nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer)

# Installation
Install using your favorite plugin manager. 

If you use vim-plug:
```vim
Plug 'WhoIsSethDaniel/goldsmith.nvim'
```
Or if you use Vim 8 style packages:
```bash
cd <plugin dir>
git clone https://github.com/WhoIsSethDaniel/goldsmith.nvim
```

# Quickstart
1. Install [Go](https://golang.org/dl/).
1. Install Goldsmith, [lspconfig](https://github.com/neovim/nvim-lspconfig), [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) and [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim).
1. Install required external programs: 
    ```bash
    nvim +GoInstallBinaries
    ```
    You may receive some warnings from Goldsmith about missing programs. These can be ignored since you are now installing those programs.

    After the installation completes (usually within a minute or so) run 
    ```vim
    :checkhealth goldsmith
    ```
    Make certain everything looks okay.
1. Restart Neovim.  
1. Start editing Go code.
1. Currently you are running with Goldsmith defaults. So take a look at the documentation and tweak your configuration.

# Configuration
See the [configuration page](https://github.com/WhoIsSethDaniel/goldsmith.nvim/wiki/Configurations) on the wiki for examples demonstrating how
to configure Goldsmith.

Also see the Goldsmith [:help documentation](https://github.com/WhoIsSethDaniel/goldsmith.nvim/blob/main/doc/goldsmith.txt) or 
after installing Goldsmith by using `:h goldsmith`.

# Minimal Requirements
* Neovim >= 0.5.0
* go >= 1.14
* gopls >= 0.6.6[\*] 
* [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

These 'minimal' requirements are not hard-and-fast. They are simply the minimal versions that the author has been able
to test with. Goldsmith may work just fine with older versions of Go, gopls, etc.... Neovim, however, must be at least
0.5.0 and nvim-lspconfig is also a hard requirement.

Goldsmith *will not work* with Vim or versions of Neovim prior to 0.5.0.

Run `:checkhealth goldsmith` after installing to see what is required and what needs to be done to meet the minimal 
requirements.

[\*] Goldsmith depends on package completion provided by gopls. Prior to 0.6.6 this did not exist. If you use a gopls
earlier than 0.6.6 it means package completion will not work for those commands that require it.

# Reporting Problems / Asking Questions
Goldsmith is very new. It works for the author, but does it work for you? If not, please consider [asking a 
question](https://github.com/WhoIsSethDaniel/goldsmith.nvim/discussions) or [reporting a
problem](https://github.com/WhoIsSethDaniel/goldsmith.nvim/issues).
