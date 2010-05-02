require File.join(File.dirname(__FILE__), "test_helper")

class TestOst < Test::Unit::TestCase
  def ost(&job)
    thread = Thread.new do
      Ost[:events].each(&job)
    end

    sleep 0.2

    thread.kill
  end

  setup do
    @redis = Redis.new
    @redis.flushdb

    Ost.connect
    Ost[:events].push(1)
  end

  teardown do
    Ost.redis.flushdb
  end

  should "insert items in the queue" do
    assert_equal ["1"], @redis.lrange("ost:events", 0, -1)
  end

  should "process items from the queue" do
    @results = []

    ost do |item|
      @results << item
    end

    assert_equal [], @redis.lrange("ost:events", 0, -1)
    assert_equal ["1"], @results
  end

  should "add failures to a special list" do
    ost do |item|
      raise "Wrong answer"
    end

    assert_equal 0, @redis.llen("ost:events")
    assert_equal 1, @redis.llen("ost:events:errors")

    assert_match /ost:events:1 => #<RuntimeError: Wrong answer/, @redis.rpop("ost:events:errors")
  end

  should "publish the error to a specific channel" do
    @results = []

    t1 = Thread.new do
      @redis.subscribe("ost:events:errors") do |on|
        on.message do |channel, message|
          if message[/ost:events:1 => #<RuntimeError: Wrong answer/]
            @results << message
            @redis.unsubscribe
          end
        end
      end
    end

    ost do |item|
      raise "Wrong answer"
    end

    t1.kill

    assert_equal 0, @redis.llen("ost:events")
    assert_equal 1, @redis.llen("ost:events:errors")

    assert_match /ost:events:1 => #<RuntimeError: Wrong answer/, @results.pop
  end
end
