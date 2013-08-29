" python-markdown2
" https://github.com/trentm/python-markdown2
"
" Beautiful Soup
" http://www.crummy.com/software/BeautifulSoup

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

class EncodingUtils(object):

    @classmethod
    def guess_encoding(cls, data):
        """
        Guess the encoding of the data sepecified 
        """
        codecs = ('ascii', 'shift_jis', 'euc_jp', 'utf_8')
        f = lambda data, enc: data.decode(enc) and enc
    
        for codec in codecs:
            try:
                f(data, codec)
                return codec
            except:
                pass;
    
        return None
    
    @classmethod
    def convert_encoding(cls, data, codec_from, codec_to='utf_8'):
        """
        Convert the encoding of the data to the specifed encoding
        """
        udata = data.decode(codec_from)
        if (isinstance(udata, unicode)):
            return udata.encode(codec_to, errors='ignore') 

class MarkDownParse(object):

    _css_path = None
    _temp_file_path = None

    def __init__(self):
        additional_file_path = vim.eval('s:additional_file_path')
        self._css_path = os.path.join(additional_file_path, 'markdown.css')
        self._temp_file_path = os.path.join(additional_file_path, 'pyrkdown.tmp.html')

    def _read_css(self):
        with open(self._css_path, 'r') as f:
            return f.read()
    
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
    
        src = ''.join(src) 
        
        enc = EncodingUtils.guess_encoding(src);
        u_src = EncodingUtils.convert_encoding(src, enc)
    
        dirty_html = ''.join([self._make_header(), markdown2.markdown(u_src), self._make_footer()])
        
        try:
            soup = BeautifulSoup(dirty_html)
            pretty_html = soup.prettify()
        except:
            # Failed to prettify a dirty HTML...
            pretty_html = dirty_html
        
        with open(self._temp_file_path, 'w') as f:
            f.write(pretty_html.encode('utf_8'))
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

