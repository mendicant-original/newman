![Newman](http://i.imgur.com/92bZB.jpg)

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
  want to make that problem worse.

* Newman is taking a use-case oriented approach to design. Be prepared to
  justify any proposed change with real or realistic scenarios, rather than
  simply addressing theoretical concerns.

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
