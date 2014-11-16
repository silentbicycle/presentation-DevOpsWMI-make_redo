presentation slides: "make and redo For Building and Automation"

- Given at [DevOps West Michigan][1] on 2014-11-10.

[1]: http://www.meetup.com/DevOps-West-Michigan/


## Abstract

"While make is usually described as a build system, it's a more general
tool. This talk will cover automating tasks that may look nothing like
rebuilding programs, working within its conceptual model, and how to
avoid common mistakes. It will also give an intro to redo, a similar
(but less well known) tool that addresses many of make's issues.
Comparing the two will bring their common design into focus, and help
with learning to use either effectively."


## Slides and presenter's notes

This presentation uses [markdown_to_reveal][2] and [pandoc][3] to
generate [reveal.js][4] slides (`slides.html`) from the markdown source
(`slides.md`).

The source also has presenter's notes included as inline comments.
Reading the `slides.md` file directly is recommended, because the slides
themselves are pretty minimal.

[2]: https://github.com/silentbicycle/markdown_to_reveal
[3]: http://johnmacfarlane.net/pandoc/
[4]: http://lab.hakim.se/reveal-js/#/


### Building

To build the slides:

    make
    
or

    redo

