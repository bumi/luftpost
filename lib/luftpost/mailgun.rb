require "yaml"
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

      params["attachment-count"].to_i.times do |i|
        self.attachments << params["attachment-#{i}"]
      end
    end

    def from_email
      self.from.to_s[/<(.+)>/,1] || self.from
    end
    def from_name
      self.from.to_s[/(.+) <.+>/,1]
    end
    def to_email
      self.to.to_s[/<(.+)>/,1] || self.to
    end
    def to_name
      self.to.to_s[/(.+) <.+>/,1]
    end
    def cc_email
      self.cc.to_s[/<(.+)>/,1] || self.cc
    end
    def cc_name
      self.cc.to_s[/(.+) <.+>/,1]
    end

    def verified?
      self.signature == OpenSSL::HMAC.hexdigest( OpenSSL::Digest::Digest.new('sha256'), Luftpost.config.mailgun_api_key.to_s, '%s%s' % [self.timestamp, self.token])
    end

    def clean_body_plain
      @clean_body_plain ||= Luftpost::Processor.new(self.body_plain, Luftpost.config.ruleset).clean_text
    end
    def clean_stripped_text
      @clean_stripped_text ||= Luftpost::Processor.new(self.stripped_text, Luftpost.config.ruleset).clean_text
    end
    def instructions_only?
      self.clean_stripped_text.empty?
    end

    def attributes
      {}.tap { |hash|
        MAILGUN_MAPPING.values.each do |attr|
          hash[attr] = self.send(attr)
        end
        hash[:clean_body_plain]    = self.clean_body_plain
        hash[:clean_stripped_text] = self.clean_stripped_text
      }
    end
    def to_yaml
      attributes.to_yaml
    end

  end
end