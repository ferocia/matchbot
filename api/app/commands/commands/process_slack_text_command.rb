class Commands::ProcessSlackTextCommand
  def self.run(...)
    new(...).run
  end

  attr_reader :game, :emoji, :command, :args
  def initialize(game, text)
    @game = game
    parse_text(text)
  end

  def run
    case command
    when 'result'
      handle_result
    when 'leaderboard'
      handle_leaderboard
    when 'undo'
      handle_undo
    when 'players'
      handle_players_show
    when 'new_player', 'add'
      handle_players_add
    else
      # 'help' or unrecognized command
      send_help_text
    end
  end

  private

  def parse_text(text)
    split = text.gsub(/[[:space:]]/, ' ').strip.split(' ')
    @emoji = split[0].gsub(':', '')
    @command = split[1]
    @args = split[2..]
  end

  def send_help_text
    text = <<~HELP
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

    post_to_slack(text:)
  end

  def handle_result
    missing_names = []
    results = args.map do |result|
      names, score_string = result.split(':')
      score = score_string&.to_f
      names = names.split('+')

      players =
        names.map do |name|
          player = Player.find_by('name ilike ?', name)
          if player
            player.id
          else
            missing_names << name
            nil
          end
        end.compact

      { score: score, players: players }
    end

    if missing_names.present?
      post_to_slack(
        text: "The following player(s) couldn't be found: #{missing_names.join(',')}",
      )
      return
    end

    # make sure that all results have a score, or none do
    has_score_on_all = results.all? { |r| r[:score].present? }
    has_no_score_on_all = results.all? { |r| r[:score].nil? }

    unless has_score_on_all || has_no_score_on_all
      post_to_slack(text: "Can't mix scores and no scores on a match")
      return
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

    text = match.generate_text_response

    post_to_slack(text:)
  end

  def generate_leaderboard
    table = game.generate_text_leaderboard

    <<~TXT
      *Leaderboard for :#{game.emoji_name}: #{game.name}*

      ```
      #{table}
      ```
    TXT
  end

  def handle_leaderboard
    post_to_slack(text: generate_leaderboard)
  end

  def handle_undo
    match = game.matches.last

    match.undo!

    text = <<~TXT
      Last match undone. Current leaderboard:

      #{generate_leaderboard}
    TXT

    post_to_slack(text:)
  end

  def handle_players_show
    body = parsed_body
    emoji = body[:emoji]

    names = Player.all.map(&:name).join("\n")

    text = <<~TXT
      Available Players:

      #{names}

      -----------------
      Add a new player with `:#{emoji}: add <name>`
    TXT

    post_to_slack(text:)
  end

  def handle_players_add
    body = parsed_body
    name = body[:args].first

    player = Player.create!(name: name)

    "Player #{player.name} created!"
  end

  private

  def post_to_slack(text:, blocks: nil)
    Commands::PostToSlack.run(
      channel_id: game.slack_channel_id,
      text:,
      blocks:
    )
  end
end
