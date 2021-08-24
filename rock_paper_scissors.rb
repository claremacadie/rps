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

  def initialize
    @record = []
  end

  def update(player_move)
    record << player_move.name
  end
end

class Move
  attr_reader :name, :beats

  MOVES = {
    'rock' => 'r', 'paper' => 'p', 'scissors' => 'sc',
    'spock' => 'sp', 'lizard' => 'l'
  }

  def rock?
    @name == 'rock'
  end

  def paper?
    @name == 'paper'
  end

  def scissors?
    @name == 'scissors'
  end

  def spock?
    @name == 'spock'
  end

  def lizard?
    @name == 'lizard'
  end

  def >(other_move)
    beats.include?(other_move.name)
  end

  def to_s
    @name
  end
end

class Rock < Move
  def initialize
    @name = "rock"
    @beats = ["scissors", "lizard"]
  end
end

class Paper < Move
  def initialize
    @name = "paper"
    @beats = ["rock", "spock"]
  end
end

class Scissors < Move
  def initialize
    @name = "scissors"
    @beats = ["paper", "lizard"]
  end
end

class Spock < Move
  def initialize
    @name = "spock"
    @beats = ["rock", "scissors"]
  end
end

class Lizard < Move
  def initialize
    @name = "lizard"
    @beats = ["paper", "spock"]
  end
end

class Player
  include Questionable
  attr_accessor :move, :name, :score, :history

  def initialize
    @score = 0
    @history = History.new
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
  def initialize
    @name = ask_open_question("What's your name?")
    super
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
    move_subclass = if Move::MOVES.keys.include?(choice)
                      choice.capitalize
                    else
                      Move::MOVES.key(choice).capitalize
                    end
    self.move = Kernel.const_get(move_subclass).new
  end
end

class Computer < Player
  attr_reader :personality, :moves

  def initialize
    super
  end

  def choose
    move_subclass = moves.sample.capitalize
    self.move = Kernel.const_get(move_subclass).new
  end
end

class R2D2 < Computer
  def initialize
    @name = 'R2D2'
    @personality = 'is always stuck between their move and a hard place'
    @moves = ['rock']
    super
  end
end

class Hal < Computer
  def initialize
    @name = 'Hal'
    @personality = 'is rather partial to a sharp object'
    @moves = ['paper', 'scissors', 'scissors', 'scissors', 'spock', 'lizard']
    super
  end
end

class Chappie < Computer
  def initialize
    @name = 'Chappie'
    @personality = 'is an all-rounder'
    @moves = Move::MOVES.keys
    super
  end
end

class Sonny < Computer
  def initialize
    @name = 'Sonny'
    @personality = 'is a traditionalist'
    @moves = ['rock', 'paper', 'scissors']
    super
  end
end

class Number5 < Computer
  def initialize
    @name = 'Number 5'
    @personality = 'embraces all things new'
    @moves = ['spock', 'lizard']
    super
  end
end

class RPSGame
  include Formattable
  include Questionable
  attr_accessor :computer
  attr_reader :human

  WINS_LIMIT = 10
  COMPUTERS_ABBREVIATIONS = {
    'R2D2' => 'r', 'Hal' => 'h', 'Chappie' => 'c',
    'Sonny' => 's', 'Number5' => 'n'
  }

  def initialize
    clear_screen
    display_welcome_message
    display_rules if show_rules?
    @human = Human.new
    set_opponent
  end

  def play
    loop do
      display_opening
      play_match
      display_match_winner
      display_move_history if show_move_history?
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

  def show_rules?
    ask_yes_no_question("Would you like to see the rules? (y/n)")
  end

  def display_rules
    break_line
    puts <<~RULES
      Scissors cuts Paper covers Rock crushes Lizard poisons Spock
      smashes Scissors decapitates Lizard eats Paper disproves Spock
      vaporizes Rock crushes Scissors.
    RULES
    break_line
  end

  def set_opponent
    answer = ask_yes_no_question(
      "Would you like to choose your opponent? (y/n) \n" \
      "(An opponent will be chosen at random if you select 'n')"
    )

    if answer
      choose_opponent
    else
      computer = COMPUTERS_ABBREVIATIONS.keys.sample
      @computer = Kernel.const_get(computer).new
    end
  end

  def choose_opponent
    opponent = ask_closed_question(
      "Please choose from:\n" \
      "(R)2D2, (H)al, (C)happie, (S)onny or (N)umber 5.",
      COMPUTERS_ABBREVIATIONS.keys + COMPUTERS_ABBREVIATIONS.values
    )

    assign_opponent(opponent)
    puts "Your opponent is #{computer.name}."
  end

  def assign_opponent(opponent)
    computer = if opponent.size == 1
                 COMPUTERS_ABBREVIATIONS.key(opponent)
               else
                 opponent.capitalize
               end
    @computer = Kernel.const_get(computer).new
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

  def play_match
    loop do
      make_moves
      update_score
      display_moves
      display_winner
      human.score
      computer.score
      break if human.score >= WINS_LIMIT || computer.score >= WINS_LIMIT
      display_scores
    end
  end

  def make_moves
    human.choose
    computer.choose
    update_history
    clear_screen
  end

  def update_history
    human.history.update(human.move)
    computer.history.update(computer.move)
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
    puts human.history
    puts
    puts "These were #{computer.name}'s moves: "
    puts computer.history
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

  def reset_variables
    set_opponent if choose_new_opponent?
    human.score = 0
    computer.score = 0
    human.history = []
    computer.history = []
  end

  def display_goodbye_message
    clear_screen
    puts "Thank you for playing Rock, Paper, Scissors, Spock, Lizard. Goodbye!"
  end
end

RPSGame.new.play
