# frozen_string_literal: true

# Note: This isn't exposed anywhere in the code. It's for, like, emergency
# situations to fix up old results that have newer results on top of them
# It will result in incorrect times attributed to the ratings :(
# The "undo" command should be favoured if no other results have been entered
class Commands::RemoveMatch
  # The general strategy is:
  # - Remove all rating events after (and including) the match in question
  # - Reset all Ratings to the most recent RatingEvent
  # - Remove the results for the match
  # - Remove the match
  # - Get all the matches after the match in question, and, with them sorted by
  #   created_at ascending, re-calculate the player ratings for each of them
  def self.run(match_id:)
    match = Match.find(match_id)

    game = match.game

    rating_events = RatingEvents
      .where(game: game)
      .where('created_at >= ?', match.created_at)

    ratings = Ratings.where(id: rating_events.pluck(:rating_id))

    rating_events.destroy_all

    ratings.each(&:reset_to_last_event!)

    match.results.destroy_all
    match.destroy

    game.matches
      .where('created_at > ?', match.created_at)
      .order(created_at: :asc)
      .each(&:calculate_ratings_for_players!)
  end
end
