# frozen_string_literal: true

class Commands::CreateGame
  def self.run(name:, emoji:, slack_channel_id:)
    unicode = Emoji.find_by_unicode(emoji)

    emoji_name = unicode&.name || emoji

    Game.create!(
      name:,
      emoji_name:,
      slack_channel_id:,
      default_mean: 25.0,
      default_deviation: 25.0 / 3,
    )
  end
end
