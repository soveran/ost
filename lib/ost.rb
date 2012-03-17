require "nest"

module Ost
  VERSION = "0.1.1"
  TIMEOUT = ENV["OST_TIMEOUT"] || 0

  class Queue
    attr :key
    attr :backup

    def initialize(name)
      @key = Nest.new(:ost)[name]
      @backup = @key[Socket.gethostname][Process.pid]
    end

    def push(value)
      key.lpush(value)
    end

    def each(&block)
      @stopping = false

      loop do
        break if @stopping

        item = @key.brpoplpush(@backup, TIMEOUT)

        block.call(item)

        @backup.lpop
      end
    end

    def stop
      @stopping = true
    end

    def items
      key.lrange(0, -1)
    end

    alias << push
    alias pop each

    def redis
      @redis ||= Redis.connect(Ost.options)
    end
  end

  @queues = Hash.new do |hash, key|
    hash[key] = Queue.new(key)
  end

  def self.[](queue)
    @queues[queue]
  end

  def self.stop
    @queues.each { |_, queue| queue.stop }
  end

  @options = nil

  def self.connect(options = {})
    @options = options
  end

  def self.options
    @options || {}
  end
end
