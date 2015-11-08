
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


checkFormat = (grammar, format) ->
  lines = tokenizeLines grammar, '\x1b[1mtext\x1b[0m'
  expect(lines[0][2]).toEqual value: 'text',     scopes: ['text.ansi', 'meta.ansi-formatted.ansi', "terminal.ansi.#{format}.ansi" ]

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

    expect(lines[0][0]).toEqual value: '\x1b[', scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]
    expect(lines[0][1]).toEqual value: '32m',   scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]
    expect(lines[0][2]).toEqual value: '✓',     scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'terminal.ansi.green.ansi' ]
    expect(lines[0][3]).toEqual value: '\x1b[', scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]
    expect(lines[0][4]).toEqual value: '39m',   scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]

  it "tokenizes intensive formatting", ->
    checkFormat "intensive", grammar

  fit "tokenizes nested escape codes with only one reset code", ->
    line = '\x1b[1m\x1b[31mSome Error\x1b[0m'

    lines = tokenizeLines grammar, line

    expect(lines[0][0]).toEqual value: '\x1b[', scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]
    expect(lines[0][1]).toEqual value: '1m',   scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]
    expect(lines[0][2]).toEqual value: '\x1b[', scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'terminal.ansi.intensive.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]
    expect(lines[0][3]).toEqual value: '31m',   scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'terminal.ansi.intensive.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]
    expect(lines[0][4]).toEqual value: 'Some Error', scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'terminal.ansi.intensive.ansi', 'terminal.ansi.red.ansi' ]
    expect(lines[0][5]).toEqual value: '\x1b[', scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]
    expect(lines[0][6]).toEqual value: '0m',   scopes: ['text.ansi', 'meta.ansi-formatted.ansi', 'hidden.ansi-escape-code.ansi' ]
