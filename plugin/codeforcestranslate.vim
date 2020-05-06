scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if exists('g:codeforcestranslate')
  finish
endif
let g:codeforcestranslate = 1


command! -nargs=1 CodeforcesTaranslate call codeforcestranslate#main(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
