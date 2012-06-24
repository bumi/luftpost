require "test_helper"

class Luftpost::ConfigTest < MiniTest::Unit::TestCase
  
  def test_default_regex
    assert_equal(/^#?(\w+):(.+)$/, Luftpost::Config.new.instructions_regex)
  end

  def test_configurable_instructions_regex
    config = Luftpost::Config.new(:instructions_regex=>/new/)
    assert_equal(/new/, config.instructions_regex)
  end

  def test_initialize_new_ruleset
    assert Luftpost::Config.new.ruleset.is_a?(Luftpost::Ruleset)
  end

  def test_save_ruleset
    config = Luftpost::Config.new
    config.ruleset.on(:command) do
      "bla"
    end
    assert config.ruleset.commands.keys.include?(:command)
  end
end