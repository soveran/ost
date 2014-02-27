## Unreleased

* Add `Ost::Queue#size` method. Returns the current size of the queue.

  Example:
  
  ```ruby
  Ost[:events].size # => 0
  Ost[:events].push(1)
  Ost[:events].size # => 1
  ```

## 0.1.5

* Fix bug with redis connection handling. Previously, it was just using the default connection
  of `localhost:6379`, regardless if you setup your app with an `Ost.connect`.

## 0.1.4

* No changes.

## 0.1.3

* Don't yield the block on timeouts.

## 0.1.2

* Change default timeout to 2 seconds.

## 0.1.1

* Use `backup.lpop` instead of `backup.del`.

## 0.1.0

* `Ost#each` no longer rescues exceptions for you.

    You are in charge of rescuing and deciding what to do.

* You can inspect the status of the queue by calling `Ost::Queue#items`.

* If you need access to the underlying Redis key, it's in `Ost::Queue#key`.

* Ost now uses `BRPOPLPUSH` and maintains a backup queue while working.

    You can access this queue using `Ost::Queue#backup`.
