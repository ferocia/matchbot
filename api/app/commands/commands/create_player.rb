# frozen_string_literal: true

class Commands::CreatePlayer
  def self.run(name:)
    Player.create(name: name)
  end
end
