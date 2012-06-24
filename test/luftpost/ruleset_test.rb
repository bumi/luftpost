require "test_helper"

class Luftpost::RulesetTest < MiniTest::Unit::TestCase

  def setup
    @rulset = Luftpost::Ruleset.new do 
      on :status do |object,command,value|
        [object,command,value] 
      end
    end
  end

  def test_should_accept_a_block_to_initialize_rules
    assert @rulset.commands.include?(:status)
  end

  def test_call_proc_with_object_command_and_value
    assert_equal ["o", :status, "closed"], @rulset.call("o", :status,"closed")
  end

  def test_accept_multiple_commands_for_same_prod
    rulset = Luftpost::Ruleset.new do 
      on :status, :state do |object,command,value|
        [object,command,value] 
      end
    end
    assert rulset.commands.include?(:status)
    assert rulset.commands.include?(:state)
  end

end