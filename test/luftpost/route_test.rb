require "test_helper"

class Luftpost::RouteTest < MiniTest::Unit::TestCase

  def test_successful_route_creation
    Luftpost.config.mailgun.api_key = "apikey"
    Luftpost.config.mailgun.api_url = "http://api.mailgun.net/v2"
    stub_http_request(:post, "api:apikey@api.mailgun.net/v2").
        with(:body => {:description => "new forward", :priority => "1", :expression => "match_recipient('.*@railslove.dealbaseapp.com')", :action => "forward('https://railslove.dealbaseapp.com/callback')"}).
        to_return(:body => File.read(File.join(File.dirname(__FILE__), "../fixtures/mailgun_route_create_successful.json")), :status => 200)
        
    route = Luftpost::Route.new({:description => "new forward", :priority => "1", :expression => "match_recipient('.*@railslove.dealbaseapp.com')", :actions => "forward('https://railslove.dealbaseapp.com/callback')"})
    assert_equal "4f3bad2335335426750048c6", route.create
    assert_equal "4f3bad2335335426750048c6", route.id
  end

  def test_unsuccessful_route_creation
    Luftpost.config.mailgun.api_key = "apikey"
    Luftpost.config.mailgun.api_url = "http://api.mailgun.net/v2"
    stub_http_request(:post, "api:apikey@api.mailgun.net/v2").
        with(:body => {:description => "new forward", :priority => "1", :expression => "match_recipient('.*@railslove.dealbaseapp.com')", :action => "forward('https://railslove.dealbaseapp.com/callback')"}).
        to_return(:body => %Q{{"message": "fail"}}, :status => 403)
    
    route = Luftpost::Route.new({:description => "new forward", :priority => "1", :expression => "match_recipient('.*@railslove.dealbaseapp.com')", :actions => "forward('https://railslove.dealbaseapp.com/callback')"})
    assert_equal nil, route.create
  end

  def test_to_param_hash_for_api_request
    assert_equal({
      "description" => "route66", 
      "priority" => 1, 
      "expression" => "expression",
      "action" => "action"
      }, 
      Luftpost::Route.new(:description => "route66", :id => "1234", :priority => 1, :expression => "expression", :actions => "action").to_params
    )
  end
end