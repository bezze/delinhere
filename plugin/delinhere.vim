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

function! CmdBracketType (verb, adverb, line_col, type_n)
    let l:bk_op = ['[','(','{']
    let [l:line, l:col] = a:line_col
    call cursor(line,col+1)
    exe 'normal! '. a:verb . a:adverb .l:bk_op[a:type_n]
endfunction


" Delete/Change functions --- {{{
function! DeleteInnestBracket()
    let [s:loc, s:type] = FindClosestPair()
    " We filter out the not-matches
    if s:type == -1
        return
    else
        call CmdBracketType('d','i',s:loc,s:type)
    endif
endfunction

function! DeleteInHere()
    call DeleteInnestBracket()
endfunction

function! ChangeInHere()
    call DeleteInnestBracket()
    startinsert
endfunction

function! DeleteAroundBracket()
    let [s:loc, s:type] = FindClosestPair()
    " We filter out the not-matches
    if s:type == -1
        return
    else
        call CmdBracketType('d','a',s:loc,s:type)
    endif
endfunction

function! DeleteAroundHere()
    call DeleteAroundBracket()
endfunction

function! ChangeAroundHere()
    call DeleteAroundBracket()
    startinsert
endfunction

"}}}

" Yank functions --- {{{
function! YankInnestBracket()
    let [s:loc, s:type] = FindClosestPair()
    " We filter out the not-matches
    if s:type == -1
        return
    else
        call CmdBracketType('y','i',s:loc,s:type)
    endif
endfunction

function! YankInHere()
    call YankInnestBracket()
endfunction

function! YankAroundBracket()
    let [s:loc, s:type] = FindClosestPair()
    " We filter out the not-matches
    if s:type == -1
        return
    else
        call CmdBracketType('y','a',s:loc,s:type)
    endif
endfunction

function! YankAroundHere()
    call YankAroundBracket()
endfunction
"}}}
