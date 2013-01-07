require 'rubygems'
require 'sinatra'
require 'rack/throttle'

module Rack
  module Test
    class FakeApp < Sinatra::Base

      get '/foo' do
        'Hello Throttler!'
      end
    end
  end
end
