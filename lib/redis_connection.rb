# https://gist.github.com/wrburgess/3752973
class RedisConnection

  def self.close
    connection.quit
  end

  def self.connection
    @connection ||= new_connection
  end

  private

  def self.new_connection
    Redis.new(:host => ENV["REDIS_HOST"],
              :port => ENV["REDIS_PORT"],
              :password => ENV["REDIS_PASSWORD"],
              :thread_safe => true)
  end
end