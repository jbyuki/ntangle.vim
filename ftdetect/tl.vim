function! s:setFT(cft)
	call execute("set ft=" . a:cft)
endfunction
autocmd BufNewFile,BufRead *.tl call s:setFT(expand("<afile>:e:e"))
