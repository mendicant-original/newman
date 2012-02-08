# Newman::Version is used to determine which version of Newman is currently
# running and is part of Newman's **external api**.
#
# Our versioning policy is roughly as follows:
#
# 1) Clearly mark each object that Newman provides as being part of either
# the 'external API' or the 'internal API'. The external API is for
# application developers, the internal API is for Newman itself as well as
# extension developers

# 2) Before 1.0, allow backwards incompatible internal API changes during
# every release, and allow backwards incompatible external API changes
# during minor version bumps, but do not add or change external behavior
# in tiny version bumps.

# 3) After 1.0, do not allow external or internal API changes during tiny
# version bumps (these will be bug fixes only). Allow changes to the
# internal API during minor version bumps, but maintain backwards
# compatibility with the 1.0 release (i.e. things introduced after 1.0 can
# be changed / removed, but things which shipped with 1.0 should stay
# supported, even internally). Allow external API changes or
# backwards-incompatible changes to the internals only on major version
# bumps (i.e. 2.0, 3.0, etc). Use semantic versioning and declare the
# external API to be the 'public' API.

# We plan to get to 1.0 quickly to reach a stabilizing point for application
# developers and a slower moving target for extension developers. This means
# that our 1.0 release will be more of a minimum-viable product and not
# necessarily a full-stack framework.

module Newman
  module Version
    MAJOR  = 0
    MINOR  = 1
    TINY   = 1
    STRING = "#{MAJOR}.#{MINOR}.#{TINY}"
  end
end
