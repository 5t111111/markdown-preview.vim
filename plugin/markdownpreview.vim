if exists('g:loaded_markdownpreview')
  finish
endif
let g:loaded_markdownpreview = 1

command! Md :call markdownpreview#MarkdownPreview()
