let s:bk_op = ['[','(','{']

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
    exe 'normal! '. a:verb . a:adverb . s:bk_op[a:type_n]
endfunction
"
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
    startinsert
endfunction

function! ChangeAroundHere()
    call s:TryCmdBracketType('c','a')
    startinsert
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

nnoremap dih  :call DeleteInHere()<CR>
nnoremap dah  :call DeleteAroundHere()<CR>
nnoremap cih  :call ChangeInHere()<CR>
nnoremap cah  :call ChangeAroundHere()<CR>
nnoremap yih  :call YankInHere()<CR>
nnoremap yah  :call YankAroundHere()<CR>
nnoremap vih  :call SelectInHere()<CR>
nnoremap vah  :call SelectAroundHere()<CR>
