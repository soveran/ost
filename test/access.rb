require_relative "helper"

scope do
  test "access to underlying key" do
    assert_equal "ost:events", Ost[:events].key
  end

  test "access to queued items" do
    Ost[:events].push(1)

    assert_equal ["1"], Ost[:events].items
  end

  test "access to queue size" do
    queue = Ost[:events]
    assert_equal 0, queue.size

    queue.push(1)
    assert_equal 1, queue.size

    queue.stop
    queue.each { }
    assert_equal 0, queue.size
  end
end
