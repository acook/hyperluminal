Hyperluminal
============

> The future is not laid out on a track.
> It is something that we can decide, and to the extent that we do not
> violate any known laws of the universe, we can probably make it work the way
> that we want to.
> - Alan Kay, 1984

Hyperluminal is a general purpose programming language that provides a clean
modern syntax and set of standard libraries that is both secure and stable for
operating at scale. It is designed around rapid development, ease of
maintenance, and expression of intent.

**This is pre-alpha software. Until it hits 1.0 the syntax, semantics, and
everything else is subject to change.**

> Major version zero (0.y.z) is for initial development.
> Anything may change at any time.
> The public API should not be considered stable.
> - [SemVer 2.0](http://semver.org)


Introduction
------------

Want to know a bit about how Hyperluminal works? You've come ot the right place!

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

The most essential components of Hyperluminal are its Objects. Objects have a
set of slots that contain Methods (public by default) and Attributes (always
private).

There's some syntactic sugar around defining Objects using the `obj` builtin, as
well as other builtin helpers for defining Methods and Attributes:

~~~ruby
obj Greeter do
  attribute name:Text

  def get_name do
    write "What is your name? "
    self.name: readln
  end

  def say_greeting do
    writeln "Hello, \(self.name)!"
  end

  def greet do
    get_name
    say_greeting
  end
end

Greeter.greet
~~~

> What is your name? Bob<br>
> Hello, Bob!

If you come from class-based object oriented languages you might notice that we
didn't instantiate the Greeter before using it. Hyperluminal doesn't need to
instantiate objects before using them, they're "live" as soon as they are
created. But don't worry, we can still do all the fancy things you're used to!

Now lets make another Object that says "Welcome" instead. We could just copy
and paste the same code above, but using the magic of inheritance we don't have
to:

~~~ruby
obj Welcomer Greeter do
  def say_greeting do
    writeln "Welcome, \(self.name)!"
  end
end

Welcomer.greet
~~~

> What is your name? Bob<br>
> Welcome, Bob!

The second parameter passed to the "obj" helper sets the "archetype" slot, this
tells Hyperluminal to delegate any unknown methods to the Archetype, but uses
the current Object's Attributes.

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

    Anthony M. Cook 2014
