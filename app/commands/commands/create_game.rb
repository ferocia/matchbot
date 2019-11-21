# frozen_string_literal: true

class Commands::CreateGame
  def self.run(name:, emoji:)
    unicode = Emoji.find_by_unicode(emoji)
    emoji_alias = Emoji.find_by_alias(emoji)

    emoji_name = unicode&.name || emoji_alias&.name

    raise StandardError, "couldn't find emoji '#{emoji}'" unless emoji_name

    Game.create!(
      name: name,
      emoji_name: emoji_name,
      default_mean: 25.0,
      default_deviation: 25.0 / 3,
    )
  end
end
