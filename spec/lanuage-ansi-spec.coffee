
text1 = '''
      \x1b[32m✓\x1b[39m tests/test_demo.py::test_passes 0.193s \x1b[32m(PASS)\x1b[39m
      \x1b[33m?\x1b[39m tests/test_demo.py::test_is_skipped 0.001s \x1b[33m(SKIP)\x1b[39m
\x1b[0m__________________________________ test_fails __________________________________\x1b[0m\x1b[0m
\x1b[0m\x1b[0m
\x1b[1m    def test_fails():\x1b[0m\x1b[0m\x1b[0m
\x1b[1m>       assert False, "This fails :)"\x1b[0m\x1b[0m\x1b[0m
\x1b[1m\x1b[31mE       AssertionError: This fails :)\x1b[0m\x1b[0m\x1b[0m
\x1b[1m\x1b[31mE       assert False\\x1b0m\x1b[0m\x1b[0m
\x1b[0m\x1b[0m
tests/test_demo.py:5: AssertionError
      \x1b[31m✗\x1b[39m tests/test_demo.py::test_fails 0.009s \x1b[31m(FAIL)\x1b[39m
      \x1b[31m✗\x1b[39m tests/test_demo2.py::test_fails 0.005s \x1b[31m(FAIL)\x1b[39m
'''
logCharCodes = (line) ->
  for c,i in line
    console.log "i", i, "c", c, line.charCodeAt(i)

logString = (line) ->
  console.log line.replace(/\x1b/g, '[ESC]')

tokenizeLines = (grammar, args...) ->
  lines = grammar.tokenizeLines args...
  console.log "lines", lines
  return lines


checkFormat = (grammar, code, format) ->
  lines = tokenizeLines grammar,"\x1b[#{code}mtext\x1b[0m"
  logString lines[0][3].value
  expect(lines[0][3]).toEqual value: 'text',     scopes: ['text.ansi', 'meta.markup.terminal.ansi', "markup.#{format}.ansi" ]

describe "ANSI Formatted grammar", ->
  grammar = null

  beforeEach ->
    # travis does not like this
    {createAnsiGrammar} = require '../src/ansi.coffee'
    createAnsiGrammar()

    waitsForPromise ->
      atom.packages.activatePackage("language-ansi")

    runs ->
      grammar = atom.grammars.grammarForScopeName("text.ansi")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "text.ansi"

  it "tokenizes simple colors", ->
    lines = tokenizeLines grammar, '\x1b[32m✓\x1b[39m'

    expect(lines[0][0]).toEqual value: '\x1b[', scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.csi.ansi' ]
    expect(lines[0][1]).toEqual value: '32',    scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.pmc.green.ansi' ]
    expect(lines[0][2]).toEqual value: 'm',     scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.letter.m.ansi' ]
    expect(lines[0][3]).toEqual value: '✓',     scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'markup.color.green.ansi' ]
    expect(lines[0][4]).toEqual value: '\x1b[', scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.csi.ansi' ]
    expect(lines[0][5]).toEqual value: '39',    scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.pmc.normal.ansi' ]
    expect(lines[0][6]).toEqual value: 'm',     scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.letter.m.ansi' ]

  it "tokenizes bold formatting", ->
    checkFormat grammar, 1, "bold"

  it "tokenizes italic formatting", ->
    checkFormat grammar, 3, "italic"

  it "tokenizes underline formatting", ->
    checkFormat grammar, 4, "underline"


  it "tokenizes red formatting", ->
    checkFormat grammar, 31, "color.red"

  it "tokenizes green formatting", ->
    checkFormat grammar, 32, "color.green"


  it "tokenizes nested escape codes with only one reset code", ->
    line = '\x1b[1m\x1b[31mSome Error\x1b[0m'

    lines = tokenizeLines grammar, line

    expect(lines[0][0]).toEqual value: '\x1b[',      scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.csi.ansi' ]
    expect(lines[0][1]).toEqual value: '1',          scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.pmc.bold.ansi' ]
    expect(lines[0][2]).toEqual value: 'm',          scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.letter.m.ansi' ]
    expect(lines[0][3]).toEqual value: '\x1b[',      scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'markup.bold.ansi', 'hidden.escape-code.csi.ansi' ]
    expect(lines[0][4]).toEqual value: '31',         scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'markup.bold.ansi', 'hidden.escape-code.pmc.red.ansi' ]
    expect(lines[0][5]).toEqual value: 'm',          scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'markup.bold.ansi', 'hidden.escape-code.letter.m.ansi' ]
    expect(lines[0][6]).toEqual value: 'Some Error', scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'markup.bold.ansi', 'markup.color.red.ansi' ]
    expect(lines[0][7]).toEqual value: '\x1b[',      scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.csi.ansi' ]
    expect(lines[0][8]).toEqual value: '0',          scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.pmc.reset.ansi' ]
    expect(lines[0][9]).toEqual value: 'm',          scopes: ['text.ansi', 'meta.markup.terminal.ansi', 'hidden.escape-code.letter.m.ansi' ]
