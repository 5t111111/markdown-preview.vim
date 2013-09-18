if exists('g:loaded_pyrkdown')
  finish
endif
let g:loaded_pyrkdown = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:LoadPythonModulePath()
    for l:i in split(globpath(&runtimepath, "plugin/pyrkdown_lib"), '\n')
        let s:python_module_path = fnamemodify(l:i, ":p")
    endfor
    python << EOF
import vim
import site

site.addsitedir(vim.eval('s:python_module_path'))
EOF
endfunction

function! s:SetAdditionalFilePath()
    for l:i in split(globpath(&runtimepath, "plugin/pyrkdown_files"), '\n')
        let s:additional_file_path = fnamemodify(l:i, ":p")
    endfor
endfunction

function! g:Pyrkdown()

    call s:LoadPythonModulePath()
    call s:SetAdditionalFilePath()

    python << EOF
import os
import webbrowser
from bs4 import BeautifulSoup
import markdown2
import chardet

class MarkDownParse(object):

    _css_path = None
    _temp_file_path = None

    def __init__(self):
        additional_file_path = vim.eval('s:additional_file_path')
        self._css_path = os.path.join(additional_file_path, 'markdown.css')
        self._temp_file_path = os.path.join(additional_file_path, 'pyrkdown.tmp.html')

    def _read_css(self):
        with open(self._css_path, 'r') as f:
            css = ''
            uniconv = lambda x: x.decode(chardet.detect(x)['encoding'])
            line = f.readline()
            while line:
                line = uniconv(line)
                css = ''.join([css, line])
                line = f.readline()

            return css.encode('utf_8', errors='replace')

    def _make_header(self):
        html = ''.join(["""
<!DOCTYPE html>
<html lang=\"ja\">
<head>
<meta charset=\"utf8\">
<title>Pyrkdown</title>
</head>
<style>
""", self._read_css(), """
</style><body>
"""])
        return html

    def _make_footer(self):
        html = '</body></html>'
        return html

    def create_html(self):
        lines = vim.current.buffer[:]
        src = []

        for line in lines:
            # Do not ignore continuous newlines... 
            if(line == ''):
                src.append(' ')
            else:
                src.append(line)
            src.append('\n')

        content = ''.join(src) 

        uniconv = lambda x: x.decode(chardet.detect(x)['encoding'])

        content = uniconv(content)
        content = markdown2.markdown(content)
        header = self._make_header()
        header = uniconv(header)
        footer = self._make_footer()
        footer = uniconv(footer)

        html = ''.join([header, content, footer])
        dirty_html = html
 
        try:
            soup = BeautifulSoup(dirty_html)
            html = soup.prettify()
        except:
            # Failed to prettify a dirty HTML...
            html = dirty_html

        with open(self._temp_file_path, 'w') as f:
            f.write(html.encode('utf_8', errors='replace'))
            if sys.platform[:3] == "win":
                webbrowser.open(self._temp_file_path)
            else:
                webbrowser.open('file://' + self._temp_file_path)

mdp = MarkDownParse()
mdp.create_html()
EOF
endfunction

command! Pyrkdown :call g:Pyrkdown()

let &cpo = s:save_cpo
unlet s:save_cpo

