require "test_helper"

class Luftpost::MailgunTest < MiniTest::Unit::TestCase

  class EmailData < self
    def setup
      @mailgun = Luftpost::Mailgun.new(MAILGUN_HASH)
    end
    mapping_attributes = MAILGUN_MAPPING.dup
    mapping_attributes.delete("References")
    mapping_attributes.each do |mailgun, attr|
      define_method "test_#{attr}_mapping" do
        assert @mailgun.respond_to?(attr), "@mailgun does not respond to #{attr}"
        assert_equal MAILGUN_HASH[mailgun], @mailgun.send(attr)
      end
    end
    def test_attachments_defaults_to_empty_array
      assert_equal [], @mailgun.attachments
    end

    def test_split_referenced_message_ids_to_array
      assert_equal ["<ref1@gmail.com>","<ref2@gmail.com>"], @mailgun.referenced_message_ids
    end

    def fallback_if_full_to_attribute_is_not_present
      m = Luftpost::Mailgun.new({"To" => "thjs@amsterdam.com", "From" => "michael@railslove.com"})
      assert_equal "thjs@amsterdam.com", m.to_email
      assert_equal nil, m.to_name
    end
    def fallback_if_full_from_attribute_is_not_present
      m = Luftpost::Mailgun.new({"To" => "thjs@amsterdam.com", "From" => "michael@railslove.com"})
      assert_equal "michael@railslove.com", @mailgun.from_email
      assert_equal nil, m.from_name
    end
  end

  class Extraction < self
    def setup
      @mailgun = Luftpost::Mailgun.new(MAILGUN_HASH)
    end
    
    def test_extract_from_email
      assert_equal "michael@railslove.com", @mailgun.from_email
    end
    def test_extract_from_name
      assert_equal "Michael Koeln", @mailgun.from_name
    end
    def test_extract_to_email
      assert_equal "thjs@amsterdam.com", @mailgun.to_email
    end
    def test_extract_to_name
      assert_equal "Thjs Amsterdam", @mailgun.to_name
    end
    def test_extract_cc_email
      assert_equal "cc@amsterdam.com", @mailgun.cc_email
    end
    def test_extract_cc_name
      assert_equal "cc basti", @mailgun.cc_name
    end

    def test_allows_nil_values
      mailgun = Luftpost::Mailgun.new({})
      assert_equal nil, mailgun.from_email
      assert_equal nil, mailgun.from_name
      assert_equal nil, mailgun.to_email
      assert_equal nil, mailgun.to_name
      assert_equal nil, mailgun.cc_email
      assert_equal nil, mailgun.cc_name
    end
  end  

  class TextProccessing < self
    def setup
      Luftpost.config.ruleset.on :status do |object,command,value|
        value
      end
      @mailgun_for_text_parsing = Luftpost::Mailgun.new({"stripped-text" => "status: foo", "body-plain" => "status: foo\r\n\r\n--\nmichael"})
    end

    def test_clean_stripped_text
      assert_equal "", @mailgun_for_text_parsing.clean_stripped_text
    end
    def test_clean_body_plain
      assert_equal "--\nmichael", @mailgun_for_text_parsing.clean_body_plain
    end
    def test_instructions_only_check
      assert @mailgun_for_text_parsing.instructions_only?
    end
  end

  class Attachments < self
    def setup
      @mailgun = Luftpost::Mailgun.new({"attachment-count" => 2, "attachment-1" => 1, "attachment-2" => 2})
    end
    
    def test_stores_attachments_to_attachments_array
      assert_equal [1,2], @mailgun.attachments
    end
  end

  class Attributes < self
    def setup
      @mailgun = Luftpost::Mailgun.new(MAILGUN_HASH)
      @hash = {}
      MAILGUN_MAPPING.each do |mailgun_name, attr_name|
        @hash[attr_name] = MAILGUN_HASH[mailgun_name]
      end
      @hash[:clean_body_plain] = @mailgun.clean_body_plain
      @hash[:clean_stripped_text] = @mailgun.clean_stripped_text
      @hash[:referenced_message_ids] = ["<ref1@gmail.com>","<ref2@gmail.com>"]
    end

    def test_retuns_an_attributes_hash
      assert_equal(@hash, @mailgun.attributes)
    end

    def test_retuns_an_attributes_yaml
      assert_equal(@hash.to_yaml, @mailgun.to_yaml)
    end
  end
end