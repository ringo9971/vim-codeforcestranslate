scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let g:codeforcestrancelate_directory = expand('~/codeforces/list')

let s:dict = {
      \ '\s\+': ' ', '</p> <p>': '\n', '<li>': '\n * ', '\(<.\{-}>\|\$\|\^M\)': '', 
      \ '\\le': '<=', '\\dots': '...', '\\cdot': 'x', '\\frac{\(.\{-}\)}{\(.\{-}\)}': '\1/\2', 
      \ '\( \| \)*—\( \| \)*': ' -- ', '\(document\).*$': '\1', '': ''
      \ }


function! codeforcestranslate#getpath(url) abort
  let s:ret = split(a:url, '/')
  return [s:ret[4], s:ret[6]]
endfunction

function! codeforcestranslate#curl(url, filepath) abort
  let s:list = system('curl ' . a:url)
  call system('touch ' . a:filepath)

  let s:list = substitute(s:list, '.*perty-title">input</div>standard input</div>     <div class="output-file">       <div class="property-title">output</div>standard output</div></div>   <div>     <p>', '', 'g')

  for item in items(s:dict)
    let s:list = substitute(s:list, item[0], item[1], 'g')
  endfor


  let s:tmppath = expand('~/codeforces/list/tmp')
  if filereadable(s:tmppath)
    call system('rm ' . s:tmppath)
  endif
  call writefile([s:list], s:tmppath, 'a')


  let s:list = system('cat -A ' . s:tmppath)
  let s:list = substitute(s:list, '\^@', '\n', 'g')
  let s:list = substitute(s:list, '[\s\n]*\s(document.*$', '', 'g')

  let s:bun = substitute(s:list, 'Input.*', '', 'g')

  let s:input = substitute(s:list, '^.\{-}input ', '', 'g')
  let s:input = substitute(s:input, 'output.*', '', 'g')

  let s:output = substitute(s:list, '^.\{-}output', '', 'g')
  let s:output = substitute(s:output, 'examples\?.*', '', 'g')

  let s:example = substitute(s:list, '^.\{-}examples\?\s*input', '', 'g')
  if match(s:example, 'note') != -1
    let s:example = substitute(s:example, 'Note.*', '', 'g')
  endif

  let s:note = substitute(s:list, '.\{-}output\(.\{-}\)document.*$', '\1', 'g')
  if match(s:note, 'note') == -1
    let s:note = ''
  else
    let s:note = substitute(s:note, '.\{-}note', '', 'g')
  endif

  call writefile(['bun', s:bun, 'bun', 'nyuuryoku', s:input, 'nyuuryoku', 'syuturyoku', s:output, 'syuturyoku', 'nyuusyuturei', s:example, 'nyuusyuturei', 'notedayo', s:note, 'notedayo'], s:filepath)
endfunction

function! codeforcestranslate#main(url) abort
  let s:p = codeforcestranslate#getpath(a:url)

  let s:filepath = g:codeforcestrancelate_directory . '/' . s:p[0]
  if !isdirectory(s:filepath)
    call mkdir(s:filepath, 'p')
  endif
  let s:filepath = s:filepath . '/' . s:p[1]

  if !filereadable(s:filepath)
    call codeforcestranslate#curl(a:url, s:filepath)
  endif

  let s:list = system('cat -A ' . s:filepath)
  let s:list = substitute(s:list, '\^@', '\n', 'g')
  let s:list = substitute(s:list, '\s*\$', '', 'g')

  let s:bun     = matchstr(s:list, 'bun\_.*bun'                  )[4:-5]
  let s:input   = matchstr(s:list, 'nyuuryoku\_.*nyuuryoku'      )[10:-11]
  let s:output  = matchstr(s:list, 'syuturyoku\_.*syuturyoku'    )[12:-12]
  let s:example = matchstr(s:list, 'nyuusyuturei\_.*nyuusyuturei')[15:-15]
  let s:note    = matchstr(s:list, 'notedayo\_.*notedayo'        )[10:-10]
  
  let s:example = split(s:example, '\(Input\|Output\)')
  for i in range(len(s:example))
    let s:example[i] = substitute(s:example[i], '^\s*\n', '', 'g')
    let s:example[i] = substitute(s:example[i], '\s*\n\s*$', '', 'g')
  endfor

  let s:tmppath = expand('~/codeforces/list/tmp')
  execute ':redir! > ' . s:tmppath
      silent! echon '問題文'  . "\n"
      silent! echon s:bun     . "\n\n"
      silent! echon '入力'    . "\n"
      silent! echon s:input   . "\n\n"
      silent! echon '出力'  . "\n"
      silent! echon s:output  . "\n\n"
      for i in range(len(s:example)/2)
        silent! echon '入力例' . (i+1)  . "\n"
        silent! echon s:example[i*2] . "\n\n"
        silent! echon '出力例' . (i+1)  . "\n"
        silent! echon s:example[i*2+1] . "\n\n"
      endfor
      silent! echon 'ノート'  . "\n"
      silent! echon s:note    . "\n\n"
  redir END

  execute 'vs ' . s:tmppath
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

