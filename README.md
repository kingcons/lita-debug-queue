# lita-debug-queue

Queue tracking of users who need debugging help with per-channel management.

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

**TODO**
