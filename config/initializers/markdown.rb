# sample code in Redcarpet's repo
require "pygments"
PYGMENTS_ALLOW_LANGUAGES = %w(cucumber Gherkin gherkin abap ada ada95ada2005 ahk antlr-as antlr-actionscript antlr-cpp antlr-csharp antlr-c# 
antlr-java antlr-objc antlr-perl antlr-python antlr-ruby antlr-rb antlr apacheconf aconf apache applescript as actionscript as3 
actionscript3 aspx-cs aspx-vb asy asymptote basemake bash sh ksh bat bbcode befunge blitzmax bmax boo brainfuck bf c-objdump c 
cfm cfs cheetah spitfire clojure clj cmake coffee-script coffeescript common-lisp cl console control cpp c++ cpp-objdump c++-objdumb 
cxx-objdump csharp c# css+django css+jinja css+erb css+ruby css+genshitext css+genshi css+mako css+myghty css+php css+smarty css 
cython pyx d-objdump d delphi pas pascal objectpascal diff udiff django jinja dpatch duel Duel Engine Duel View JBST jbst JsonML+BST 
dylan erb erl erlang evoque factor felix flx fortran gas genshi kid xml+genshi xml+kid genshitext glsl gnuplot go gooddata-cl groff 
nroff man haml HAML haskell hs html+cheetah html+spitfire html+django html+jinja html+evoque html+genshi html+kid html+mako html+myghty 
html+php html+smarty html+velocity html hx haXe hybris hy ini cfg io ioke ik irc jade JADE java js+cheetah javascript+cheetah 
js+spitfire javascript+spitfire js+django javascript+django js+jinja javascript+jinja js+erb javascript+erb js+ruby javascript+ruby 
js+genshitext js+genshi javascript+genshitext javascript+genshi js+mako javascript+mako js+myghty javascript+myghty js+php javascript+php 
js+smarty javascript+smarty js javascript jsp lhs literate-haskell lighty lighttpd llvm logtalk lua make makefile mf bsdmake mako maql 
mason matlab octave matlabsession minid modelica modula2 m2 moocode mupad mxml myghty mysql nasm newspeak nginx numpy objdump objective-c 
objectivec obj-c objc objective-j objectivej obj-j objj ocaml ooc perl pl php php3 php4 php5 postscript pot po pov prolog properties 
protobuf py3tb pycon pytb python py python3 py3 ragel-c ragel-cpp ragel-d ragel-em ragel-java ragel-objc ragel-ruby ragel-rb ragel raw 
rb ruby duby rbcon irb rconsole rout rebol redcode rhtml html+erb html+ruby rst rest restructuredtext sass SASS scala scaml SCAML 
scheme scm scss smalltalk squeak smarty sourceslist sources.list splus s r sql sqlite3 squidconf squid.conf squid ssp tcl tcsh csh 
tex latex text trac-wiki moin v vala vapi vb.net vbnet velocity vim xml+cheetah xml+spitfire xml+django xml+jinja xml+erb xml+ruby 
xml+evoque xml+mako xml+myghty xml+php xml+smarty xml+velocity xml xquery xqy xslt yaml)

class HTMLwithSyntaxHighlight < Redcarpet::Render::HTML
  def block_code(code, language)
    language = 'text' if not PYGMENTS_ALLOW_LANGUAGES.include?(language)
    Pygments.highlight(code, :lexer => language, :formatter => 'html', :options => {:encoding => 'utf-8'})
  end
end

html_renderer = HTMLwithSyntaxHighlight.new({
  :filter_html => true   # filter out html tags
})

$markdown = Redcarpet::Markdown.new(html_renderer, {
  :autolink => true,
  :fenced_code_blocks => true
})
