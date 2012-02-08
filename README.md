![Newman](http://i.imgur.com/92bZB.jpg)

Newman is a microframework which aims to do for email-based 
applications what Rack and Sinatra have done for web programming. It is
currently in its very early experimental stages, and is not safe for use in
production. 

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

* Basic support for email templates are provided via Tilt

* A barebones configuration system allows configuring email settings, service
  settings, and application specific settings.

We are still working on figuring out what belongs in Newman and what doesn't,
and so all of these features are subject to change or disappear entirely. But if
you have a need for this sort of tool, it's worth noting that this software
isn't entirely vaporware, and that we could use your help!

### For a demonstration of how Newman is used:

Check out [Jester](http://github.com/mendicant-university/jester) as well as some of the
simple examples in this repository.

### For a walkthrough of Newman's codebase:

Check out the [Rocco-based API documentation](http://mendicant-university.github.com/newman/lib/newman.html).

### For general discussion, questions, and ideas about newman:

Find seacreature in the #newman channel on Freenode or send an email to newman@librelist.org
