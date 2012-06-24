require "test_helper"

class Luftpost::ProcessorTest < MiniTest::Unit::TestCase
  def setup
    @text = "
status: incoming
#rsp: joe
 not: found
nice stuff"
    @rulset = Luftpost::Ruleset.new do 
      on :status do |object,command,value|
        object.send(command,value) # our basic typical usecase 
      end
    end
    @processor = Luftpost::Processor.new(@text,@rulset)
  end

  def test_clean_instructions_from_text
    assert_equal "not: found\nnice stuff", @processor.clean_text
  end

  def test_extract_matches
    assert_equal ["status: incoming", "#rsp: joe"], @processor.matches
  end

  def test_store_instuctions
    assert_equal({:status => "incoming", :rsp => "joe"}, @processor.instructions)
  end

  def test_calls_ruleset_proc_with_specific_object
    object = MiniTest::Mock.new
    object.expect(:send, "return", [:status,"incoming"])
    @processor.apply_to(object)
  end
end