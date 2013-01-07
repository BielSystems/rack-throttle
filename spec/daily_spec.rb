require File.dirname(__FILE__) + '/spec_helper'

describe Rack::Throttle::Daily do

  def app
    @target_app ||= example_target_app
    @daily_app ||= Rack::Throttle::Daily.new(@target_app, :max_per_day => 3)
  end


  it "should be allowed if not seen this day" do
    get "/foo"
    last_response.body.should show_allowed_response
    last_response.headers["X-RateLimit-Limit"].should == "3"
    last_response.headers["X-RateLimit-Remaining"].should == "2"
  end

  it "should be allowed if seen fewer than the max allowed per day" do
    2.times { get "/foo" }
    last_response.body.should show_allowed_response
    last_response.headers["X-RateLimit-Remaining"].should == "1"
  end

  context "surpassing the limit" do

    it "should not be allowed if seen more times than the max allowed per day" do
      4.times { get "/foo" }
      last_response.body.should show_throttled_response
    end

    describe 'after 1 hour' do

      it 'should allow more requests' do
        4.times { get "/foo" }
        last_response.body.should show_throttled_response

        Timecop.travel(Time.now + 3600 * 24)
        get "/foo"
        last_response.body.should show_allowed_response
        last_response.headers["X-RateLimit-Limit"].should == "3"
        last_response.headers["X-RateLimit-Remaining"].should == "2"
      end

      it 'should calculate the remaining properly' do
        2.times { get "/foo" }
        Timecop.travel(Time.now + 3600 * 1)
        2.times { get "/foo" }
        last_response.body.should show_throttled_response

        Timecop.travel(Time.now + 3600 * 12)
        get "/foo"
        last_response.headers["X-RateLimit-Remaining"].should == "2"
      end

    end
  end


end