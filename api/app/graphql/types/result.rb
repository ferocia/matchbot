# frozen_string_literal: true

class Types::Result < Types::Base::Object
  field :id, ID, null: false
  field :score, Float, null: true
  field :place, Integer, null: false
  field :team, Types::Team, null: false
  field :match, Types::Match, null: false

  def match
    Loaders::Record.for(Match).load(object.match_id)
  end

  def team
    Loaders::Record.for(Team).load(object.team_id)
  end
end
