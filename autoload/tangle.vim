if !exists("g:tangle_code_dir")
	let g:tangle_code_dir = "~/fakeroot/code"
endif

if !exists("g:tangle_cache_file")
	let g:tangle_cache_file = expand("~/tangle_cache.txt")
endif

if !exists("g:tangle_cache_skip_filenames")
	let g:tangle_cache_skip_filenames = 1
endif

function! tangle#BuildCache()
	let files = split(glob(g:tangle_code_dir . "/**/*.tl"), "\n")
	
	let globalcache = {}
	
	for file in files
		let filerefs = []
		
		let lines = readfile(file)
		for line in lines
			if line =~ '^@[^@]\S*='
				let ml = matchlist(line, '@\(.\{-}\)\([+\-]\?=\)')
				let name = ml[1]
				
				if g:tangle_cache_skip_filenames && name =~ '\.'
					continue
				endif
				call add(filerefs, name)
				
			endif
			
		endfor
		
		call uniq(filerefs)
		let globalcache[file] = filerefs
		
	endfor
	
	let savelines = []
	for fn in keys(globalcache)
		for section in globalcache[fn]
			call add(savelines, join(split(section, '_'), ' ') . " " . fn)
		endfor
	endfor
	call writefile(savelines, g:tangle_cache_file)
	echo "Cache saved to " . g:tangle_cache_file
	
endfunction

"@start_function

let s:REFERENCE = 1

let s:TEXT = 2

let s:lineindex = 1

function! tangle#TangleCurrentBuffer(outputdir)
	if line('$') <= 1
		return
	endif
	
	let sections = {}
	
	let roots = []
	
	for i in range(1, line('$'))
		let line = getline(i)
		
		if line =~ '^\s*@@'
			if len(sections) == 0
			endif
			
			let ml = matchlist(line, '\(.*\)@@\(.*\)')
			let text = ml[1] . "@" . ml[2]
			let l = { 'type' : s:TEXT, 'str' : text }
			
			let l['ref'] = i
			
			call add(cur_section['lines'], l)
			
		
		elseif line =~ '^@\S\+[+\-]\?=\s*$'
			let ml = matchlist(line, '@\(.\{-}\)\([+\-]\?=\)')
			let name = ml[1]
			let op = ml[2]
			
			let section = { 'lines' : [] }
			
			if op == '='
				call add(roots, name)
			endif
			
			if op == '+=' || op == '-=' 
				if has_key(sections, name)
					if op == '+='
						call add(sections[name], section)
						let cur_section = section
						
					else " op == '-='
						call insert(sections[name], section, 0)
						let cur_section = section
						
					endif
				else
					let sections[name] = [section]
					let cur_section = section
				endif
			
			else
				let sections[name] = [section]
				let cur_section = section
			endif
			
			
		
		elseif line =~ '^\s*@\S\+\s*$'
			let ml = matchlist(line, '\(\s*\)@\(\S\+\)')
			
			if len(sections) == 0
			endif
			
			let l = { 'type' : s:REFERENCE, 'str' : ml[2], 'prefix' : ml[1] }
			
			let l['ref'] = i
			
			call add(cur_section['lines'], l)
			
		
		else
			if len(sections) == 0
			endif
			
			let l = { 'type' : s:TEXT, 'str' : line }
			
			let l['ref'] = i
			
			call add(cur_section['lines'], l)
			
		endif
		
	endfor
	
	let parentdir = expand("%:p:h")
	
	for outputnode in roots
		let lines = []
		call tangle#TraverseNode(lines, "", outputnode, sections)
		
		let filename = outputnode
		if filename == "*"
			let filename = expand("%:t:r")
		endif
		let fullpath = parentdir . "\\" . a:outputdir . "\\" . filename
		if filename =~ '/'
			let dirs = split(filename, '/')
			
			let curdir = parentdir . "\\" . a:outputdir . "\\"
			for i in range(0, len(dirs)-2)
				let curdir = curdir . dirs[i]
				if !isdirectory(curdir)
					call mkdir(curdir)
				endif
				let curdir = curdir . "\\"
			endfor
			
			let fullpath = curdir . dirs[-1]
		endif
		
		call writefile(lines, fullpath)
		
	endfor
	
endfunction

function! tangle#TraverseNode(lines, prefix, name, sections)
	if !has_key(a:sections, a:name)
		return -1
	endif
	let sectionList = a:sections[a:name]
	
	for section in sectionList
		for line in section["lines"]
			if line['type'] == s:REFERENCE
				let totalprefix = a:prefix . line['prefix']
				call tangle#TraverseNode(a:lines, totalprefix, line['str'], a:sections)
			
			elseif line['type'] == s:TEXT
				let linetext = a:prefix . line['str']
				call add(a:lines, linetext)
			endif
			
		endfor
	endfor
	
endfunction

function! tangle#GoToLine(args)
	let sections = {}
	
	let roots = []
	
	for i in range(1, line('$'))
		let line = getline(i)
		
		if line =~ '^\s*@@'
			if len(sections) == 0
			endif
			
			let ml = matchlist(line, '\(.*\)@@\(.*\)')
			let text = ml[1] . "@" . ml[2]
			let l = { 'type' : s:TEXT, 'str' : text }
			
			let l['ref'] = i
			
			call add(cur_section['lines'], l)
			
		
		elseif line =~ '^@\S\+[+\-]\?=\s*$'
			let ml = matchlist(line, '@\(.\{-}\)\([+\-]\?=\)')
			let name = ml[1]
			let op = ml[2]
			
			let section = { 'lines' : [] }
			
			if op == '='
				call add(roots, name)
			endif
			
			if op == '+=' || op == '-=' 
				if has_key(sections, name)
					if op == '+='
						call add(sections[name], section)
						let cur_section = section
						
					else " op == '-='
						call insert(sections[name], section, 0)
						let cur_section = section
						
					endif
				else
					let sections[name] = [section]
					let cur_section = section
				endif
			
			else
				let sections[name] = [section]
				let cur_section = section
			endif
			
			
		
		elseif line =~ '^\s*@\S\+\s*$'
			let ml = matchlist(line, '\(\s*\)@\(\S\+\)')
			
			if len(sections) == 0
			endif
			
			let l = { 'type' : s:REFERENCE, 'str' : ml[2], 'prefix' : ml[1] }
			
			let l['ref'] = i
			
			call add(cur_section['lines'], l)
			
		
		else
			if len(sections) == 0
			endif
			
			let l = { 'type' : s:TEXT, 'str' : line }
			
			let l['ref'] = i
			
			call add(cur_section['lines'], l)
			
		endif
		
	endfor
	
	let node = roots[0]
	if a:args =~ ":"
		let m = split(a:args, ":")
		let node = m[0];
		let linesearch = str2nr(m[1])
	else
		let linesearch = str2nr(a:args)
	endif
	
	let s:lineindex = 1
	let linesnr = tangle#TraverseNodeLineNr(linesearch, node, sections)
	
	if linesnr == -1
		echoerr "Could not go to line"
	else
		call execute("normal " . linesnr . "gg")
	endif
	
endfunction

function! tangle#TraverseNodeLineNr(linesearch, name, sections)
	if !has_key(a:sections, a:name)
		return -1
	endif
	let sectionList = a:sections[a:name]
	
	for section in sectionList
		for line in section["lines"]
			if line['type'] == s:REFERENCE
				let linesnr = tangle#TraverseNodeLineNr(a:linesearch, line['str'], a:sections)
				if linesnr != -1
					return linesnr
				endif
			
			elseif line['type'] == s:TEXT
				if s:lineindex == a:linesearch
					return line['ref']
				endif
				let s:lineindex = s:lineindex+1
			endif
			
		endfor
	endfor
	
	return -1
	
endfunction


