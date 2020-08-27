let ext = expand("%:e:e:r")
let matching = uniq(sort(filter(split(execute('autocmd filetypedetect'), "\n"), 'v:val =~ "\*\." . ext')))

if len(matching) >= 1 && matching[0]  =~ 'setf'
   let lang = matchstr(matching[0], 'setf\s\+\zs\k\+')
   call execute('set syntax=' . lang)
endif

syn cluster vimFuncBodyList	add=ntangleSection,ntangleSectionReference
syntax match ntangleSection /^@[^[:space:]@]\+[+\-]\?=\s*$/
syntax match ntangleSectionReference /^\s*@[^=@[:space:]]\+\s*$/
highlight link ntangleSectionReference Special
highlight link ntangleSection Special

