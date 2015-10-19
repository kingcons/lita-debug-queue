## News

### 0.2.0 (2015-10-18)

* Restrict users adding themselves to the queue
  to hours defined by weekeday in the configuration.

  A `config.schedule` hash must be present in your
  config file, mapping `strftime("%a")` keys to hour ranges.

* Relax routing requirements on instructor commands.

### 0.1.9 (2015-10-08)

* Relax some of the routing requirements and fix the tests.

### 0.1.8 (2015-09-29)

* Add support for TAs using the `next`/`drop` commands
  by adding an `assistants` Slack auth group.

### 0.1.7 (2015-09-25)

* Fix bug in "debug next" implementation.

### 0.1.6 (2015-09-21)

* Fix a thinko. Not the best day for me.

### 0.1.5 (2015-09-21)

* Fix the bug but break most of the tests.

  I'm screwed on this one until Lita Slack Issue #44 is fixed.
  Essentially, the room object returned by lita-slack is incorrect.
  I had worked around this in the RoomFinder class but that code broke
  the tests so I added a conditional based on whether tests were running
  and oh god why am I writing this who am I talking to, screw it.

### 0.1.4 (2015-09-21)

* No plan survives first contact with the enemy.

  Add more debugging info to debug queue and debug count.

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
