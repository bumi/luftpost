require 'hashr'
module Luftpost
  class Config < Hashr
    define :instructions_regex => /^#?(\w+):(.+)$/, :mailgun => {:api_url => "https://api.mailgun.net/v2", :api_key => "", :user => "api" }

    def ruleset
      @ruleset ||= Luftpost::Ruleset.new
    end
  end
end