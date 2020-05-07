scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let g:codeforcestrancelate_directory = expand('~/codeforces/list')
let s:url = ''

let s:ac = ["    _       ____   _","   / \\     / ___| | |","  / _ \\   | |     | |"," / ___ \\  | |___  |_|","/_/   \\_\\  \\____| (_)",""]
let s:wa = ["__        __     _      _ ","\\ \\      / /    / \\    | |"," \\ \\ /\\ / /    / _ \\   | |","  \\ V  V /    / ___ \\  |_|","   \\_/\\_/    /_/   \\_\\ (_)",""]

let s:dict = {
      \ '\s\+': ' ', '</p> <p>': '\n', '<li>': '\n * ', '\(<.\{-}>\|\$\|\^M\)': '', 
      \ '\\dots': '...', '\\cdot': 'x', '\\frac{\(.\{-}\)}{\(.\{-}\)}': '\1/\2', 
      \ '\( \| \)*—\( \| \)*': ' -- ', '\(.document\).*$': '', '': ''
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
  call writefile([s:list], s:filepath)


  let s:tmppath = expand('~/codeforces/list/tmp')
  if filereadable(s:tmppath)
    call system('rm ' . s:tmppath)
  endif
  call writefile([s:list], s:tmppath, 'a')

  let s:list = system('cat -A ' . s:tmppath)
  let s:list = substitute(s:list, '\^@', '\n', 'g')
  let s:list = substitute(s:list, '\\le', '<=', 'g')
  let s:list = substitute(s:list, '\(\n\|\$\)*\%$', '', 'g')

  let s:bun = substitute(s:list, 'Input.*', '', 'g')

  let s:input = substitute(s:list, '^.\{-}input ', '', 'g')
  let s:input = substitute(s:input, 'output.*', '', 'g')

  let s:output = substitute(s:list, '^.\{-}output', '', 'g')
  let s:output = substitute(s:output, 'examples\?.*', '', 'g')

  let s:example = substitute(s:list, '^.\{-}examples\?\s*input', '', 'g')
  if match(s:example, 'note') != -1
    let s:example = substitute(s:example, 'Note.*', '', 'g')
  endif
  let s:example = substitute(s:example, '\(\s\|\n\)*\%$', '', 'g')

  let s:note = substitute(s:list, '.\{-}output\(.\{-}\)document.*$', '\1', 'g')
  if match(s:note, 'note') == -1
    let s:note = ''
  else
    let s:note = substitute(s:note, '.\{-}note', '', 'g')
  endif

  call writefile(['bun', s:bun, 'bun', 'nyuuryoku', s:input, 'nyuuryoku', 'syuturyoku', s:output, 'syuturyoku', 'nyuusyuturei', s:example, 'nyuusyuturei', 'notedayo', s:note, 'notedayo'], s:filepath)
endfunction

function! codeforcestranslate#main(url) abort
  let s:url = a:url
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
  let s:list = substitute(s:list, '\(\s\|\$\|\n\)*notedayo', '\nnotedayo', 'g')


  let s:bun     = matchstr(s:list, 'bun\_.*bun'                  )[5:-6]
  let s:input   = matchstr(s:list, 'nyuuryoku\_.*nyuuryoku'      )[11:-12]
  let s:output  = matchstr(s:list, 'syuturyoku\_.*syuturyoku'    )[12:-13]
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

function! codeforcestranslate#checksample() abort
  if s:url ==# ''
    echo '先にCodeforcesTranslateを実行して下さい'
    return
  endif

  let s:height = 11
  let s:col = [0, 3, 6, 6, 4, 4]
  let s:table = []
  let s:a = system('g++ -std=gnu++17 -O2 ' . expand('%'))

  let s:is_ac = v:true
  
  for i in range(len(s:example)/2)
    let s:a = system('echo ' . substitute(s:example[i*2], "\n", '', 'g') . ' | ./a.out')
    let s:a = substitute(s:a, "\n$", '', '')

    let s:now = [string(i+1), s:example[i*2], s:example[i*2+1], s:a]
    if s:a !=# s:example[i*2+1]
      call add(s:now, 'WA')
      let s:is_ac = v:false
    else
      call add(s:now, 'AC')
    endif

    call s:colupdate(s:now)
    call add(s:table, s:now)
  endfor

  let s:col[0] = (160-(s:col[1]+s:col[2]+s:col[3]+s:col[4]+s:col[5]))/2
  let s:str = '+' . repeat('-', s:col[1]+2) . '+' . repeat('-', s:col[2]+2) . '+' . repeat('-', s:col[3]+2) . '+' . repeat('-', s:col[4]+2) . '+' . repeat('-', s:col[5]+2) . '+'
  for i in range(1, 5)
    let s:col[i] += s:col[i-1]+3
  endfor
  let s:col[-1] -= 3


  let s:winid = popup_create(s:str, { 'moved': 'any', 'line': s:height-1, 'col': s:col[0]-1 })
	if s:is_ac == v:true
		let s:winac = popup_create(s:ac, {
          \ 'border': [1, 1, 1, 1], 
          \ 'borderchars': ['-', '|', '-', '|', '+', '+', '+', '+'], 
          \ 'moved': 'any', 
          \ 'line': 2
          \ })
	else
		let s:winwa = popup_create(s:wa, {
          \ 'border': [1, 1, 1, 1], 
          \ 'borderchars': ['-', '|', '-', '|', '+', '+', '+', '+'], 
          \ 'moved': 'any', 
          \ 'line': 2
          \ })
	endif

  call s:maketable([['No.'], ['入力例'], ['出力例'], ['出力'], ['判定']])
  for i in s:table
    call s:maketable(i)
  endfor
endfunction

function! s:colupdate(list) abort
  for i in range(1, 3)
    let a:list[i] = split(a:list[i], '\n')
    for j in a:list[i]
      let s:col[i+1] = max([s:col[i+1], len(j)])
    endfor
  endfor
endfunction

function! s:maketable(list) abort
  let s:max = 0
  for i in range(len(a:list))
    let s:winid = popup_create(a:list[i], {
          \ 'moved': 'any', 
          \ 'line': s:height, 
          \ 'col': s:col[i]+1
          \ })

    let s:max = max([s:max, len(a:list[i])])
  endfor

  for i in range(s:max)
    let s:winid = popup_create(repeat(' ', len(s:str)), { 'moved': 'any', 'line': s:height+i, 'col': s:col[0]-1 })
  endfor
  let s:winid = popup_create(s:str, { 'moved': 'any', 'line': s:height+s:max, 'col': s:col[0]-1 })

  let s:height += s:max+1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
