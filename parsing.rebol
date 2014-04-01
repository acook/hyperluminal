#!/usr/bin/env r3

REBOL []

example: read/string %../../Mein/hyperluminal/spec/examples/hello_world.ftl

print "input:"
print example

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

delim: [ some blank ]
apostext: [ 1 apost any not-apost 1 apost ]
word: [ 3 wordy any wordy ]

t: func [type value][ append/only tokens reduce [type value] ]

program: [
  some [
    [
      copy token word (t 'word token)
      |
      copy token apostext (t 'apostext token)
    ]

    delim
  ]

  opt thru newline
]

tokens: []

match?: parse example program

print "output:"
print either match? "succeeded" "did not parse entire input"
print mold tokens
