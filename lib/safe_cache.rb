# SafeCache
module SafeCache

  def self.included(base) #:nodoc:
    base.extend(SafeCache::CacheMethods)  
  end
  
  module CacheMethods
    # +caches_safely+ gives the class it is called on the cache_safely instance and class methods
    def caches_safely(options={})
      unless included_modules.include? InstanceMethods 
        extend ClassMethods 
        include InstanceMethods    
      end
    end
  
    module CommonMethods
    end

    module ClassMethods   
      def uncached_method_call(method, arguments)
        if arguments.blank?
          self.send(method.to_sym)
        else
          self.send(method.to_sym, arguments)
        end
      end
    
      # TODO: get the options from config, settable in environment.rb or initializers.rb
      def cache_safely(method, arguments={}, options={:expires_in => 15.minutes})
        cache_key = [self.to_s, method, arguments.to_query].join('_')
        begin
          result = Rails.cache.read(cache_key)
          if result.nil?
            result = self.uncached_method_call(method, arguments)
            Rails.cache.write(cache_key, result, options)
          end
        rescue
          Rails.cache.clear
          result = self.uncached_method_call(method, arguments)
        end
        result
      end
    end

    module InstanceMethods
      def uncached_method_call(method, arguments)
        if arguments.blank?
          self.send(method.to_sym)
        else
          self.send(method.to_sym, arguments)
        end
      end    
    
      def cache_safely(method, arguments={}, options={:expires_in=>15.minutes})
        begin
          cache_key = [self.class.to_s, self.id, method, arguments.to_query].join('_')
          result = Rails.cache.read(cache_key)
          if result.nil?
            result = uncached_method_call(method, arguments)
            Rails.cache.write(cache_key, result, options)
          end
        rescue          
          Rails.cache.clear
          result = call_for_safe_cached(method, arguments)            
        end          
        result          
      end
    
    end  
  
  end
  
end