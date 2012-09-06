require 'hashr'
module Luftpost
  class Config < Hashr
    define :mailgun => {:api_url => "https://api.mailgun.net/v2", :api_key => "", :user => "api" }
  end
end