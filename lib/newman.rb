# [Newman](https://github.com/mendicant-university/newman) is a 
# microframework which aims to do for email-based applications what Rack and 
# Sinatra have done for web programming. **While our goals may be ambitious, 
# this project is currently in a very early experimental stage, 
# and is in no way safe for use in production.**
#
# That said, we still welcome contributors to help us work on this project
# as we collectively figure out what exactly Newman should be. Even in its
# very early stages, Newman is already doing some useful things and provides
# a wide range of application development features via its external interface
# as well as extension points via its internal interface.
#
# The documentation you're currently reading is meant to help explain Newman's
# implementation to contributors and alpha testers. Before you dig deeper into
# the source, make sure to read 
# [Newman's README](https://github.com/mendicant-university/newman)
# as well as the [Jester](https://github.com/mendicant-university/jester) demo
# application.
#
# Assuming you have done those things and are now familiar with the basic ideas
# behind Newman, the following outline may help you in your explorations of
# its source code.
#
# ### External interface (for application developers)
#
# * [Newman::Server](http://mendicant-university.github.com/newman/lib/newman/server.html) 
#   takes incoming mesages from a mailer object and passes them to applications as a 
#   request, and then delivers a response email that built up by its
#   applications.
#
# * [Newman::Application](http://mendicant-university.github.com/newman/lib/newman/application.html)
#   provides the main entry point for Newman application developers, and exists to tie together 
#   various Newman objects in a convenient way.
#
# * [Newman::Filters](http://mendicant-university.github.com/newman/lib/newman/filters.html)
#   provides high level filters for matching incoming requests.
#   
# * [Newman::Controller](http://mendicant-university.github.com/newman/lib/newman/controller.html)
#   provides a context for application callbacks to run in, and provides most of
#   the core functionality for preparing a response email.
#
# * [Newman::MailingList](http://mendicant-university.github.com/newman/lib/newman/mailing_list.html)
#   implements a simple mechanism for storing persistent lists of email addresses keyed 
#   by a mailing list name. 
#
# * [Newman::Store](http://mendicant-university.github.com/newman/lib/newman/store.html) provides 
#   a minimal persistence layer for storing non-relational data.
#
# * [Newman::Recorder](http://mendicant-university.github.com/newman/lib/newman/recorder.html)
#   provides a mechanism for storing records with autoincrementing identifiers
#   within a `Newman::Store` and supports some rudimentary CRUD functionality.
#
# * Implicitly, the settings files used by Newman as well as the structure of
#   its low level data storage format are also considered part of external API,
#   even though these are actually implementation details. This is simply
#   because we want to make sure to clearly reflect backwards incompatible
#   changes to these features via our versioning policy, as this sort of
#   change could potentially cause update problems for application
#   developers.
#
# ### Internal interface (for extension developers)
#
# * [Newman::EmailLogger](http://mendicant-university.github.com/newman/lib/newman/email_logger.html)
#   provides rudimentary logging support for email objects, and primarily exists to 
#   support the `Newman::RequestLogger` and `Newman::ResponseLogger` objects.
#
# * [Newman::RequestLogger](http://mendicant-university.github.com/newman/lib/newman/request_logger.html)
#   provides a mechanism for logging information about incoming emails.
#
# * [Newman::ResponseLogger](http://mendicant-university.github.com/newman/lib/newman/response_logger.html)
#   provides a mechanism for logging information about outgoing emails.
#
# * [Newman::Mailer](http://mendicant-university.github.com/newman/lib/newman/mailer.html) provides a thin
#   wrapper on top of the [mail gem](http://github.com/mikel/mail) which is
#   designed to have a minimal API so that it can easily be swapped out with
#   another mailer object.
#
# * [Newman::TestMailer](http://mendicant-university.github.com/newman/lib/newman/test_mailer.html) 
#   is a drop-in replacement for `Newman::Mailer` meant for use in automated testing. 
#
# * [Newman::Settings](http://mendicant-university.github.com/newman/lib/newman/settings.html) provides
#   the base functionality that is used by Newman's configuration files. Note
#   that while this object is part of the internals, the settings actually used
#   by Newman should be considered part of the external API.
#
# ### Getting help, or helping out:
#
# Please catch up with seacreature or ericgj in the #newman channel on Freenode,
# or send an email to newman@librelist.org. We'd love to hear any questions,
# ideas, or suggestions you'd like to share with us.

require "logger"
require "pstore"
require "ostruct"
require "fileutils"
require "optparse"

require "mail"
require "tilt"

require_relative "newman/email_logger"
require_relative "newman/request_logger"
require_relative "newman/response_logger"
require_relative "newman/server"
require_relative "newman/filters"
require_relative "newman/application"
require_relative "newman/controller"
require_relative "newman/mailing_list"
require_relative "newman/settings"
require_relative "newman/store"
require_relative "newman/recorder"
require_relative "newman/mailer"
require_relative "newman/runner"
require_relative "newman/test_mailer"
require_relative "newman/version"
