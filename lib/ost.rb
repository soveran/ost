require "redis"
require "nest"

module Ost
  VERSION = "0.0.1"
  TIMEOUT = ENV["OST_TIMEOUT"] || 2

  class Queue
    attr :ns

    def initialize(name)
      @ns = Nest.new(:ost)[name]
    end

    def push(value)
      redis.lpush(ns, value)
    end

    def each(&block)
      loop do
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

    alias << push
    alias pop each

  private

    def redis
      Ost.redis
    end
  end

  @queues = Hash.new do |hash, key|
    hash[key] = Queue.new(key)
  end

  def self.[](queue)
    @queues[queue]
  end

  def self.connect(options = {})
    @redis = Redis.new(options)
  end

  def self.redis
    @redis ||= Redis.new
  end

  def self.redis=(redis)
    @redis = redis
  end
end
