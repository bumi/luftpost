require "json"
module Luftpost
  class Route
    attr_accessor :description, :created_at, :actions, :priority, :expression, :id, :response, :response_json

    def initialize(args)
      args.each do |attr, value|
        self.send("#{attr}=",value) if self.respond_to?("#{attr}=")
      end
    end

    def create
      uri = URI.parse(Luftpost.config.mailgun.api_url)
      post = Net::HTTP::Post.new(uri.path)
      post.set_form_data(self.to_params)

      post.basic_auth(Luftpost.config.mailgun.user, Luftpost.config.mailgun.api_key)

      # make request
      req = Net::HTTP.new(uri.host, uri.port)

      # use SSL if applicable
      req.use_ssl = true if uri.scheme == "https"

      # push it through
      response = req.start { |http| http.request(post) }
      self.response = response.body
      self.response_json = JSON.parse(self.response)
      self.id = self.response_json["route"]["id"] if self.response_json["route"]
    end

    def to_params
      {
        "description" => self.description,
        "priority"    => self.priority,
        "expression"  => self.expression,
        "action"    => self.actions # no this must really be called action
      }
    end
  end
end