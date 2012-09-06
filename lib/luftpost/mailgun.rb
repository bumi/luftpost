require "yaml"
require "mail"
require "i18n"
module Luftpost
  class Mailgun
    attr_accessor :params, :attachments
    MAILGUN_MAPPING = {
      "Message-Id"        => :message_id,
      "References"        => :referenced_message_ids, # referenced e-mail ids
      "In-Reply-To"       => :in_reply_to_id,
      "message-headers"   => :headers, # email headers
      "recipient"         => :recipient, # recipient of the message as reported by MAIL TO during SMTP chat.
      "sender"            => :sender, # sender of the message as reported by MAIL FROM during SMTP chat. Note: this value may differ from From MIME header.
      "To"                => :to, # full to field
      "From"              => :from, # sender of the message as reported by From message header, for example “Bob Lee <blee@mailgun.net>”.
      "Cc"                => :cc, # cc field
      "Subject"           => :subject,
      "stripped-html"     => :stripped_html, # HTML version of the message, without quoted parts.
      "stripped-text"     => :stripped_text, # text version of the message without quoted parts and signature block (if found).
      "body-plain"        => :body_plain, # text version of the email. This field is always present. If the incoming message only has HTML body, Mailgun will create a text representation for you.
      "body-html"         => :body_html, # HTML version of the message, if message was multipart. Note that all parts of the message will be posted, not just text/html. For instance if a message arrives with “foo” part it will be posted as “body-foo”.
      "stripped-signature"=> :stripped_signature, # the signature block stripped from the plain text message (if found).
      "signature"         => :signature,
      "token"             => :timestamp,
      "timestamp"         => :token
    }
    attr_accessor(*MAILGUN_MAPPING.values)

    def initialize(params)
      self.params = params
      MAILGUN_MAPPING.each do |mailgun, attr|
        self.send("#{attr}=", params[mailgun])
      end
      self.referenced_message_ids   = params["References"].to_s.split(" ")
      self.attachments              = []

      (1..params["attachment-count"].to_i).each do |i|
        self.attachments << params["attachment-#{i}"]
      end
    end

    # transliteration in the following is a stupid hack because the mail maillist parser does not like umlauts: https://github.com/mikel/mail/issues/39
    def from_email
      @from_email ||= Mail::AddressList.new(I18n.transliterate(self.from.to_s)).addresses.map(&:address).first
    end
    def from_name
      @from_name ||= Mail::AddressList.new(I18n.transliterate(self.from.to_s)).addresses.map(&:name).first
    end
    def to_emails
      @to_emails ||= Mail::AddressList.new(I18n.transliterate(self.to.to_s)).addresses.map(&:address)
    end
    def to_names
      @to_names ||= Mail::AddressList.new(I18n.transliterate(self.to.to_s)).addresses.map(&:name)
    end
    def cc_emails
      @cc_emails ||= Mail::AddressList.new(I18n.transliterate(self.cc.to_s)).addresses.map(&:address)
    end
    def cc_names
      @cc_names ||= Mail::AddressList.new(I18n.transliterate(self.cc.to_s)).addresses.map(&:name)
    end

    def verified?
      self.signature == OpenSSL::HMAC.hexdigest( OpenSSL::Digest::Digest.new('sha256'), Luftpost.config.mailgun_api_key.to_s, '%s%s' % [self.timestamp, self.token])
    end

    def attributes
      {}.tap { |hash|
        MAILGUN_MAPPING.values.each do |attr|
          hash[attr] = self.send(attr)
        end
      }
    end
    def to_yaml
      attributes.to_yaml
    end

  end
end