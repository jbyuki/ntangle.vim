syntax match xSection /^@[^[:space:]@]\+[+\-]\?=\s*$/
syntax match xSectionReference /^\s*@[^=@[:space:]]\+\s*$/
highlight link xSectionReference Special
highlight link xSection Special
