require_relative "helper"

scope do
  test "returns backup key" do
    hostname = Socket.gethostname
    pid = Process.pid

    assert_equal "ost:events:#{hostname}:#{pid}", Ost[:events].backup
  end

  test "maintains a backup queue for when worker dies" do
    queue = Ost[:events]

    queue.push(1)

    assert_equal 0, queue.redis.call("LLEN", queue.backup)

    begin
      queue.stop
      queue.each { |item| item.some_error }
    rescue
    end

    assert_equal ["1"], queue.redis.call("LRANGE", queue.backup, 0, -1)
  end

  test "cleans up the backup queue on success" do
    queue = Ost[:events]
    queue.push(1)

    queue.stop
    queue.each do |item|
      assert_equal [item], queue.redis.call("LRANGE", queue.backup, 0, -1)
    end

    assert_equal [], queue.redis.call("LRANGE", queue.backup, 0, -1)
  end
end
