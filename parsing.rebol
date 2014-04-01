#!/usr/bin/env r3

REBOL []

example: read/string %../../Mein/hyperluminal/spec/examples/hello_world_block.ftl

print "input:"
print example

t: func [type value][ append/only tokens reduce [type value] ]

lower: charset [#"a" - #"z"]
upper: charset [#"A" - #"Z"]
numer: charset "0123456789"
extra: charset "-_"
blank: charset " "
apost: charset "'"

alpha: union lower upper
wordy: union lower extra

alphanumer: union alpha numer

not-apost: complement apost

sep:      [ some newline ]
delim:    [ some blank ]
apostext: [ 1 apost any not-apost 1 apost ]
word:     [ 3 wordy any wordy ]

block_begin: [ "[" | "do" ]
block_final: [ "]" | "end" ]

program: [
  some [
    [
      copy token word (t 'word token)
      |
      copy token apostext (t 'apostext token)
      |
      copy token block_begin (t 'block_begin token)
    ]

    [
      delim
      |
      any delim
      copy token sep (t 'sep token)
      any delim
    ]
  ]

  opt thru newline
]

tokens: []

match?: parse example program

print either match? "WIN:" "FAIL: did not parse entire input"
print mold tokens
