# `Newman::Settings` provides the base functionality that is used by Newman's
# configuration files. It is currently a thin wrapper on top of Ruby's
# `OpenStruct` construct, but will later add some domain specific validations
# and transformations for the various configuration options it supports.
#
# Unless you need to customize the way that Newman's configuration system
# works or make changes to your settings objects at runtime, you probably don't
# need to worry about how this object is implemented. Both
# `Newman::Server.simple` and `Newman::Server.test_mode` create a
# `Newman::Settings` object for you automatically, and you will typically be
# tweaking a sample settings file rather than crafting one from scratch.
#
# `Newman::Settings`is part of Newman's **internal API**, but 
# the setting file format and various settings that Newman depends
# on should be considered part of the **external API**.

# ---
 
# List of current settings (all default to nil unless otherwise noted)
#
# - `imap.address`
# - `imap.user`
# - `imap.password`
# - `imap.ssl_enabled`  (default false)
# - `imap.port`
#
# - `smtp.address`
# - `smtp.user`
# - `smtp.password`
# - `smtp.starttls_enabled`  (default false)
# - `smtp.port`
#
# - `service.debug_mode`<br>
#       log error backtraces and full request and response emails
# - `service.default_sender`<br>
#       default FROM field for responses, can be changed by applications
# - `service.domain`<br>
#       mail domain, used by filters and by applications in building email addresses
# - `service.polling_interval`<br>
#       idle seconds between server ticks (checking and processing email)
# - `service.raise_exceptions`<br>
#       raise exceptions during server ticks, killing the server
# - `service.templates_dir`<br>
#       directory of template files, relative to the application root
#
module Newman 
  class Settings

    # ---
    
    # The `Newman::Settings.from_file` method is used to create
    # a new `Newman::Settings` object and populate it with the data 
    # contained in a settings file, i.e.
    #
    #     settings = Newman::Settings.from_file('config/environment.rb')
    # 
    # This method is purely syntactic sugar, and is functionally equivalent to
    # the following code:
    #
    #     settings = Newman::Settings.new
    #     settings.load_config('config/environment.rb')
    #
    # Because there currently is little advantage to explicitly instantiating a
    # blank `Newman::Settings` object, this method is the preferred way of doing
    # things.
    # 
    def self.from_file(filename)
      new.tap { |o| o.load_config(filename) }
    end

    # ---
     
    # A `Newman::Settings` object is a blank slate upon creation. It simply
    # assigns an empty `OpenStruct` object for each type of settings data it 
    # supports.     
    # 
    # In most situations, you will not instantiate a `Newman::Settings` object
    # directly but instead will make use of a configuration file and the
    # `Newman::Settings.from_file` method. Newman provides sample configuration
    # files in its `examples/` and `test/` directories, and applications should do the
    # same. This will help users discover what fields can be set.
    #
    # We are aware of the fact that the current configuration system is way too
    # flexible and a breeding ground for subtle bugs. This will be fixed in a
    # future version of Newman.

    def initialize
      self.imap        = OpenStruct.new
      self.smtp        = OpenStruct.new
      self.service     = OpenStruct.new
      self.application = OpenStruct.new
    end

    # ---

    # The `imap` and `smtp` fields are used by `Newman::Mailer`, 
    # the `service` field is used throughout Newman (particularly in
    # `Newman::Server`), and the `application` field is reserved for
    # application-specific configurations.

    attr_accessor :imap, :smtp, :service, :application


    # ---

    # `Newman::Settings#load_config` is used for evaluating
    # the contents of a file within the context of a `Newman::Settings`
    # instance. 
    #
    # In practice, this method is typically called by
    # `Newman::Settings#from_file`, but can also be used to apply 
    # multiple settings files to a single `Newman::Settings` object

    def load_config(filename)
      eval(File.read(filename), binding)
    end
  end
end
