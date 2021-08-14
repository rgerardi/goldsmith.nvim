if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

compiler go

setlocal textwidth=0
setlocal noexpandtab
setlocal formatoptions-=t
setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s

function s:GoDocComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.doc'.doc_complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:GoHelpComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.doc'.help_complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:GoAddTestComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.tests'.complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:GoImplComplete(A,C,P) abort
	return luaeval("require'goldsmith.cmds.impl'.complete(_A[1], _A[2], _A[3])", [a:A, a:C, a:P])
endfunction

function s:TagAction(act,line1,line2,count,...) abort
    if a:act ==? 'add'
        return luaeval("require'goldsmith.cmds.tags'.add(_A[1],_A[2],_A[3],_A[4])", [a:line1, a:line2, a:count, a:000])
    elseif a:act ==? 'remove'
        return luaeval("require'goldsmith.cmds.tags'.remove(_A[1],_A[2],_A[3],_A[4])", [a:line1, a:line2, a:count, a:000])
    endif
endfunction

" terminal/window commands
command! -nargs=+ -complete=custom,s:GoDocComplete GoDoc lua require'goldsmith.cmds.doc'.run('doc', <f-args>)
command! -nargs=1 -complete=custom,s:GoHelpComplete GoHelp lua require'goldsmith.cmds.doc'.run('help', <f-args>)
command! -nargs=* GoBuild lua require'goldsmith.cmds.build'.run(<f-args>)
command! -nargs=* GoRun lua require'goldsmith.cmds.run'.run(<f-args>)
command! -nargs=* GoGet lua require'goldsmith.cmds.get'.run(<f-args>)
command! -nargs=* GoInstall lua require'goldsmith.cmds.install'.run(<f-args>)
command! -nargs=* GoTest lua require'goldsmith.cmds.test'.run(<f-args>)
command! -nargs=0 -bang GoAlt lua require'goldsmith.cmds.alt'.run('<bang>')

" formatting
command! -nargs=0 GoImports lua require'goldsmith.cmds.format'.run_goimports(1)
command! -nargs=0 GoFormat lua require'goldsmith.cmds.format'.run(1)

" creating/editing tests
command! -nargs=? GoAddTests lua require'goldsmith.cmds.tests'.generate(<f-args>)
command! -nargs=* -complete=custom,s:GoAddTestComplete GoAddTest lua require'goldsmith.cmds.tests'.add(<f-args>)

" code editing
command! -nargs=* -range GoAddTags call s:TagAction('add', <line1>, <line2>, <count>, <f-args>)
command! -nargs=* -range GoRemoveTags call s:TagAction('remove', <line1>, <line2>, <count>, <f-args>)
command! -nargs=0 -range GoClearTags call s:TagAction('remove', <line1>, <line2>, <count>)
command! -nargs=* -complete=custom,s:GoImplComplete GoImpl lua require'goldsmith.cmds.impl'.run(<f-args>)
command! -nargs=0 GoFixPlurals lua require'goldsmith.cmds.fixplurals'.run()

" navigation
command! -nargs=0 GoDef lua require'goldsmith.cmds.lsp'.goto_definition()
command! -nargs=0 GoInfo  lua require'goldsmith.cmds.lsp'.hover()
command! -nargs=0 GoSigHelp lua require'goldsmith.cmds.lsp'.signature_help()
command! -nargs=0 GoDefType lua require'goldsmith.cmds.lsp'.type_definition()
cabbrev GoTypeDef GoDefType
command! -nargs=0 GoCodeAction lua require'goldsmith.cmds.lsp'.code_action()
command! -nargs=0 GoRef lua require'goldsmith.cmds.lsp'.references()
command! -nargs=0 GoShowDiag lua require'goldsmith.cmds.lsp'.show_diagnostics()
command! -nargs=0 GoListDiag lua require'goldsmith.cmds.lsp'.diag_set_loclist()
command! -nargs=1 GoRename lua require'goldsmith.cmds.lsp'.rename(<f-args>)

" highlighting
command! -nargs=0 GoSymHighlight lua require'goldsmith.cmds.lsp'.highlight_current_symbol()
command! -nargs=0 GoSymHighlightOn lua require'goldsmith.cmds.lsp'.turn_on_symbol_highlighting()
command! -nargs=0 GoSymHighlightOff lua require'goldsmith.cmds.lsp'.turn_off_symbol_highlighting()

" codelens
command! -nargs=0 GoCodeLensRun lua require'goldsmith.cmds.lsp'.run_codelens()
command! -nargs=0 GoCodeLensOn lua require'goldsmith.cmds.lsp'.turn_on_codelens()
command! -nargs=0 GoCodeLensOff lua require'goldsmith.cmds.lsp'.turn_off_codelens()

" configs
command! -nargs=0 -bang GoCreateConfigs lua require'goldsmith.cmds.lint'.create_configs('<bang>')

augroup goldsmith_ft_go
  autocmd! * <buffer>
  autocmd BufWritePre <buffer> lua require'goldsmith.cmds.format'.run(0)
  autocmd BufEnter    <buffer> lua require'goldsmith.buffer'.checkin()
  autocmd CursorHold,CursorHoldI <buffer> lua require'goldsmith.highlight'.current_symbol()
  autocmd CursorHold,InsertLeave <buffer> lua require'goldsmith.codelens'.update()
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save
