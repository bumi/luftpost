module Luftpost
  class Processor
    attr_accessor :text, :clean_text, :matches, :instructions, :ruleset

    def initialize(text, ruleset)
      @text         = text
      @ruleset      = ruleset
      @instructions = {}
      @matches      = []
      self.parse!
    end

    def apply_to(object)
      self.instructions.each do |command, value|
        self.ruleset.call(object,command,value)
      end
    end

    def parse!
      self.clean_text = self.text.gsub(Luftpost.config.instructions_regex) { |match|
        command = $1.strip.to_sym
        value = $2.strip

        self.matches << match
        self.instructions[command] = value
        nil
      }.strip
    end
  end
end