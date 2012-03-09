### 0.3.0 (2012-03-08)

**Improvements:**

- Added documentation of all settings that can be modified via Newman configuration files.

- Added `Newman::Server#simple!`, which combines some of the flexibility of
  manually building a server object with sensible defaults. This method is
  useful for building simple tick-based servers, or for tweaking small details
  such as which logger you want to use.

- Allow a locals hash to be passed to tilt via `Newman::Controller#template`,
  and added some integration tests for template support.

**Behavior Changes:**

- Caching of logger object is less aggressive now, allowing 
  `Newman::Server#logger=` to be called at any time to change the 
  logger object used by the server.

- `Newman::Server.new` no longer accepts a custom logger argument. 
   Use `Newman::Server#logger=` instead.

- Locked explicitly to mail v2.3.0, because we're being bit by an upstream
  bug. We will try to lock more optimistically in a future release of
  Newman.

[Diff of all changes since 0.2.1](https://github.com/mendicant-university/newman/compare/v0.2.1...v0.3.0#diff-43)

### 0.2.1 (2012-02-11)

- Fixed a bug with `Newman::Application#match`. It now normalizes keys to 
  strings for easy use with `Newman::Application#compile_regex`, which
  fixes our substitution logic in patterns.

[Diff of all changes since 0.2.0](https://github.com/mendicant-university/newman/compare/v0.2.0...v0.2.1#diff-43)

### 0.2.0 (2012-02-08)

- Internals mostly rewritten, changes too numerous to outline meaningfully. 
  We'll keep better track of these changes in the future.

- Basic logging support added.

- Lots of documentation added.

- Server no longer crashes upon application errors unless
  service.raise_exceptions is set to true.

- Added Newman::Controller#skip_response which allows disabling delivery of a response
  email upon demand.

- Make Newman::MailingList fail gracefully by checking subscriber status before
  attempting subscribe / unsubscribe.

- Add a generic callback method to Newman::Application which allows for arbitrary
  callbacks to be run based on filters against the Mail::Message object.

[Diff of all changes since 0.1.1](https://github.com/mendicant-university/newman/compare/v0.1.1...v0.2.0#diff-43)

### 0.1.1 (2012-02-03)

- First official release.
