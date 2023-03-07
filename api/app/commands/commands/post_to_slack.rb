# frozen_string_literal: true

class Commands::PostToSlack
  def self.run(webhook_url:, message:)
    headers = { 'Content-Type' => 'application/json' }
    body = { text: message }

    begin
      r = HTTParty.post(webhook_url, body: body.to_json, headers: headers)
      (r.code == 200)
    rescue # rubocop:disable Style/RescueStandardError
      false
    end
  end
end
