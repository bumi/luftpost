require "luftpost/version"
require 'openssl'
module Luftpost
  autoload :Config, "luftpost/config"
  autoload :Mailgun, "luftpost/mailgun"
  autoload :Ruleset, "luftpost/ruleset"
  autoload :Processor, "luftpost/processor"
  autoload :Route, "luftpost/route"
  
  class << self
    def config
      @config ||= Config.new
    end
  end
end