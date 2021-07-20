if !has('nvim-0.5')
    call nvim_echo([['goldsmith requires at least neovim 0.5.0.', 'ErrorMsg']], v:true, {})
    finish
endif

lua require'goldsmith.lsp.autoconfig'.config()