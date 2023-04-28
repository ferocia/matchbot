class Commands::SlackSlash
  def self.run(...)
    new(...).run
  end

  attr_reader :slack_channel_id, :trigger, :args
  def initialize(slack_channel_id, arg)
    @slack_channel_id = slack_channel_id
    trigger, *args = arg.split(' ')
    @trigger = trigger
    @args = args
  end

  def run
    case trigger
    when 'new'
      raw_emoji_name, *name_parts = args
      name = name_parts.join(' ')
      emoji_name = raw_emoji_name.gsub(':', '')
      emoji_details = find_emoji_url(emoji_name)

      puts "Emoji: #{emoji_name}"
      puts "Name: #{name}"

      if emoji_details.nil?
        return { response_type: 'ephemeral', text: "Sorry, :#{emoji_name}: doesn't seem to be a custom Slack emoji, but also can't be found in Gemoji. There might be a different alias. This must be fixed manually."}
      end

      begin
        game = Game.create!(name:, emoji_name:, slack_channel_id:, **emoji_details)

        response = [
          "Success! :#{emoji_name}: #{name} created!",
        ]

        unless bot_is_channel_member?
          response.push("MatchBot is not a member of this channel, and commands won't work until you add it. Type `@Matchbot` in this channel to add.")
        end

        { response_type: 'in_channel', text: response.join("\n\n")}
      rescue => e
        puts e
        { response_type: 'ephemeral', text: "Couldn't create ':#{emoji_name}: #{name}' - maybe it already exists?" }
      end
    when 'help'
      help
    else
      { response_type: "ephemeral", text: ":x: Unknown command '#{trigger}'. Try `/matchbot help` to see what you can do." }
    end
  end

  private

  def help
    content = <<~EOF
      \`/matchbot new <emoji> <name>\`
        Creates a new game in the system

        Examples:
          \`/matchbot new :9ball: 9 Ball\`

    EOF

    { response_type: "ephemeral", text: content }
  end

  def find_emoji_url(emoji)
    return { slack_unaliased_name: emoji } if Emoji.find_by_alias(emoji)

    custom = custom_emoji[emoji]

    return nil if custom.nil?

    if custom.start_with?("alias:")
      actual = custom.gsub(/^alias:/, '')

      return find_emoji_url(actual)
    end

    { slack_emoji_url: custom }
  end

  def custom_emoji
    @result ||= begin
      headers = { 'Authorization' => "Bearer #{ENV["SLACK_TOKEN"]}" }
      result = HTTParty.get('https://slack.com/api/emoji.list', headers:)

      if result["ok"]
        result["emoji"]
      else
        nil
      end
    end
  end

  def bot_is_channel_member?
    headers = { 'Content-Type' => "application/json", 'Authorization' => "Bearer #{ENV["SLACK_TOKEN"]}" }
    body = {
      channel: slack_channel_id,
      limit: 1,
    }.to_json
    result = HTTParty.post('https://slack.com/api/emoji.list?', headers:, body:)

    result[:ok] # if the response returns false, the bot isn't a member
  end
end
