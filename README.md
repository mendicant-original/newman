![Newman](http://i.imgur.com/GCqaT.png)

Newman is a microframework which aims to do for email-based 
applications what Rack and Sinatra have done for web programming. **While our
goals may be ambitious, this project is
currently in a very early experimental stage, and is in no way safe for use in
production.** 

That said, Newman is already capable of doing a number of interesting things. In
particular:

* A simple polling server provides a basic interface for
  reading email from a single inbox and then building up a response email.

* Filters are provided for handling emails based on their TO and SUBJECT fields.

* Filters can also be defined for handling messages based on arbitrary
  conditions evaluated against a `Mail::Messsage` object.

* A rudimentary PStore backed storage mechanism is provided for persistence.

* Basic support for maintaining persistent lists of email addresses is
  provided.

* Basic support for email templates are provided via Tilt.

* A barebones configuration system allows configuring email settings, service
  settings, and application specific settings.

We are still working on figuring out what belongs in Newman and what doesn't,
and so all of these features are subject to change or disappear entirely. But if
you have a need for this sort of tool, it's worth noting that this software
isn't entirely vaporware, and that we could use your help!

### Scary Warning:

DON'T HOOK UP NEWMAN TO ANY EMAIL INBOX THAT YOU CAN'T COMPLETELY WIPE OUT EVERY TIME IT RUNS. NEWMAN **WILL** DELETE YOUR EMAILS!!!

### For a demonstration of how Newman is used:

Check out [Jester](http://github.com/mendicant-university/jester) as well as some of the
simple examples in this repository.

### For a walkthrough of Newman's codebase:

Check out [Newman's Rocco-based API documentation](http://mendicant-university.github.com/newman/lib/newman.html).

We update this documentation on each gem release of newman, but to generate this documentation yourself, 
you'll need to install the rocco gem.

### For general discussion, questions, and ideas about Newman:

Find seacreature or ericgj in the #newman channel on Freenode or send an email to newman@librelist.org

### Contributing to Newman:

We do not yet have a clear roadmap or contributor guidelines, so be sure to talk
to us before working on bug fixes or patches. But assuming you do want to send
us some code, here is what you need to know:

* You get to keep the copyright to your code, but you must agree to license it
  under the MIT license.

* Your code should come with tests. Integration tests are fine, but unit tests
  would be nice where appropriate. Right now Newman is under tested and we don't
  want to make that problem worse. You can of course submit a pull request for
  feedback BEFORE writing tests.

* Your code should be fully documented, and properly formatted for use with
  Rocco. Please try to emulate the style and conventions we've been using where
  possible. Do the best you can with this, and we'll help tighten up wording and
  clean up formatting as needed. You can of course submit a pull request for
  feedback BEFORE writing documentation.

* Newman is taking a use-case oriented approach to design. Be prepared to
  justify any proposed change with real or realistic scenarios, rather than
  simply addressing theoretical concerns.

### Versioning Policy:

We will try to follow the guidelines below when cutting new releases,
to the extent that it makes sense to do so.

1) Clearly mark each object that Newman provides as being part of either
the 'external API' or the 'internal API'. The external API is for
application developers, the internal API is for Newman itself as well as
extension developers

2) Before 1.0, allow backwards incompatible internal API changes during
every release, and allow backwards incompatible external API changes
during minor version bumps, but do not add or change external behavior
in tiny version bumps.

3) After 1.0, do not allow external or internal API changes during tiny
version bumps (these will be bug fixes only). Allow changes to the
internal API during minor version bumps, but maintain backwards
compatibility with the 1.0 release (i.e. things introduced after 1.0 can
be changed / removed, but things which shipped with 1.0 should stay
supported, even internally). Allow external API changes or
backwards-incompatible changes to the internals only on major version
bumps (i.e. 2.0, 3.0, etc). Use semantic versioning and declare the
external API to be the 'public' API.

We plan to get to 1.0 quickly to reach a stabilizing point for application
developers and a slower moving target for extension developers. This means
that our 1.0 release will be more of a minimum-viable product and not
necessarily a full-stack framework.

### Authorship:

Newman is being developed by [Gregory Brown](http://community.mendicantuniversity.org/people/sandal)
and [Eric Gjertsen](http://community.mendicantuniversity.org/people/ericgj), along with 
help from several other folks. 

It is based on an assignment from [Mendicant
University](http://mendicantuniversity.org)'s January 2011 core
skills course, and was also used as a sample application for the [Practicing Ruby](http://practicingruby.com)
journal. The original inspiration for this project came from some code
written by [Brent Vatne](http://community.mendicantuniversity.org/people/brentvatne), 
as well as from the general ideas behind Rack and Sinatra.

[View the full list of contributors](https://github.com/mendicant-university/newman/contributors) to see who else has helped out.

### License:

Copyright (c) 2012 Gregory Brown, Eric Gjertsen, et al.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
