pyrkdown.vim
============
Overview
----------
pyrkdown.vim is a markdown parse plugin for Vim. While you are editing markdown file, you can preview it on a web browser.  
However, since it is fully written in Python, you are needed to enable Python interface, and it only supports Python 2.x for the moment.

Usage
-------
1. Open markdown syntax file on your buffer.
2. ```:Pyrkdown```
3. Parsed HTML appears on your web browser.
   See how your document looks.

__Modify markdown.css if you don't like it.__

Thanks
--------
These are the libraries used in pyrkdown.vim.  

* python-markdown2  
  https://github.com/trentm/python-markdown2

* Beautiful Soup  
  http://www.crummy.com/software/BeautifulSoup

License
---------
MIT
