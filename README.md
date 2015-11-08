# Language ANSI

Highlight ANSI Markups in Terminal Output.

Origin of the code for this package is [build-output-grammar.coffe]( https://github.com/klorenz/atom-build-systems/blob/master/lib/build-output-grammar.coffee).  There
the ANSI markup language was embedded into build output Grammar, which also highlighted other
things like python errors.

This is a revised version of the grammar orienting more on [TextMate Language Grammar Naming Conventions](http://manual.macromates.com/en/language_grammars#naming_conventions).  It also
provides an injection grammar, which will apply in all _text.*_ grammars.

# Development

Grammar is generated from `src/ansi-grammar.coffee`.  So if you would like to contribute,
please edit this file and then run
```shell
  $ coffee src/ansi.coffee
    Grammar created.
```
