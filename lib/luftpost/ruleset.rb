module Luftpost
  class Ruleset
    attr_accessor :commands

    def initialize(&block)
      self.commands = {}
      instance_eval(&block) if block_given?
    end

    def on(*cmds,&block)
      cmds.each do |command|
        self.commands[command] = block
      end
    end
    def call(object, command, value)
      return unless self.commands.include?(command)
      self.commands[command].call(object,command,value)
    end
  end
end