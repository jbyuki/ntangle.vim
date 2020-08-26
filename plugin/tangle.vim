let g:tangle_dir = "tangle"
let g:tangle_cache_file = expand("~/tangle_cache.txt")

function! SaveTangle()
	let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
	let path_dir = expand("%:p:h") . "/" . g:tangle_dir
	if !isdirectory(path_dir)
		call mkdir(path_dir)
	endif
	call tangle#TangleCurrentBuffer(g:tangle_dir)
endfunction

autocmd BufWrite *.tl call SaveTangle()
command! -nargs=1 TangleGoto :call tangle#GoToLine("<args>")
command! TangleBuildCache :call tangle#BuildCache()
