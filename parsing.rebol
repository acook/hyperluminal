#!/usr/bin/env r3

REBOL []

example: read/string %../../Mein/hyperluminal/examples/test.ftl

print "input:"
print example

t: func [type value][ append/only tokens reduce [type value] ]

lower: charset [#"a" - #"z"]
upper: charset [#"A" - #"Z"]
numer: charset "0123456789"
extra: charset "-_"
blank: charset " "
apost: charset "'"
dquot: charset {"}

alpha: union lower upper
wordy: union lower extra

alphanumer: union alpha numer

not-apost: complement apost
not-dquot: complement dquot

sep:      [ some newline ]
delim:    [ some blank ]
apostext: [ 1 apost any not-apost 1 apost ]
dquotext: [ 1 dquot any not-dquot 1 dquot ]
word:     [ 3 wordy any wordy ]
integer:  [ some numer ]

block_begin: [ "[" | "do" ]
block_final: [ "]" | "od" ]
list_begin: [ "(" ]
list_final: [ ")" ]

program: [
  some [
    [
      copy token block_final (t 'block_final token)
      |
      copy token block_begin (t 'block_begin token)
      |
      copy token list_final (t 'list_final token)
      |
      copy token list_begin (t 'list_begin token)
      |
      copy token word (t 'word token)
      |
      copy token apostext (t 'apostext token)
      |
      copy token dquotext (t 'dquotext token)
      |
      copy token integer (t 'integer token)
    ]

    [
      any delim
      copy token sep (t 'sep token)
      any delim
      |
      some delim
    ]
  ]

  opt thru newline
]

tokens: []

match?: parse example program

print either match? "WIN:" "FAIL: did not parse entire input"
print mold tokens
