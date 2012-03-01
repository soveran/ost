# 1.0.0 - unreleased

* `Ost#each` no longer rescues exceptions for you.

  You are in charge of rescuing and deciding what to do.

* You can inspect the status of the queue by calling `Ost::Queue#items`.

* If you need access to the underlying Redis key, it's in `Ost::Queue#key`.
