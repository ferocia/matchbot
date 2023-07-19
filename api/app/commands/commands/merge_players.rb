# frozen_string_literal: true

class Commands::MergePlayers
  def self.run(to_remain:, to_destroy:)
    Player.transaction do
      # upate all the teams to include the old player instead
      to_destroy.teams.each do |team|
        p = team.players.select { |p| p != to_destroy }
        p << to_remain

        team.players = p
        team.save!
      end

      # update all the ratings for this player
      to_destroy.ratings.update(player: to_remain)

      to_destroy.destroy!
    end
  end
end
