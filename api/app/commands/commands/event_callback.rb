class Commands::EventCallback
  def self.run(...)
    new(...).run
  end

  attr_reader :event
  attr_reader :game
  attr_reader :text

  def initialize(event)
    @event = event
    @text = event[:text].gsub(/[[:space:]]/, ' ').strip
  end

  def run
    return unless is_message?
    return if is_thread_response?

    emoji_name = emoji_from_message

    return if emoji_name.nil?

    @game = Game.find_by(emoji_name:, slack_channel_id: event[:channel])

    puts @game

    if game.nil?
      Command::PostToSlack.run(
        channel_id: event[:channel],
        text: "Couldn't find a game for emoji ':#{emoji_name}:' (#{emoji_name})",
        blocks: nil,
      )
      return
    end

    return if game.nil?

    Commands::ProcessSlackTextCommand.run(game, text)
  end

  private
  def is_thread_response?
    return true if event[:thread_ts].present?
  end

  def is_message?
    return event[:type] == "message"
  end

  def emoji_from_message
    if text =~ /^:([A-z0-9\-_]+):/
      $1
    end
  end
end
