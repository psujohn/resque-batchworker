require 'resque'
require 'active_support' 

module Kernel
  def safe_fork(count = 1)
    if Object.const_defined?('ActiveRecord') && ActiveRecord.const_defined?('Base')
      ActiveRecord::Base.lock_optimistically = false
      ActiveRecord::Base.connection_pool.disconnect!
    end  
    
    count.times do |i|
      fork do
        Resque.redis = Redis.new
        yield(i) if block_given?
        exit!
      end
    end
    Process.waitall
  end
end
