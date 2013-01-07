module Rack; module Throttle
  ##
  class TimeWindow < Limiter
    ##
    # Returns `true` if fewer than the maximum number of requests permitted
    # for the current window of time have been made.
    #
    # @param  [Rack::Request] request
    # @return [Boolean]
    def allowed?(request)
      count = cache_get(key = cache_key(request)).to_i + 1 rescue 1
      allowed = count <= max_per_window.to_i
      begin
        cache_set(key, count)
        allowed
      rescue => e
        allowed = true
      end
    end

    def rate_limit_headers(request, headers)
      headers['X-RateLimit-Limit'] = max_per_window.to_s
      headers['X-RateLimit-Remaining'] = ([0, max_per_window - (cache_get(cache_key(request)).to_i rescue 1)].max).to_s
      headers
    end

    def need_protection?(request)
      true
    end

  end
end; end
