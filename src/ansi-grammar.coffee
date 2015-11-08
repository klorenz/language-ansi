# {rule} = require 'atom-syntax-tools'

# see http://en.wikipedia.org/wiki/ANSI_escape_code
# http://www.hamiltonlabs.com/userguide/30-AnsiEscapeSequences.htm

# http://graphcomp.com/info/specs/ansi_col.html

# Sets multiple display attribute settings. The following lists standard attributes:
#
# 0	Reset all attributes
# 1	Bright
# 2	Dim
# 4	Underscore
# 5	Blink
# 7	Reverse
# 8	Hidden
#
# 	Foreground Colors
# 30	Black
# 31	Red
# 32	Green
# 33	Yellow
# 34	Blue
# 35	Magenta
# 36	Cyan
# 37	White
#
# 	Background Colors
# 40	Black
# 41	Red
# 42	Green
# 43	Yellow
# 44	Blue
# 45	Magenta
# 46	Cyan

ansiColor = (num) ->
    if num >= 40
      stop =  [ 0, 41, 42, 43, 44, 45, 46, 47, 48, 49 ]
    else
      stop =  [ 0, 31, 32, 33, 34, 35, 36, 37, 38, 39 ]

    {
      start: num
      end: stop
    }

ansiFormats =
  reset:       { start: 0}
  black:       ansiColor(30)
  red:         ansiColor(31)
  green:       ansiColor(32)
  yellow:      ansiColor(33)
  blue:        ansiColor(34)
  magenta:     ansiColor(35)
  cyan:        ansiColor(36)
  white:       ansiColor(37)
  "normal": ansiColor(39)

  bold:   {start: 1, end: [ 0, 2, 21, 22 ]}
  # dim:         {start: 2, end: [ 0, 23 ]}
  italic:      {start: 3, end: [ 0, 23 ]}
  underline:   {start: 4, end: [ 0, 24 ]}
#  blink:       {start: 5, end: [ 0, 24 ]}  # which often is bright bg
  reversed:    {start: 7, end: [ 0, 27 ]}
  "bg-black":  ansiColor(40)
  "bg-red":    ansiColor(41)
  "bg-green":  ansiColor(42)
  "bg-yellow": ansiColor(43)
  "bg-blue":   ansiColor(44)
  "bg-purple": ansiColor(45)
  "bg-cyan":   ansiColor(46)
  "bg-white":  ansiColor(47)
  "bg-normal": ansiColor(49)

#  italic: 2
#  "underline-single": 4
#  "crossed-out":  9

ansiFormatted = (format) ->
  if typeof format == "string"
    name = format
    format = ansiFormats[format]

  name = format.name if format.name
  markup = name

  if name not in ['bold', 'underline', 'italic', 'reset']
    markup = "color.#{name}"

  {start, end, extra} = format

  end = "\\d+" unless end
  if end instanceof Array
     end = "(?:"+end.join("|")+")"

  if start instanceof Array
    start = "(?:"+start.join("|")+")"

  extra = "" unless extra

  return [
    {
      b: "(?<=\\x1B\\[|\\d;)(#{start})(;)"
      # b: "\\G(#{start};)" does not work :(
      c:
        1: "hidden.escape-code.pmc.#{name}"  # pmc = private mode characters
        2: "hidden.escape-code.separator"  #
      N: "markup.#{markup}"
      e: "(?=\\x1B\\[((?!#{end};)\\d{1,2};)*#{end}(;\\d{1,2})*m)"
      p: "#ansiFormat"
    }
    {
      b: "(?<=\\x1B\\[|\\d;)(#{start})(m)"
      # b: "\\G(#{start}m)" does not work :(
      c:
        1: "hidden.escape-code.pmc.#{name}"
        2: "hidden.escape-code.letter.m"

      N: "markup.#{markup}"
      e: "(?=\\x1B\\[((?!#{end};)\\d{1,2};)*#{end}(;\\d{1,2})*m)"
      p: "#ansiFormatted"
    }
  ]

grammar =
  name: "ANSI Terminal Markup"
  scopeName: "text.ansi"
  patterns: [
    "#terminalMarkup"
  ]
  fileTypes: [
    'ansi'
  ]
  # injections:
  #   "text.*": /^(?=.*\x1b\[\d/

  repository:
    terminalMarkup:
      b: /(\x1B\[)(?=\d{1,2}(;\d{1,2})*m)/
      c: { 1: "hidden.escape-code.csi" }   # control sequence indicator

      n: "meta.markup.terminal"

      L: true
      e: /(?=\x1B\[\d{1,2}(;\d{1,2})*m)/

      p: "#ansiFormat"

    ansiFormatted:
      b: /(\x1B\[)(?=\d{1,2}(;\d{1,2})*m)/
      c: { 1: "hidden.escape-code.csi" }   # control sequence indicator

      L: true
      e: /(?=\x1B\[\d{1,2}(;\d{1,2})*m)/

      p: "#ansiFormat"

    ansiFormat: do ->
      formats = []

      for n,v of ansiFormats
        for rule in ansiFormatted(n)
          formats.push rule

      formats

module.exports = grammar
