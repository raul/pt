# PivotalTracker gem doesn't update the connection when switching SSL
# I'll submit a pull request, but in the meantime this patch should solve it
module PivotalTracker
  class Client
    def self.use_ssl=(val)
      if !@use_ssl == val
        @connection = nil if @connection
        @connections = {} if @connections
      end

      @use_ssl = val
    end
  end
end
