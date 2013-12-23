let s:save_cpo = &cpo
set cpo&vim

function! s:LoadPythonModulePath()
    for l:i in split(globpath(&runtimepath, "markdownpreview_lib"), '\n')
        let s:python_module_path = fnamemodify(l:i, ":p")
    endfor
    python << EOF
import vim
import site

site.addsitedir(vim.eval('s:python_module_path'))
EOF
endfunction

function! s:SetAdditionalFilePath()
    for l:i in split(globpath(&runtimepath, "markdownpreview_files"), '\n')
        let s:additional_file_path = fnamemodify(l:i, ":p")
    endfor
endfunction

function! markdownpreview#MarkdownPreview()

    call s:LoadPythonModulePath()
    call s:SetAdditionalFilePath()

    python << EOF
import os
from markdown_preview.markdown_preview import MarkdownPreview

additional_file_path = vim.eval('s:additional_file_path')
src = '\n'.join(vim.current.buffer[:])
css = os.path.join(additional_file_path, 'preview', 'css', 'markdown.css')
template = os.path.join(additional_file_path, 'preview', 'view', 'index.html')
html = os.path.join(additional_file_path, 'preview', 'index.html')
mdp = MarkdownPreview(source=src, template=template, html=html, css=css)
mdp.create_html()
EOF
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

