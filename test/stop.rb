require_relative "helper"

scope do
  test "stop processing a queue" do
    Ost[:events].push(1)
    Ost[:events].stop
    Ost[:events].each { }

    assert(true)
  end

  test "stop processing all queues" do
    Ost[:events].push(1)
    Ost[:people].push(1)

    Ost.stop
    Ost[:events].each { }
    Ost[:people].each { }

    assert(true)
  end
end
