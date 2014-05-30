require_relative "helper"

scope do
  test "process items from the queue" do
    Ost[:events].push(1)

    results = []

    Ost[:events].stop
    Ost[:events].each do |item|
      results << item
    end

    assert_equal [], Ost[:events].items
    assert_equal ["1"], results
  end
end
