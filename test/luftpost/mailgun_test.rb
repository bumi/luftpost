# encoding: utf-8
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
      assert_equal ["thjs@amsterdam.com"], @mailgun.to_emails
    end
    def test_extract_to_names
      assert_equal ["Thjs Amsterdam"], @mailgun.to_names
    end
    def test_extract_cc_emails
      assert_equal ["cc@amsterdam.com"], @mailgun.cc_emails
    end
    def test_extract_cc_names
      assert_equal ["cc basti"], @mailgun.cc_names
    end

    def test_mulit_cc_and_to_receipients
      mailgun = Luftpost::Mailgun.new({"Cc" => "Lärs Brillert <lars@railslove.com>, Railslove Team <team@railslove.com>", "To" => 'Jenny de Lá Röck <rock@railslove.com>, freddy blitz <fraeddy.blitz@railslove.com>'})
      assert_equal ["rock@railslove.com", "fraeddy.blitz@railslove.com"], mailgun.to_emails
      assert_equal ["Jenny de La Rock", "freddy blitz"], mailgun.to_names
      assert_equal ["lars@railslove.com", "team@railslove.com"], mailgun.cc_emails
      assert_equal ["Lars Brillert", "Railslove Team"], mailgun.cc_names
    end
    # transliteration is a stupid hack because the mail maillist parser does not like umlauts: https://github.com/mikel/mail/issues/39
    def test_tansliterate_umlaut_values
      mailgun = Luftpost::Mailgun.new({"Cc" => "Lärs Brillert <lars@railslove.com>", "To" => 'Jenny de Lá Röck <rock@railslove.com>, fräddy blitz <fraeddy.blitz@railslove.com>'})
      assert_equal ["rock@railslove.com", "fraeddy.blitz@railslove.com"], mailgun.to_emails
      assert_equal ["Jenny de La Rock", "fraddy blitz"], mailgun.to_names
      assert_equal ["lars@railslove.com"], mailgun.cc_emails
      assert_equal ["Lars Brillert"], mailgun.cc_names
    end

    def test_allows_nil_values
      mailgun = Luftpost::Mailgun.new({})
      assert_equal nil, mailgun.from_email
      assert_equal nil, mailgun.from_name
      assert_equal [], mailgun.to_emails
      assert_equal [], mailgun.to_names
      assert_equal [], mailgun.cc_emails
      assert_equal [], mailgun.cc_names
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