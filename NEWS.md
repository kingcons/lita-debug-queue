## News

### 0.1.3 (2015-08-31)

* Fix an error in how "debug next" notifies the student.

  The error in question wasn't caught by the test suite
  as the behavior is mocked by the tests. Specifically,
  the test suite is happy to accept a string representing
  the mention name but in real usage a Lita::Source object
  containing a Lita::User is required. *sigh*

  I'm not sure how to write a regression test for this
  without checking implementation details in a nasty way.
  And I'm on vacation at the beach anyway so time for a walk.

### 0.1.2 (2015-08-31)

* Add docstrings for built-in Lita help.
* Fix inconsistency in the way the room is determined.
* Fix student not being notified on instructor "debug next".

### 0.1.1 (2015-08-28)

* Quick workaround for issue #44 in lita-slack.

### 0.1.0 (2015-08-28)

* Initial release. Undocumented.
