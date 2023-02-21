Hyperluminal
============

> "To program is to understand." - Kristen Nygaard

Hyperluminal is a general purpose programming language that provides a clean
modern syntax and set of standard libraries that is both secure and stable for
operating at scales both large and small.

Status
------

> The future is not laid out on a track.
> It is something that we can decide, and to the extent that we do not
> violate any known laws of the universe, we can probably make it work the way
> that we want to.
> - Alan Kay, 1984

There are several experimental parsers written in different languages with different approaches, each with their own branch. None of them are final.

**This is pre-alpha software. Until it hits 1.0 the syntax, semantics, and
everything else is subject to change.**

> Major version zero (0.y.z) is for initial development.
> Anything may change at any time.
> The public API should not be considered stable.
> - [SemVer 2.0](http://semver.org)


Introduction
------------

Want to know a bit about how Hyperluminal works? You've come to the right place!

### Hello, Bob!

> **Akima** : What are you going to call it?<br>
> **Cale**  : I think I'm going to call it... 'Bob'.<br>
> **Akima** : Bob?<br>
> **Cale**  : You don't like Bob?<br>
> **Akima** : You can't call a planet 'Bob'!<br>
> - Titan AE, 2000

Just to get it out of the way, lets write a simple program that take a user's
name on the commandline and greets them:

~~~ruby
write   "Enter your name: "
writeln "Hi, \(readln)!"
~~~

Thats it. Fancy, huh?

The `write` method takes text and writes it to an `IO`, `Stdout` by default.
While `writeln` does the same it also adds a `newline` at the end. As for
`readln` it reads in text from an `IO` and stops reading when it hits a
`newline` character. On the commandline, this is just pressing `<enter>`.

We're also doing some text-interpolation with `\()`. It will run arbitrary
code inside the parens and interpolate the result into the text.

### Objects

> Actually I made up the term "object-oriented",
> and I can tell you I did not have C++ in mind.
> - Alan Kay, 1997

Is Hyperluminal object-oriented? Probably not in the way that you are imagining.

It lacks traditional inheritance.
It doesn't use dynamic dispatch.
It doesn't use a garbage collector.

Actually, it *can* do those things, but it does not by default, nor do the core libraries depend on them.

~~~rebol
name: Struct.new [
  text: Text

  def/fn get: [ @stdin @stdout ] Result [
    @stdout.write "What is your name?"
    self/text: @stdin.read/ln
  ]

  def/fn say: [ @stdout ] Result [
    @stdout.write/ln "Hello, \(self/name)!"
  ]

  def/fn greet none Result [
    get && say
  ]
]

name.greet
~~~

> What is your name? Bob
> Hello, Bob!

If you come from class-based object oriented languages you might notice that we
didn't instantiate the name before using it, but we called `new` on the Struct.

`Struct` is just a namespace.
And `.new` is just telling it you're about to specify a struct.
It isn't being "instantiated" at this point.
However, when `name.greet` is called, `name` is declared and allocated automatically.
This is not garbage collection. It is literally just declaring it on the stack.

The functions are attached to the struct and receive the struct as their first parameter called `self`.
Barewords that look like functions are treated as if they were prefixed by `self.`.

The `@stdin` and `@stdout` in the function signature refer to queues available in the default context.
They don't need to be passed in explicitly, they are taken from the context they are called in as parameters.

The `none` is just a synonym for an empty block `[]`.
For parameters this means there aren't any.

The `Result` return type is saying that the important part isn't what it returned, but if it succeeded.
In many cases this can make error handling nearly invisible.

This is used in `greet` when `get` has the `&&` operator after it.
The `&&` operator will only evaluate its right hand side if the left hand side succeeds.
This way, we don't attempt to make a greeting if the read fails.

Now lets make some code that says "Welcome" instead. We could just copy
and paste the same code above, but using the magic of guises we don't have
to:

~~~elixir
welcomer: Module.new [
  def/fn say: [ @stdout ] Result [
    @stdout.write/ln "Welcome, \(self/name)!"
  ]
]

name: welcomer.guise name
name.greet
~~~

> What is your name? Bob
> Welcome, Bob!

A module is a kind of namespace.
This time it is being used as a `guise` but they can do other things as well.

A `guise` can cause existing functions to use it instead.
This isn't dynamic dispatch, this happens at compile-time.
A `guise` is only applicable in the current context, it doesn't affect even the same value in other contexts.
A `guise`d value can be used anywhere the un`guise`d value could be, unless one of the inherent function signatures its changed.

In practice, it's not ideal to have IO on inherent values. So let's fix that, starting scratch:

~~~elixir
name: Text

greeter: Module.new [
  def/fn get: [ @stdin @stdout ] Result [
    @stdout.write "What is your name?"
    self/text: @stdin.read/ln
  ]

  def/fn say: [ @stdout ] Result [
    @stdout.write/ln "Hello, \(self/name)!"
  ]

  def/fn greet none Result [
    get && say
  ]
]

greet_name: greeter.guise name
name.greet
~~~

Wow, that was easy. The code is nearly identical except for the explicit `guise`!
How do we bring back our welcome? This is where things get neat.

~~~elixir
welcomer: Module.new [
  def/fn say: [ @stdout ] Result [
    @stdout.write/ln "Welcome, \(self/name)!"
  ]
]

name: welcomer.guise greet_name
welcome_name.greet
~~~

Now we have both welcome and greet available simultaneously!

### Literals

> **Fox1** : Say something loud, maybe he'll use it in his examples!<br>
> **Fox2** : Like what? Like "chunky bacon"?
> - why's (poignant) Guide to Ruby, 2004-ish

Text literals can be defined with doublequotes:

~~~ruby
"This is some bit of text."

"Chunky bacon."
~~~

Numeric literals can be created in the usual way:

~~~ruby
42

13.37

47e5

0hDEADBEEF

0b10101010
~~~

Sequence literals are generally defined with parens:

~~~ruby
(1 2 3)
("a" "sequence" "of" "strings")
~~~

There are also Pairs and Triplets defined with a colon:

~~~ruby
1:2

5:4:7
~~~

Pairs combined with Sequences give us Dictionaries:

~~~ruby
(a:4 b:7 c:8)
~~~

Ideas? Complaints?
------------------

- You could Contribute: https://github.com/acook/hyperluminal
- Or you could Submit an issue: https://github.com/acook/hyperluminal
- Or you could even ping me on Twitter: http://twitter.com/anthony_m_cook

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
  3. Commit your changes (`git commit -am 'Add some feature'`)
  4. Push to the branch (`git push origin my-new-feature`)
  5. Create new Pull Request


Who made this anyway?
---------------------

I'm glad you asked!

    Anthony M. Cook 2014-2021
