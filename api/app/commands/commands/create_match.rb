# frozen_string_literal: true

class Commands::CreateMatch
  # game_id => Game.id
  # results => [{
  #   players: [Player.id],
  #   score: ?Float,
  #   place: ?Integer
  # }],
  # post_to_slack: Boolean
  def self.run(game_id:, results:)
    game = Game.find(game_id)

    results = results.map do |result|
      players = Player.find(result[:players])
      team = Team.find_or_create_by_players(players)
      # TODO: manually add a place to all of these if it doesn't exist
      { team: team, score: result[:score], place: result[:place] }
    end

    players = results.map { |r| r[:team].players }.flatten
    game.ensure_ratings_created_for!(players)

    ActiveRecord::Base.transaction do
      match = Match.create!(game: game)
      match.results.create(results)
      match.calculate_ratings_for_players!

      match
    end
  end
end
