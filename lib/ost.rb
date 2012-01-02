require "nest"

module Ost
  VERSION = "0.0.3"
  TIMEOUT = ENV["OST_TIMEOUT"] || 2

  class Queue
    attr :ns

    def initialize(name)
      @ns = Nest.new(:ost)[name]
    end

    def push(value)
      unstop
      redis.lpush(ns, value)
    end

    def each(&block)
      loop do
        break if stopped?
        _, item = redis.brpop(ns, TIMEOUT)
        next if item.nil? or item.empty?

        begin
          block.call(item)
        rescue Exception => e
          error = "#{Time.now} #{ns[item]} => #{e.inspect}"

          redis.rpush   ns[:errors], error
          redis.publish ns[:errors], error
        end
      end
    end

    def errors
      redis.lrange ns[:errors], 0, -1
    end

    def stop
      redis.set ns[:stop], 1
    end

    def unstop
      redis.del ns[:stop]
    end

    def stopped?
      redis.exists ns[:stop]
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
