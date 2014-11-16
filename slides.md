# make and redo for automation

by Scott Vokes ([@silentbicycle][sb])

[sb]: https://github.com/silentbicycle/


# Not just build systems

<!-- While these tools are typically described as build systems, they're
more general than that. Makefiles describe a set of targets, some of
which may produce input for other targets, and execute them in a
dependency-based order. -->


# make(1) -- 1976

<!-- make is a fairly old tool, dating back to the early days of Unix.

Have any of you ever had mysterious things happen because something was
partially regenerated, but some stale cached parts caused results that
didn't line up with the current state of things? make was originally
written to automate away that kind of problem. -->


# Idempotency

<!-- Just like configuration management tools, Make expects the targets
to be idempotent -- skipping a target because its output is up to date
and its input hasn't changed should lead to a functionally identical
result as redundantly regenerating the target.

That way, if only a small portion of the tasks need to be run, then
running the main target can be completed much sooner.

Unlike ansible (for example), which will potentially run through a whole
playbook of tasks, noting individually that they are complete, make is
operating on a tree of dependencies, and if a target is up to date, it
assumes all tasks contained within it can be skipped. -->


# Goal-Directed Programming

<!-- Ultimately, make is a tool for goal-directed programming. Rather
than telling it a full series of operations, you describe how to perform
individual tasks (by shell commands), what depends on what, and let it
figure out the best order to execute them on demand. -->


# Unix-Flavored Prolog

<!-- It a way, it's like a Unix-flavored Prolog - you try to specify
your problem domain, but leave most of the overall control flow to it
built-in dependency search.

And just like Prolog, if you try to write Makefiles like a typical
scripting language, you will likely end up with an awkward result. -->


# Rule format

    target: deps list
    <TAB>program -o target --flag deps list

<!-- Yes, the literal tab is required. More on that later. -->


# Basic use

    make target

<!-- To run a target in a make file, use `make target`.
If the target is omitted, the first rule will run. -->


# Suffix rules

    .html.md:
            markdown $< > $@

<!-- You don't have to specify every individual target, though.
Patterns can be generalized to file extensions, and it is often
practical to do so.-->


# Pattern rules and variables

    %.png: %.dot
	        dot -Tpng -o $@ $<
        

<!-- There are a couple forms for abstracting over individual filenames. -->


# Variables

    ${PROJECT}: ${OBJS}
            ${CC} -o $@ ${LDFLAGS} $^

<!-- Also, variables can be expanded from the shell environment, or defined
in the makefile itself. -->


# \$@ \$< \$? \$^ \$+ \$*

    $@ target
    $* stem (file w/out ext.) in % rules
    $< first prereq
    $? all NEWER prereqs
    $^ all prereqs, ONCE
    $+ all prereqs, with DUPLICATES

<!-- There are also several built-in variables. -->


# Good tutorial: 'PMake'

<!-- My favorite in-depth tutorial for make is the 'PMake' one (linked
below). PMake became BSD make; it was originally named "PMake" because
its novel feature was parallelism, building with multiple processes.

While GNU make is more common, I find BSD make to have a better defined
set of features, and the tutorial covers those well. "Make: The Good
Parts", if you will. Once you learn to use BSD make effectively, using
GNU make isn't much different, but GNU make has a lot of extra features
that are probably better handled by other tools. -->


# Uses for Automation

<!-- I've tended to lean a lot on make for automation. Not just in a
programming context, where I can use it for rebuilding, running tests,
or generating benchmark data. I've also used it for generating static
web pages off of plaintext markup, generating diagrams for presentations
from graphviz dot code, and just saving keystrokes.

If you are running a series of commands to produce some kind of output
file, you might benefit from using make. If it generates several
files along the way, you might be able to resume from a step
partway along and iterate faster than starting from scratch every
time.

This presentation is generated from markdown slides, using make to
drive pandoc creating reveal.js presentations out of markdown slides.
Granted, pandoc is doing the majority of the work, but being able to
just type "make" and have it complete in a few msec if there isn't
any new work to do is a nice workflow. -->


# Advantages


# make is everywhere

<!-- make is likely to be installed on almost every Un*x system.
If you prefer to use something else, you can still use it
to bootstrap your preferred toolchain.

In the absolute worst case, you can still install something minimal like
[ake](https://github.com/darius/ake), a mini-make implemented in awk,
which is required to be available. -->


# Fairly terse

    out: deps
        gen out deps

<!-- While generated Makefiles can be quite verbose or complex, ones
used for automation don't need to be. -->


# Low startup costs

<!-- Unlike rake and similar systems for other languages/platforms, make
is pretty lightweight. Automation via a Makefile should add very little
overhead (perhaps a few milliseconds) compared to running the commands
directly. (This is less true for compiling large projects with complex
dependency trees, but we're mainly talking about automation here.)

Because rake has to load Ruby and related infrastructure, it can still
take 300 msec or so to run a no-op rake task. That may not seem like
much time, but it can be enough to make integration with editors feel
awkward, and can be mentally jarring in the heart of a develop/test
workflow. make is typically running in under 10 msec, giving much less
mental friction. -->


# Decent support for parallelism

    make -j8

<!-- As long as you've accurately expressed dependencies, make can
schedule tasks that aren't going to directly impact each other in
parallel, making better use of multiple processor cores.

Like xargs(1), this is often an easy way to add parallelism when
processing lots of files. -->


# Not language / platform specific

ant, maven, lein, cabal, ...

<!-- Most of the make spin-offs I've seen have been more focused on a
particular platform or language. While this means they're usually better
at things like detecting dependencies, it also means they're less
effective for automating general tasks. -->


# Disadvantages

<!-- All that said, there are some flaws in make that aren't likely to
change any time soon. Many of them are details of the popular
implementations, rather than issues in the core model, and lead to
less trouble if they're known in advance. -->


# The Closed World Assumption

<!-- The most significant disadvantage with make is that it needs
the dependency information you give it to be accurate. If it has
gaps in its knowledge, those gaps may distort execution by failing
to update something after its input has changed, allowing two
concurrent processes to update a target at the same time, or
otherwise leading to inconsistent state.

Often, this is from not indicating that a file depends on the Makefile
itself (which may have some platform-specific configuration), leading to
stale configuration data causing other problems. -->


# "Recursive make considered harmful"

<!-- This gets worse when sub-instances of make are being run nested
during the make execution, because the nested make processes will
probably only communicate with the parent make by whether a target
file exists or not. -->


# Awkwardness with nested projects

<!-- ...and if you try to drive everything from a single top-level
make file, it often leads to cumbersome, deeply nested paths.

Again, this is less an issue with automation than while building
software projects, but it is probably make's most significant
weakness. -->


# Variants and portability issues

BSD make, GNU make, ...

<!-- Also, there are incompatibilities between the different make
implementations. My personal preference is to use the subset common to
all of them (which is fairly close to BSD make) and only add few GNU
make-isms, but however you use them, this is something to keep in mind.
-->


# Extensions that don't really fit the model

<!-- Some make implementations, particularly platform-specific ones like
rake, have extensions that clash with the underlying model of
computation. For example, you can run rake commands with file arguments:

    rake build:pattern[filepattern]

but the argument(s) used when building those targets aren't typically
preserved in a way that informs detection of out-of-date dependencies.
If those configuration options were defined in a file (possibly
generated), and that file was marked as an explicit dependency,
then they could be handled accurately. -->


# Historical baggage

"...a few weeks later I had a user population of about a dozen..."

<!-- The tab literal required in Makefiles could have been relaxed to
*any* leading whitespace (or whatever), but by the time the problems
with that design were understood, it would have been a major interface
change.

"Why the tab in column 1? Yacc was new, Lex was brand new. I hadn't
tried either, so I figured this would be a good excuse to learn. After
getting myself snarled up with my first stab at Lex, I just did
something simple with the pattern newline-tab. It worked, it stayed. And
then a few weeks later I had a user population of about a dozen, most of
them friends, and I didn't want to screw up my embedded base. The rest,
sadly, is history." - Stuart Feldman, author of make
   (quote from http://www.catb.org/esr/writings/taoup/html/ch15s04.html)
-->


# Obscure built-in behavor

<!-- Make has a lot of built-in rules. (You can typically print them
somehow; for GNU make, use `make -p`.) The installated version on this
computer includes rules for not just C and C++, but also TeX / LaTeX,
RCS, and some other things. Rather than having a clean slate and an
explicit ipmort of some sort (e.g., "load common rules for C"), it
assumes familiarity with implicit variables like ${LDFLAGS}.

Having something almost-work because of built-in rules used instead of
rules I've explicitly provided has led to some particularly confusing
issues. -->


# Poor culture of re-use

<!-- Also, make has just enough built-in behavior to take the pressure
off of giving it good support for packing & sharing target rules for
common tasks. Instead of working off a shared base, a lot of projects'
makefiles seem to end up with some copy-paste-modify incantations and
generated code that isn't relevant.

(The best counterexample to this is the make infrastructure included
with OpenBSD. It's the exception that proves the rule, though.) -->


#

![Die Autotools](images/die_autotools.jpg)

<!-- Instead of a good package system for make, we got The Autotools.

*we have a sad feeling for a moment, and then it passes*

-->


# redo

<!-- There's been several make-inspired tools since the 70s. One I've
seen that seems to improve most of make's gotchas (while keeping its
good aspects) is redo. -->


# djb

"Rebuilding target files when source files have changed"

<!-- Daniel J. Bernstein, author of qmail and daemontools (among other
things) posted some notes on his site, gathered under the heading
"Rebuilding target files when source files have changed". These
described some common problems with make, and design changes that
improve them. -->


# Top-down, like make

<!-- Fundamentally, redo has the same model as make -- you specify
targets, what they depend on, and how to rebuild them once their
dependencies are up to date. -->


# Atomic targets

<!-- The single biggest change in redo is that targets are atomic.
Instead of replacing targets while building, targets are built to temp
files, and moved over once complete. This means that if the build is
interrupted (crashing, power outage, etc.) there won't be a file with a
newer timestamp and corrupt contents to mess up everything that depends
on it. -->


# default.do, default.o.do, ...

<!-- The big stylistic difference is that, instead of having one large
Makefile at the root of a directory tree, there are multiple .do files
throughout. These scripts are all scoped to their own directory, so
referring to targets in sub-sub-directories doesn't lead to long
relative paths - things compose more cleanly. Also, targets depend on
the .do file that built them; changing configuration options in a .do
file impacts that part of the tree, not everything using a single
Makefile. -->


# Essential use

    redo
    redo-ifchange
    redo-ifcreate

<!-- Instead of using their own shell-script-like language, these .do
scripts are just normal shell scripts. The trick is that they can call
into `redo-ifchange`, to inform the running `redo` process about
dependency information.

The first time a dependency is mentioned, it's recorded. If it already
exists, it's a source dependency, otherwise it's another target to
build. This dependency information can be derived from the recently
built target, which often makes it simpler to get very accurate
dependency info.

Similarly, `redo-ifcreate` is based on whether a file exists, not if it
has changed. Other hooks such as `redo-hash` (comparing content) could
use the same underlying mechanism.

(Because of how redo-ifchange works, they can also be written in any
#!-able language.) -->


# redo

<!-- So, to use redo, `redo` is called, with an optional target. If no
target is given, redo defaults to `all`.

It looks for a .do file for the target (e.g. `all.do`). If that is
found, it's executed, otherwise it falls back on `default.do`.
For targets with an extension, like `foo.o`, it will try `foo.do`,
then `default.o.do` (an extension-specific script), then `default.do`. -->


#

+ $1 target
+ $2 basename of the target w/out extension, if any
+ $3 tmp file for target being created

<!-- These scripts are always called with three arguments.
they are seemingly just as arbitrary as $@ $^ etc. in make, but
those three are all that are needed.

default.do can use a switch-case statement on $1
to handle several targets in the same .do file, if desired. -->


# ./compile -o $3 $2.c

<!-- a typical .do file for c object files would look like this:

    redo-ifchange compile
    ./compile -o $3 $2.c
    
djb suggests having `compile` itself be a script generated by redo,
which contains all the compilation options -- it just takes a source
file and an output name. (this same pattern would also work nicely with
make.) that way, all platform-specific config is handled in one spot,
and will be invalidated / rebuilt if the options are changed. -->


# Or, save stdout

<!-- Instead of using $3 for the temp output file, redo will also save
any content sent to stdout. (I'm not entirely convinced that this is
a good default, but it hasn't been a problem yet.) -->


# redo-ifchange a b c

<!-- The other benefit with redo-ifchange is that all the targets
depended on by the same redo-ifchange can be scheduled to be rebuilt
in parallel. -->


# Where do I get it?

+ https://github.com/apenwarr/redo

<!-- Unlike make, which is distributed with Un*x, you need to download
redo. djb hasn't released his implementation, but Avery Pennarun has a
GPL'd Python [implementation][redo] based on djb's design. His redo repo
also includes a public-domain implementation as a < 200 line shell
script, the redo counterpart to Darius Bacon's ake script. It doesn't
support incremental rebuilding, but is otherwise compatible with full
redo. -->


# Closing - Not just build tools

<!-- redo improves on several aspects of make, but both are very useful
tools. I prefer redo as a build system for programming projects
(particularly as projects become nested), but most of the reasons why
matter far less when using make for other workflow automation, and it's
available almost everywhere. -->


# Building these slides (make)

    $ cat Makefile
    TEMPLATE= template.revealjs

    PANDOC= pandoc --section-divs -t html5 \
        -s --template ${TEMPLATE}

    slides.html: slides.md ${TEMPLATE} Makefile
	        ${PANDOC} -o $@ slides.md


# Building these slides (redo)

    $ cat all.do
    redo-ifchange slides.html

    $ cat default.html.do 
    TEMPLATE="template.revealjs"
    PANDOC="pandoc --section-divs -t html5 \
        -s --template ${TEMPLATE}"
    ${PANDOC} -o $3 $2.md


# Resources

+ ["Make - A Program for Maintaining Computer Programs"](http://sai.syr.edu/~chapin/cis657/make.pdf)
<!-- The original make(1) paper -->

+ ["Rebuilding target files when source files have changed"](http://cr.yp.to/redo.html)
<!-- The original redo design notes -->

+ [PMake](https://www.freebsd.org/doc/en_US.ISO8859-1/books/pmake/) - excellent make tutorial

+ [mk](http://plan9.bell-labs.com/sys/doc/mk.html) - recommended practices
<!-- Notes on plan9's mk, which is very similar to make, and has much
commentary on good practices to follow when using make-like tools. -->

+ ["Purely Top-Down Software Rebuilding"](http://grosskurth.ca/papers/mmath-thesis.pdf)
<!-- A master's thesis on make and redo. -->

+ apenwarr's [redo](https://github.com/apenwarr/redo) implementation

+ _Time Management for System Administrators_
<!-- A book which has a section on using make specifically for automation. -->

+ ["A quick introduction to redo"](http://pozorvlak.livejournal.com/159621.html)
<!-- A great redo tutorial. -->


# Questions?
