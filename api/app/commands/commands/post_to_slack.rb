# frozen_string_literal: true

class Commands::PostToSlack
  def self.run(channel_id:, text:, blocks: nil)
    headers = { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{ENV["SLACK_TOKEN"]}" }

    body = { channel: channel_id, text: }
    if blocks.present?
      body[:blocks] = blocks
    end

    begin
      r = HTTParty.post("https://slack.com/api/chat.postMessage", body: body.to_json, headers: headers)
      (r.code == 200)
    rescue # rubocop:disable Style/RescueStandardError
      false
    end
  end
end
