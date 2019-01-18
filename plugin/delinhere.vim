let s:bk_op = ['[','(','{']

function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! FindClosestPair ()
    let l:bk_op = ['\[','(','{']
    let l:bk_cl = ['\]',')','}']
    let l:type_n = -1
    let l:closest = [0,0]
    for i in [0,1,2]
        let _start = l:bk_op[i]
        let _end = l:bk_cl[i]
        " Works, but can only search for a single type pair
        " b: backward, n: don't move cursor, z: search from cursor column instead of
        " zero, p: return number of matching sub-Pattern
        let l:all = searchpairpos(_start,'',_end, 'bnW','(synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment")')
        if l:all[0] > l:closest[0]
            let l:closest = l:all
            let l:type_n = i
        elseif all[0] == l:closest[0]
            if all[1] > l:closest[1]
                let l:closest = l:all
                let l:type_n = i
            endif
        endif
    endfor
    return [l:closest, l:type_n]
endfunction

function! s:CmdBracketType (verb, adverb, line_col, type_n)
    let [l:line, l:col] = a:line_col
    call cursor(line,col+1)
    call feedkeys(a:verb . a:adverb . s:bk_op[a:type_n], 'n')
endfunction

function! s:TryCmdBracketType(verb, adverb)
    let [s:loc, s:type] = FindClosestPair()
    " We filter out the not-matches
    if s:type == -1
        return
    else
        call s:CmdBracketType(a:verb,a:adverb,s:loc,s:type)
    endif
endfunction


" Select functions --- {{{

function! SelectInHere()
    call s:TryCmdBracketType('v','i')
endfunction

function! SelectAroundHere()
    call s:TryCmdBracketType('v','a')
endfunction

function! SelectInHereAndLeave()
    call s:TryCmdBracketType('v','i')
    exe "normal! <esc>"
endfunction

"}}}

" Change/Delete functions --- {{{

function! DeleteInHere()
    call s:TryCmdBracketType('d','i')
endfunction

function! DeleteAroundHere()
    call s:TryCmdBracketType('d','a')
endfunction

function! ChangeInHere()
    call s:TryCmdBracketType('c','i')
endfunction

function! ChangeAroundHere()
    call s:TryCmdBracketType('c','a')
endfunction

"}}}

" Yank functions --- {{{

function! YankInHere()
    call s:TryCmdBracketType('y','i')
endfunction

function! YankAroundHere()
    call s:TryCmdBracketType('y','a')
endfunction

"}}}

function! s:SplitNStrip(arg_string)
        let l:arg_list = split(a:arg_string, ",")
        let l:new_list = []
        for ar in l:arg_list
            let l:new_list = new_list + [Strip(ar)]
        endfor
        return new_list
endfunction

function! FindArgs ()
    let [l:op, l:type] = FindClosestPair()
    let l:bk_op = ['\[','(','{']
    let l:bk_cl = ['\]',')','}']
    let l:cl = searchpairpos(l:bk_op[l:type],'',l:bk_cl[l:type], 'nW','(synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment")')
    let l:lines = getline(op[0], cl[0])
    if op[0] == cl[0]
        " Same line
        let l:end = cl[1]  - 2
        return s:SplitNStrip(lines[0][op[1]:end])
    else
        let l:end = cl[1] - 1
        let l:lines = [lines[0][op[1]:]] + lines[1:-2] + [lines[-1][:end]]
        " join(lines, "\n")
        echo lines
    endif
endfunction

function! s:CycleArgs (ori, args)
    let l:largs = a:args
    if a:ori == "+"
        let l:rot =  [largs[-1]] +  largs[:-2]
    elseif a:ori == "-"
        let l:rot =  largs[1:] + [largs[0]]
    endif
    return rot
endfunction

function! s:Perm (ori)
    let save_cursor = getcurpos()

    let l:args = FindArgs()
    let l:nargs = s:CycleArgs(a:ori, args)
    call DeleteInHere()
    exec "normal! i" . join(nargs,", ")

    call setpos('.', save_cursor)
endfunction

function! CyclicPerm ()
    call s:Perm('+')
endfunction

function! AcyclicPerm ()
    call s:Perm('-')
endfunction

" Mappings functions --- {{{
nnoremap dih  :call DeleteInHere()<CR>
nnoremap dah  :call DeleteAroundHere()<CR>
nnoremap cih  :call ChangeInHere()<CR>
nnoremap cah  :call ChangeAroundHere()<CR>
nnoremap yih  :call YankInHere()<CR>
nnoremap yah  :call YankAroundHere()<CR>
nnoremap vih  :call SelectInHere()<CR>
nnoremap vah  :call SelectAroundHere()<CR>
nnoremap ;fa  :call FindArgs()<CR>
nnoremap ;fb  :call CyclicPerm()<CR>
nnoremap ;fc  :call AcyclicPerm()<CR>
"}}}
