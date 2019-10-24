# frozen_string_literal: true

game = Game.create!(
  name: 'Billiards',
  default_mean: 25,
  default_deviation: 25.0 / 3,
)

p1 = Player.create!(name: 'David')
p2 = Player.create!(name: 'Tyson')
p3 = Player.create!(name: 'Ev')
p4 = Player.create!(name: 'Anson')

t1 = Team.create!(players: [p1, p2])
t2 = Team.create!(players: [p3, p4])

m1 = Match.create!(game: game, teams: [t1, t2])
m1.results.create!(team: t1, score: 10)
m1.results.create!(team: t2, score: 0)

m2 = Match.create!(game: game, teams: [t1, t2])
m2.results.create!(team: t1, score: 0)
m2.results.create!(team: t2, score: 10)

m3 = Match.create!(game: game, teams: [t1, t2])
m3.results.create!(team: t1, score: 40)
m3.results.create!(team: t2, score: 0)
