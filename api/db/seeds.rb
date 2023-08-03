# frozen_string_literal: true

smash = Game.create!(
  name: 'Super Smash Bros',
  emoji_name: 'smash',
  default_mean: 25,
  default_deviation: 25.0 / 3,
)

eight_ball = Game.create!(
  name: 'Billiards',
  emoji_name: '8ball',
  default_mean: 25,
  default_deviation: 25.0 / 3,
)

table_tennis = Game.create!(
  name: 'Table Tennis',
  emoji_name: 'ping_pong',
  default_mean: 25,
  default_deviation: 25.0 / 3,
)

games = [eight_ball, table_tennis]

p1 = Player.create!(name: 'David')
p2 = Player.create!(name: 'Tyson')
p3 = Player.create!(name: 'Ev')
p4 = Player.create!(name: 'Anson')
p5 = Player.create!(name: 'Gally')

def create_result(first, second)
  [{
    players: [first.id],
    place: 1,
  }, {
    players: [second.id],
    place: 2,
  }]
end

games.each do |game|

  Commands::CreateMatch.run(game_id: game.id, results: create_result(p1, p2))
  Commands::CreateMatch.run(game_id: game.id, results: create_result(p1, p3))
  Commands::CreateMatch.run(game_id: game.id, results: create_result(p1, p4))
  Commands::CreateMatch.run(game_id: game.id, results: create_result(p1, p5))
  
  Commands::CreateMatch.run(game_id: game.id, results: create_result(p2, p3))
  Commands::CreateMatch.run(game_id: game.id, results: create_result(p2, p4))
  Commands::CreateMatch.run(game_id: game.id, results: create_result(p2, p5))
  
  Commands::CreateMatch.run(game_id: game.id, results: create_result(p3, p4))
  Commands::CreateMatch.run(game_id: game.id, results: create_result(p3, p5))
  
  Commands::CreateMatch.run(game_id: game.id, results: create_result(p4, p5))
end
