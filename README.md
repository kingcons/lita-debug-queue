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

lita-debug-queue expects two things to be present for correct operation:

1. An `:instructors` authorization group containing admin users.
2. A `classrooms` config option containing a Hash that maps instructor mention names to classroom channels.

## Usage

All usage is based on commands so statements must be directed `@ironbot: foo` or sent as a DM.

### General Commands

* `debug me` - Put your name in the queue for debugging help.
* `debug nvm` - Remove your name from the queue for debugging help.
* `debug queue` - Show the current queue for your class.
* `debug count` - Count the number of people waiting for help.

### Instructor Commands
* `debug next` - Notify the next student to be helped.
* `debug drop NAME` - Remove the student with NAME from the queue.
* `debug clear` - Empty the queue.
