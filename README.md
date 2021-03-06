# lita-debug-queue

[![Gem Version](https://badge.fury.io/rb/lita-debug-queue.svg)](http://badge.fury.io/rb/lita-debug-queue)
[![Build Status](https://travis-ci.org/kingcons/lita-debug-queue.svg?branch=master)](http://travis-ci.org/kingcons/lita-debug-queue)

A queue for tracking users who need debugging help with per-channel management.

## Installation

Add lita-debug-queue to your Lita instance's Gemfile:

``` ruby
gem "lita-debug-queue"
```

## Configuration

lita-debug-queue expects four things to be present for correct operation:

1. An `:instructors` authorization group containing admin users.
   If you want TAs to also be able to modify (but not clear) the
   queue you should add them to an `:assistants` group.
   The Slack admin can message Ironbot to add users to an authorization group as follows: `auth add nick.name instructors`.
   Note that the Slack admin IDs should be set in the `lita_config.rb` file for your bot. You can look up a users Id with `users find nick.name`.

2. A `debug_queue.classrooms` config option containing a Hash that maps instructor mention nam   es to classroom channels.

3. A `debug_queue.schedule` config option containing a Hash that maps from days of the week
   (as from `DateTime.now.strftime("%a")`), to ranges of hours in the
   [server's time zone][heroku-tz].
   
4. A `debug_api.passphrase` config option which is just a static string. A way to disable the API
   will be available in a future release.

[heroku-tz]: http://blog.pardner.com/2012/08/setting-the-default-time-zone-for-a-heroku-app/

## Usage

### General Commands

* `debug me` - Put your name in the queue for debugging help.
* `debug nvm` - Remove your name from the queue for debugging help.
* `debug queue` - Show the current queue for your class.
* `debug count` - Count the number of people waiting for help.

### Instructor Commands

* `debug next` - Notify the next student to be helped.
* `debug drop NAME` - Remove the student with NAME from the queue.
* `debug clear` - Empty the queue.

### API

Better docs coming soon. ... Ish.

### General Conventions

*AUTH*: Every request to the API must include a Query Param `?passphrase=FOO`. Check with your local debug queue admin.``

In the event that an invalid room is supplied or incorrect authorization is provided,
a JSON object containing an `error` key will be returned.
All correct API requests will result in a response with `queue` and `message` keys.

#### Retrieve the Queue for a Class

`GET /api/:classroom/queue`

#### Pop the Next Debugee

`PUT /api/:classroom/queue`

#### Drop a specific Debugee

`DELETE /api/:classroom/drop`

*PARAMS:* Drop requires a `student` query param with the mention name of the student to be removed from the queue.

#### Clear the Queue

`DELETE /api/:classroom/clear`
