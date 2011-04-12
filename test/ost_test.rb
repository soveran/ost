require File.expand_path("test_helper", File.dirname(__FILE__))

scope do
  def ost(&job)
    thread = Thread.new do
      Ost.redis = Redis.current
      Ost[:events].each(&job)
    end

    sleep 0.1

    thread.kill
  end

  def enqueue(id)
    Ost[:events].push(id)
  end

  prepare do
    Ost.redis.flushall
  end

  setup do
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

    ost do |item|
      raise "Wrong answer"
    end

    assert_equal 0, redis.llen("ost:events")
    assert_equal 1, redis.llen("ost:events:errors")

    assert redis.rpop("ost:events:errors").match(/ost:events:1 => #<RuntimeError: Wrong answer/)
  end

  test "publish the error to a specific channel" do |redis|
    enqueue(1)
    results = []

    t1 = Thread.new do
      redis.subscribe("ost:events:errors") do |on|
        on.message do |channel, message|
          if message[/ost:events:1 => #<RuntimeError: Wrong answer/]
            results << message
            redis.unsubscribe
          end
        end
      end
    end

    ost do |item|
      raise "Wrong answer"
    end

    t1.kill

    assert_equal 0, redis.llen("ost:events")
    assert_equal 1, redis.llen("ost:events:errors")

    assert results.pop.match(/ost:events:1 => #<RuntimeError: Wrong answer/)
  end
end
