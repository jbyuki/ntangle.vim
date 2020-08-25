let ext = expand("%:t:r:e")

if ext != ""
	call execute("set syntax=" . ext)
endif

syn cluster vimFuncBodyList	add=ntangleSection,ntangleSectionReference
syntax match ntangleSection /^@[^[:space:]@]\+[+\-]\?=\s*$/
syntax match ntangleSectionReference /^\s*@[^=@[:space:]]\+\s*$/
highlight link ntangleSectionReference Special
highlight link ntangleSection Special


