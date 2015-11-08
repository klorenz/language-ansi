{makeGrammar} = require 'atom-syntax-tools'
grammar = require './ansi-grammar.coffee'
path = require 'path'

createAnsiGrammar = ->
    grammarFile = path.resolve __dirname, "..", "grammars", "ansi.cson"
    makeGrammar grammar, grammarFile

if require.main is module
  createAnsiGrammar()
  process.stdout.write "Grammar created."

module.exports = {createAnsiGrammar}
