
" python-markdown2
" https://github.com/trentm/python-markdown2
"
" Beautiful Soup
" http://www.crummy.com/software/BeautifulSoup

let s:save_cpo = &cpo
set cpo&vim

let g:path_to_this = expand("<sfile>:p:h")

function! ParseMarkdownSyntax()

" Set the path directory contains python module(s)
python << EOF
import vim
import site

plugin_dir = vim.eval('g:path_to_this')
site.addsitedir(plugin_dir)
EOF

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
        codecs = ('ascii', 'shift_jis', 'euc_jp', 'utf_8', 'utf_16')
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

    _plugin_dir = None
    _css_path = None
    _temp_file_path = None

    def __init__(self):
        self._plugin_dir = vim.eval('g:path_to_this')
        self._css_path = os.path.join(plugin_dir, 'markdown.css')
        self._temp_file_path = os.path.join(plugin_dir, 'pyrkdown.tmp.html')

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

command! Pyrkdown :call ParseMarkdownSyntax()

let &cpo = s:save_cpo
unlet s:save_cpo

