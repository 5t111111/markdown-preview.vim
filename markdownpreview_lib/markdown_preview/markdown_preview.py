#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import webbrowser
from bs4 import BeautifulSoup
import chardet
import markdown

class MarkdownPreview(object):

    _source = None
    _template_path = None
    _html_path = None
    _css_path = None

    def __init__(self, source=None, template=None, html=None, css=None):
        self._source = source
        self._template_path = template
        self._css_path = css
        self._html_path = html

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

    def create_html(self):

        src = []

        for line in self._source.split('\n'):
            line = line.rstrip()
            # Do not ignore continuous newlines... 
            if(line == ''):
                src.append(' ')
            else:
                src.append(line)
            src.append('\n')

        content = ''.join(src) 

        uniconv = lambda x: x.decode(chardet.detect(x)['encoding'])

        content = uniconv(content)
        content = markdown.markdown(content, extensions=['extra', 'codehilite', 'nl2br'])

        with open(self._template_path, 'r') as f:
            html = f.read()

        html = html.replace('{{ CSS }}', self._read_css())
        html = html.replace('{{ CONTENT }}', content)

        dirty_html = html
 
        try:
            soup = BeautifulSoup(dirty_html)
            html = soup.prettify()
        except:
            # Failed to prettify a dirty HTML...
            html = dirty_html

        with open(self._html_path, 'w') as f:
            f.write(html.encode('utf_8', errors='replace'))
            if sys.platform[:3] == "win":
                webbrowser.open(self._html_path)
            else:
                webbrowser.open('file://' + self._html_path)

def main():

    argvs = sys.argv
    src_file = argvs[1]
    with open(src_file) as f:
        src = f.read()

    path_to_this = os.path.dirname(os.path.abspath(__file__))
    css = os.path.join(path_to_this, 'preview', 'css', 'markdown.css')
    template = os.path.join(path_to_this, 'preview', 'view', 'index.html')
    html = os.path.join(path_to_this, 'preview', 'index.html')
    mdp = MarkdownPreview(source=src, template=template, html=html, css=css)
    mdp.create_html()

if __name__ == '__main__':
    main()

