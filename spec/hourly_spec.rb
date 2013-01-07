require File.dirname(__FILE__) + '/spec_helper'

describe Rack::Throttle::Hourly do

  def app
    @target_app ||= example_target_app
    @hourly_app ||= Rack::Throttle::Hourly.new(@target_app, :max_per_hour => 3)
  end

  context "when not reaching the limit" do

    it "should be allowed if not seen this hour" do
      get "/foo"
      last_response.body.should show_allowed_response
      last_response.headers["X-RateLimit-Limit"].should == "3"
      last_response.headers["X-RateLimit-Remaining"].should == "2"
    end

    it "should be allowed if seen fewer than the max allowed per hour" do
      2.times { get "/foo" }
      last_response.body.should show_allowed_response
      last_response.headers["X-RateLimit-Remaining"].should == "1"
    end

  end

  context "surpassing the limit" do

    it "should not be allowed if seen more times than the max allowed per hour" do
      4.times { get "/foo" }
      last_response.body.should show_throttled_response
    end

    describe 'after 1hr' do

      it "should allow another request" do
        4.times { get "/foo" }
        last_response.body.should show_throttled_response

        Timecop.travel(Time.now + 3600)
        get "/foo"
        last_response.body.should show_allowed_response
        last_response.headers["X-RateLimit-Limit"].should == "3"
        last_response.headers["X-RateLimit-Remaining"].should == "2"
      end
    end

  end

end
