require_relative "helper"

scope do
  test "inherits ost redis connection by default" do
    queue = Ost[:events]

    assert_equal Ost.redis.url, queue.redis.url
  end

  test "queue can define its own connection" do
    queue = Ost[:people]
    queue.redis = Redic.new("redis://localhost:6379/1")

    assert Ost.redis.url != queue.redis.url
  end
end
