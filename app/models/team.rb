# frozen_string_literal: true

class Team < ApplicationRecord
  has_and_belongs_to_many :players, join_table: :players_teams
  has_and_belongs_to_many :matches, join_table: :team_matches

  has_many :results

  def self.find_by_players(players)
    candidates =
      Team.joins(:players)
        .includes(:players_teams)
        .where(players: { id: players.map(&:id) })
        .group('teams.id')

    candidates.find do |candidate|
      p = candidate.players

      p.map(&:id).sort == players.map(&:id).sort
    end
  end

  def self.find_or_create_by_players(players)
    t = find_by_players(players)
    return t if t.present?

    Team.create!(players: players)
  end
end
