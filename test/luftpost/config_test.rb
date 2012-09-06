require "test_helper"

class Luftpost::ConfigTest < MiniTest::Unit::TestCase

  def test_defaults
    assert Luftpost::Config.new.mailgun.api_url, "https://api.mailgun.net/v2"
  end

end