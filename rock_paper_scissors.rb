# rock_paper_scissors.rb

module Formattable
  def break_line
    puts "------------------------------------------------------------------"
  end

  def clear_screen
    system('clear')
  end
end

module Questionable
  YES_NO_OPTIONS = %w(y yes n no)
  def ask_yes_no_question(question)
    answer = ''
    loop do
      puts question
      answer = gets.chomp.downcase.strip
      break if YES_NO_OPTIONS.include? answer
      puts "Sorry, must be y or n."
    end

    answer[0] == 'y'
  end

  def ask_open_question(question)
    answer = ""
    loop do
      puts question
      answer = gets.chomp.strip
      break unless answer.empty?
      puts "Sorry, must enter a value."
    end
    answer
  end

  def ask_closed_question(question, options)
    downcase_options = options.map(&:downcase)
    answer = ''
    loop do
      puts question
      answer = gets.chomp.downcase.strip
      break if downcase_options.include?(answer)
      puts "Sorry, invalid choice."
    end
    answer
  end
end

class History
  attr_accessor :record
  attr_reader :player1, :player2

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @record = { @player1 => [], @player2 => [] }
  end

  def update(player1_move, player2_move)
    record[player1] << player1_move.value
    record[player2] << player2_move.value
  end

  def player_record(player)
    record[player].join(", ")
  end
end

class Move
  attr_reader :value

  MOVES = {
    'rock' => 'r', 'paper' => 'p', 'scissors' => 'sc',
    'spock' => 'sp', 'lizard' => 'l'
  }

  def initialize(value)
    @value = value
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def scissors?
    @value == 'scissors'
  end

  def spock?
    @value == 'spock'
  end

  def lizard?
    @value == 'lizard'
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def >(other_move)
    rock? && (other_move.scissors? || other_move.lizard?) ||
      paper? && (other_move.rock? || other_move.spock?) ||
      scissors? && (other_move.paper? || other_move.lizard?) ||
      spock? && (other_move.rock? || other_move.scissors?) ||
      lizard? && (other_move.paper? || other_move.spock?)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def to_s
    @value
  end
end

class Player
  include Questionable
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end

  def increment_score
    self.score += 1
  end

  def point_string
    self.score == 1 ? "point" : "points"
  end

  def reset_variables
    self.score = 0
  end
end

class Human < Player
  def set_name
    self.name = ask_open_question("What's your name?")
  end

  def choose
    choice = ask_closed_question(
      "Please choose (r)ock, (p)aper, (sc)issors, (sp)ock or (l)izard:",
      Move::MOVES.keys + Move::MOVES.values
    )
    assign_choice_to_move(choice)
  end

  private

  def assign_choice_to_move(choice)
    if Move::MOVES.keys.include?(choice)
      self.move = Move.new(choice)
    elsif Move::MOVES.values.include?(choice)
      self.move = Move.new(Move::MOVES.key(choice))
    else
      false
    end
  end
end

class Computer < Player
  attr_reader :personality

  COMPUTERS_ABBREVIATIONS = {
    'R2D2' => 'r', 'Hal' => 'h', 'Chappie' => 'c',
    'Sonny' => 's', 'Number 5' => 'n'
  }

  COMPUTERS_PERSONALITIES = {
    'R2D2' => 'is always stuck between their move and a hard place',
    'Hal' => 'is rather partial to a sharp object',
    'Chappie' => 'is an all-rounder',
    'Sonny' => 'is a traditionalist',
    'Number 5' => 'embraces all things new'
  }

  COMPUTERS_MOVES = {
    'R2D2' => ['rock'],
    'Hal' => ['paper', 'scissors', 'scissors', 'scissors', 'spock', 'lizard'],
    'Chappie' => Move::MOVES.keys,
    'Sonny' => ['rock', 'paper', 'scissors'],
    'Number 5' => ['spock', 'lizard']
  }

  def initialize
    super
    @personality = COMPUTERS_PERSONALITIES[name]
  end

  def set_name
    answer = ask_yes_no_question(
      "Would you like to choose your opponent? (y/n) \n" \
      "(An opponent will be chosen at random if you select 'n')"
    )

    if answer == true
      choose_opponent
    else
      self.name = COMPUTERS_ABBREVIATIONS.keys.sample
    end
  end

  def choose
    self.move = Move.new(COMPUTERS_MOVES[name].sample)
  end

  private

  def choose_opponent
    opponent = ask_closed_question(
      "Please choose from:\n" \
      "(R)2D2, (H)al, (C)happie, (S)onny or (N)umber 5.",
      COMPUTERS_ABBREVIATIONS.keys + COMPUTERS_ABBREVIATIONS.values
    )

    assign_opponent(opponent)
    puts "Your opponent is #{name}."
  end

  def assign_opponent(opponent)
    if COMPUTERS_ABBREVIATIONS.keys.include?(opponent.capitalize)
      self.name = opponent.capitalize
    else COMPUTERS_ABBREVIATIONS.values.include?(opponent)
      self.name = COMPUTERS_ABBREVIATIONS.key(opponent)
    end
  end
end

class RPSGame
  include Formattable
  include Questionable
  attr_accessor :computer, :history
  attr_reader :human

  WINS_LIMIT = 10

  def initialize
    clear_screen
    display_welcome_message
    display_rules if show_rules? == true
    @human = Human.new
    @computer = Computer.new
    @history = History.new(human.name, computer.name)
  end

  def play
    loop do
      display_opening
      play_match
      display_match_winner
      display_move_history if show_move_history? == true
      break unless play_again?
      reset_variables
    end
    display_goodbye_message
  end

  private

  def display_welcome_message
    clear_screen
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard!"
  end

  def display_opening
    clear_screen
    puts "You are playing Rock, Paper, Scissors, Spock, Lizard."
    puts "The first to win #{WINS_LIMIT} games is the champion."
    break_line
    puts "You shall be playing against #{computer.name}."
    puts "#{computer.name} #{computer.personality}."
    break_line
  end

  def show_rules?
    ask_yes_no_question("Would you like to see the rules? (y/n)")
  end

  def display_rules
    break_line
    puts "Scissors cuts Paper covers Rock crushes Lizard poisons Spock \n" \
      "smashes Scissors decapitates Lizard eats Paper disproves Spock \n" \
      "vaporizes Rock crushes Scissors."
    break_line
  end

  def play_match
    loop do
      make_moves
      update_score
      display_moves
      display_winner
      break if human.score >= WINS_LIMIT || computer.score >= WINS_LIMIT
      display_scores
    end
  end

  def make_moves
    human.choose
    computer.choose
    history.update(human.move, computer.move)
    clear_screen
  end

  def update_score
    if human.move > computer.move
      human.increment_score
    elsif computer.move > human.move
      computer.increment_score
    end
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif computer.move > human.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
    break_line
  end

  def display_scores
    puts "#{human.name} has #{human.score} #{human.point_string}."
    puts "#{computer.name} has #{computer.score} #{computer.point_string}."
    break_line
    puts "Remember, the first to #{WINS_LIMIT} is the champion."
  end

  def display_match_winner
    if human.score > computer.score
      puts "#{human.name} won #{WINS_LIMIT} games and is the CHAMPION!"
    else
      puts "#{computer.name} won #{WINS_LIMIT} games and is the CHAMPION!"
    end
    break_line
  end

  def show_move_history?
    ask_yes_no_question(
      "Would you like to see the moves that were made in the match? (y/n)"
    )
  end

  def display_move_history
    clear_screen
    puts "These were #{human.name}'s moves:"
    puts fetch_history(human.name)
    puts
    puts "These were #{computer.name}'s moves: "
    puts fetch_history(computer.name)
    puts
  end

  def fetch_history(player)
    history.player_record(player)
  end

  def play_again?
    ask_yes_no_question("Would you like to play again? (y/n)")
  end

  def choose_new_opponent?
    ask_yes_no_question(
      "Would you like a new opponent for the next match? (y/n)"
    )
  end

  def reset_opponent
    self.computer = Computer.new
  end

  def reset_variables
    reset_opponent if choose_new_opponent? == true
    human.score = 0
    computer.score = 0
    self.history = History.new(human.name, computer.name)
  end

  def display_goodbye_message
    clear_screen
    puts "Thank you for playing Rock, Paper, Scissors, Spock, Lizard. Goodbye!"
  end
end

RPSGame.new.play
