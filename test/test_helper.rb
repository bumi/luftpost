require 'luftpost'
require 'bundler/setup'
require 'minitest/mock'
require 'minitest/autorun'
require 'webmock/minitest'


# duplicate from the mailgun class for tests
MAILGUN_MAPPING= {
  "Message-Id"        => :message_id,
  "References"        => :referenced_message_ids,
  "In-Reply-To"       => :in_reply_to_id,
  "message-headers"   => :headers,
  "recipient"         => :recipient,
  "sender"            => :sender,
  "To"                => :to,
  "From"              => :from,
  "Cc"                => :cc,
  "Subject"           => :subject,
  "stripped-html"     => :stripped_html,
  "stripped-text"     => :stripped_text,
  "body-plain"        => :body_plain,
  "body-html"         => :body_html,
  "stripped-signature"=> :stripped_signature,
  "signature"         => :signature,
  "token"             => :timestamp,
  "timestamp"         => :token
}

MAILGUN_HASH = {
  "Message-Id"        => "<msgid@railslove.com>",
  "References"        => "<ref1@gmail.com>\t<ref2@gmail.com>",
  "In-Reply-To"       => "<CAHkasdTv2Hv2w40FejhhNbUSMzA0SN8_9thPmeew1pdhc9yGHw@mail.gmail.com>",
  "message-headers"   => "",
  "recipient"         => "company@dealbase.vc",
  "sender"            => "michael@railslove.com",
  "To"                => "Thjs Amsterdam <thjs@amsterdam.com>",
  "From"              => "Michael Koeln <michael@railslove.com>",
  "Cc"                => "cc basti <cc@amsterdam.com>",
  "Subject"           => "hello amsterdam",
  "stripped-html"     => "<html><head></head><body>Hey Thjs,</body></html>",
  "stripped-text"     => "Hey Thjs,",
  "body-plain"        => "Hey Thjs,\nThanks!\r\n\r\nMichael",
  "body-html"         => "<html><head></head><body>Hey Thjs,<br />Thanks!\r\n\r\nMichael</body></html>",
  "stripped-signature"=> "Thanks!\r\n\r\nMichael",
  "signature"         => "8faa4f0a4954967dabdebc6d6f5a6058c987abec34d7e599804607ab11c5a226",
  "token"             => "8wp7i3xujhyiywfsk5ieoq-b2nnbobu65-q39t-ywhjljz7363",
  "timestamp"         => "1339643224"
}