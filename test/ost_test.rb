require File.expand_path("test_helper", File.dirname(__FILE__))

scope do
  def ost(&job)
    thread = Thread.new do
      Ost[:events].each do |item|
        begin
          yield(item)
        ensure
          thread.kill
        end
      end
    end
  end

  def enqueue(id)
    Ost[:events].push(id)
  end

  prepare do
    Redis.current.flushall
  end

  setup do
    Ost[:events].redis.quit
    Redis.new
  end

  test "insert items in the queue" do |redis|
    enqueue(1)
    assert_equal ["1"], redis.lrange("ost:events", 0, -1)
  end

  test "process items from the queue" do |redis|
    enqueue(1)

    results = []

    ost do |item|
      results << item
    end

    assert_equal [], redis.lrange("ost:events", 0, -1)
    assert_equal ["1"], results
  end

  test "add failures to special lists" do |redis|
    enqueue(1)

    assert_raise do
      Ost[:events].each do |item|
        item.some_error
      end
    end

    assert_equal 0, redis.llen("ost:events")
  end

  test "halt processing a queue" do
    Thread.new do
      sleep 0.5
      Ost[:always_empty].stop
    end

    Ost[:always_empty].each { }

    assert true
  end

  test "halt processing all queues" do
    Thread.new do
      sleep 0.5
      Ost.stop
    end

    t1 = Thread.new { Ost[:always_empty].each { } }
    t2 = Thread.new { Ost[:always_empty_too].each { } }

    t1.join
    t2.join

    assert true
  end

  test "allows access to the queued items" do
    enqueue(1)

    assert_equal ["1"], Ost[:events].items
  end
end
