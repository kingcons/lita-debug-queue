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

lita-debug-queue expects three things to be present for correct operation:

1. An `:instructors` authorization group containing admin users.
   If you want TAs to also be able to modify (but not clear) the
   queue you should add them to an `:assistants` group.

2. A `classrooms` config option containing a Hash that maps instructor mention nam   es to classroom channels.

3. A `schedule` config option containing a Hash that maps from days of the week
   (as from `DateTime.now.strftime("%a")`), to ranges of hours in the
   [server's time zone][heroku-tz].

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
