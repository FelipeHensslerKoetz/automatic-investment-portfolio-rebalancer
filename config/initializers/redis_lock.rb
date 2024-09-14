require 'redis'
require 'redis-lock'

REDIS_LOCK = Redis.new(url: 'redis://localhost:6379/0')