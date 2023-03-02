# frozen_string_literal: true

class SlackController < ApplicationController
  ALLOWED_CHANNELS = %w[billiards gaming-smash-bros gaming-rocket-league towerfall fifa].freeze

  def webhook
    body = parsed_body

    return unless ALLOWED_CHANNELS.include?(body[:channel])

    text = case body[:command]
           when 'result'
             handle_result
           when 'leaderboard'
             handle_leaderboard
           when 'undo'
             handle_undo
           when 'players'
             handle_players_show
           when 'new_player'
             handle_players_add
           else
             # 'help' or unrecognized command
             generate_help_text
           end

    render json: { text: text, username: 'MatchBot' }
  rescue => e # rubocop:disable Style/RescueStandardError
    raise e if Rails.env.test?

    render json: { text: "ERROR: #{e.message}", username: 'MatchBot' }
  end

  private

  def parsed_body
    if params.require(:token) != ENV['SLACK_WEBHOOK_TOKEN']
      raise StandardError, 'Unauthenticated'
    end

    body = params.require(:text)
    split = body.gsub(/[[:space:]]/, ' ').strip.split(' ')
    emoji = split.first.gsub(':', '')

    command = split.second
    args = split[2..]

    {
      channel: params.require(:channel_name),
      emoji: emoji,
      command: command,
      args: args,
    }
  end

  def game
    body = parsed_body
    game = Game.find_by(emoji_name: body[:emoji])

    unless game
      raise StandardError, "Can't find game with emoji \`#{body[:emoji]}\`"
    end

    game
  end

  def handle_result
    body = parsed_body

    results = body[:args].map do |arg|
      parse_result(arg)
    end

    # make sure that all results have a score, or none do
    has_score_on_all = results.all? { |r| r[:score].present? }
    has_no_score_on_all = results.all? { |r| r[:score].nil? }

    unless has_score_on_all || has_no_score_on_all
      raise StandardError, "Can't mix scores and no scores on a match"
    end

    results = if has_score_on_all
                # sort them correctly if the score is provided
                results
                  .group_by { |r| r[:score] }
                  .sort_by { |k, _v| -k }
                  .each_with_index.map do |group, i|
                    _, group_results = group
                    place = i + 1
                    group_results.map { |r| r.merge(place: place) }
                  end.flatten
              else
                results.each_with_index.map { |r, i| r.merge(place: i + 1) }
              end

    match = Commands::CreateMatch.run(game_id: game.id, results: results)

    match.generate_text_response
  end

  # result looks like 'Name+Name:Score'
  def parse_result(result)
    names, score_string = result.split(':')
    score = score_string&.to_f
    names = names.split('+')

    players =
      names.map do |name|
        player = Player.find_by('name ilike ?', name)
        raise StandardError, "No player with name \`#{name}\`" unless player

        player.id
      end

    { score: score, players: players }
  end

  def generate_help_text
    <<~HELP
      *MatchBot Help*

      ```
      result name1+name2:score name3+name4:score
        - teams are joined by a +, score follows the :
        - teams can be one person (result name1:score)
        - score is optional (result name1+name2 name3+name4)
        - teams can have differing number of players (result name1+name2 name3)
        - if no scores, winner is first team given, second place is second, etc
        - if scores are provided the order doesn't matter
        - scores must be in a "highest is winner" format if provided (i.e. you'll need to invert a golf score)
      help
        - show this again
      leaderboard
        - show the leaderboard for the game
      players
        - show a list of all available players
      undo
        - revert the previous result entry
      new_player name
        - add a new player to the system.
        - new player isavailable for all games on matchbot
        - player names must be unique and are case insensitive
      ```
    HELP
  end

  def handle_leaderboard
    table = game.generate_text_leaderboard

    <<~TXT
      *Leaderboard for :#{game.emoji_name}: #{game.name}*

      ```
      #{table}
      ```
    TXT
  end

  def handle_undo
    match = game.matches.last

    match.undo!

    leaderboard = handle_leaderboard

    <<~TXT
      Last match undone. Current leaderboard:

      #{leaderboard}
    TXT
  end

  def handle_players_show
    body = parsed_body
    emoji = body[:emoji]

    names = Player.all.map(&:name).join("\n")

    <<~TXT
      Available Players:

      #{names}

      -----------------
      Add a new player with `:#{emoji}: new_player <name>`
    TXT
  end

  def handle_players_add
    body = parsed_body
    name = body[:args].first

    player = Player.create!(name: name)

    "Player #{player.name} created!"
  end
end
