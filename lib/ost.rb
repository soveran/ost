require "nido"
require "redic"

module Ost
  TIMEOUT = ENV["OST_TIMEOUT"] || "2"

  class Queue
    attr :key
    attr :backup

    def initialize(name)
      @key = Nido.new(:ost)[name]
      @backup = @key[Socket.gethostname][Process.pid]
      @stopping = false
    end

    def push(value)
      redis.call("LPUSH", @key, value)
    end

    def each(&block)
      loop do
        item = redis.call("BRPOPLPUSH", @key, @backup, TIMEOUT)

        if item.nil?
          if @stopping
            break
          else
            next
          end
        end

        block.call(item)

        redis.call("LPOP", @backup)

        break if @stopping
      end
    end

    def stop
      @stopping = true
    end

    def items
      redis.call("LRANGE", @key, 0, -1)
    end

    alias << push
    alias pop each

    def size
      redis.call("LLEN", @key)
    end

    def redis
      defined?(@redis) ? @redis : Ost.redis
    end

    def redis=(redis)
      @redis = redis
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

  def self.redis
    @redis ||= Redic.new
  end

  def self.redis=(redis)
    @redis = redis
  end
end
