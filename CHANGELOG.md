### 0.2.0 (2012-02-08)

- Internals mostly rewritten, changes too numerous to outline meaningfully. We'll keep better track of these changes in the future.

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

### 0.1.1 (2012-02-03)

- First official release.
