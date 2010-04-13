Ost
===

Redis based queues and workers.

Description
-----------

**Ost** makes it easy to enqueue object ids and process them with workers.

Say you want to process video uploads. In your application you will have something like this:

    Ost[:videos_to_process].push(@video.id)

Then, you will have a worker that will look like this:

    require "ost"

    Ost[:videos_to_process].each do |id|
      # Do something with it!
    end

Usage
-----

**Ost** connects to Redis automatically with the default options (localhost:6379, database 0).

You can customize the connection by calling `connect`:

    Ost.connect port: 6380, db: 2

Then you only need to refer to a queue for it to pop into existence:

    Ost[:rss_feeds] << @feed.id

A worker is a Ruby file with this basic code:

    require "ost"

    Ost[:rss_feeds].each do |id|
      ...
    end

It will pop items from the queue with a timeout of two seconds and retry indefinitely. If you want to configure the timeout, set the environment variable `OST_TIMEOUT`.

Available methods for a queue are `push` (aliased to `<<`) and `pop` (aliased to `each`).

Note that in these examples we are pushing numbers to the queue. As we have unlimited queues, each queue should be specialized and the workers must be smart enough to know what to do with the numbers they pop.

Failures
========

If the block raises an error, it is captured by **Ost** and the exception is logged in Redis.

Consider this example:

    require "ost"

    Ost[:rss_feeds].each do |id|
      ...
      raise "Invalid format"
    end

Then, in the console you can do:

    >> Ost[:rss_feeds].push 1
    => 1

    >> Ost[:rss_feeds].errors
    => ["2010-04-12 21:57:23 -0300 ost:rss_feeds:1 => #<RuntimeError: Invalid format>"]

Differences with Delayed::Job and Resque
--------------------------------------

Both [Delayed::Job](http://github.com/tobi/delayed_job) and [Resque](http://github.com/defunkt/resque)
provide queues and workers (the later using Redis). They provide dumb workers that process jobs, which are specialized for each task. The specialization takes place in the application side, and the job is serialized and pushed into a queue.

**Ost**, by contrast, just pushes numbers into specialized queues, and uses workers that are subscribed to specific queues and know what to do with the items they get. The total sum of logic is almost the same.

Installation
------------

    $ sudo gem install ost

License
-------

Copyright (c) 2010 Michel Martens

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
