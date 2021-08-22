# rock_paper_scissors.rb

module Question
  def yes_no_question(question)
    answer = ''
    loop do
      puts question
      answer = gets.chomp.downcase.strip
      break if ['y', 'n'].include? answer
      puts "Sorry, must be y or n."
    end

    return true if answer == 'y'
    return false if answer == 'n'
  end

  def open_question(question)
    answer = ""
    loop do
      puts question
      answer = gets.chomp.strip
      break unless answer.empty?
      puts "Sorry, must enter a value."
    end
    answer
  end

  def closed_question(question, options)
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
    @player1 = player1.to_sym
    @player2 = player2.to_sym
    @record = { @player1 => [], @player2 => [] }
  end

  def update(player1_move, player2_move)
    record[player1] << player1_move.value
    record[player2] << player2_move.value
  end

  def player_record(player)
    record[player.to_sym].join(", ")
  end
end

class Move
  attr_reader :value

  VALUES_ABBREVIATIONS = {
    'r' => 'rock', 'p' => 'paper', 'sc' => 'scissors',
    'sp' => 'spock', 'l' => 'lizard'
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

  def >(other_move)
    rock? && (other_move.scissors? || other_move.lizard?) ||
      paper? && (other_move.rock? || other_move.spock?) ||
      scissors? && (other_move.paper? || other_move.lizard?) ||
      spock? && (other_move.rock? || other_move.scissors?) ||
      lizard? && (other_move.paper? || other_move.spock?)
  end

  def to_s
    @value
  end
end

class Player
  include Question
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
    self.name = open_question("What's your name?")
  end

  def assign_choice_to_move(choice)
    if Move::VALUES_ABBREVIATIONS.values.include?(choice)
      self.move = Move.new(choice)
    elsif Move::VALUES_ABBREVIATIONS.keys.include?(choice)
      self.move = Move.new(Move::VALUES_ABBREVIATIONS[choice])
    else
      false
    end
  end

  def choose
    choice = closed_question(
      "Please choose (r)ock, (p)aper, (sc)issors, (sp)ock or (l)izard:",
      Move::VALUES_ABBREVIATIONS.keys + Move::VALUES_ABBREVIATIONS.values
    )
    assign_choice_to_move(choice)
  end
end

class Computer < Player
  attr_reader :personality

  COMPUTERS_ABBREVIATIONS = {
    'r' => 'R2D2', 'h' => 'Hal', 'c' => 'Chappie',
    's' => 'Sonny', 'n' => 'Number 5'
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
    'Chappie' => Move::VALUES_ABBREVIATIONS.values,
    'Sonny' => ['rock', 'paper', 'scissors'],
    'Number 5' => ['spock', 'lizard']
  }

  def initialize
    super
    @personality = COMPUTERS_PERSONALITIES[name]
  end

  def assign_opponent(opponent)
    if COMPUTERS_ABBREVIATIONS.values.include?(opponent)
      self.name = opponent.capitalize
    elsif COMPUTERS_ABBREVIATIONS.keys.include?(opponent)
      self.name = COMPUTERS_ABBREVIATIONS[opponent]
    else
      false
    end
  end

  def choose_opponent
    opponent = closed_question(
      "Please choose from:\n" \
      "(R)2D2, (H)al, (C)happie, (S)onny or (N)umber 5.",
      COMPUTERS_ABBREVIATIONS.keys + COMPUTERS_ABBREVIATIONS.values
    )

    assign_opponent(opponent)
    puts "Your opponent is #{name}."
  end

  def set_name
    answer = yes_no_question(
      "Would you like to choose your opponent? (y/n) \n" \
      "(An opponent will be chosen at random if you select 'n'.)"
    )

    if answer == true
      choose_opponent
    else
      self.name = COMPUTERS_ABBREVIATIONS.values.sample
    end
  end

  def choose
    self.move = Move.new(COMPUTERS_MOVES[name].sample)
  end
end

class RPSGame
  include Question
  attr_accessor :computer, :history
  attr_reader :human

  WINS_LIMIT = 3

  def initialize
    clear_screen
    @human = Human.new
    @computer = Computer.new
    @history = History.new(human.name, computer.name)
  end

  def break_line
    puts "------------------------------------------------------------------"
  end

  def display_welcome_message
    clear_screen
    puts "You are playing Rock, Paper, Scissors, Spock, Lizard!"
    puts "The first to win #{WINS_LIMIT} games is the champion."
    break_line
    puts "You shall be playing against #{computer.name}."
    puts "#{computer.name} #{computer.personality}."
    break_line
  end

  def display_goodbye_message
    clear_screen
    puts "Thank you for playing Rock, Paper, Scissors, Spock, Lizard. Goodbye!"
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

  def update_score
    if human.move > computer.move
      human.increment_score
    elsif computer.move > human.move
      computer.increment_score
    end
  end

  def play_again?
    yes_no_question("Would you like to play again? (y/n)")
  end

  def make_moves
    human.choose
    computer.choose
    history.update(human.move, computer.move)
    clear_screen
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

  def display_match_winner
    if human.score > computer.score
      puts "#{human.name} won #{WINS_LIMIT} games and is the CHAMPION!"
    else
      puts "#{computer.name} won #{WINS_LIMIT} games and is the CHAMPION!"
    end
    break_line
  end

  def reset_variables
    reset_opponent if choose_new_opponent? == true
    human.score = 0
    computer.score = 0
    self.history = History.new(human.name, computer.name)
  end

  def show_move_history?
    yes_no_question(
      "Would you like to see the moves that were made in the match? (y/n)"
    )
  end

  def display_move_history
    clear_screen
    puts "These were #{human.name}'s moves:"
    puts history.player_record(human.name)
    puts
    puts "These were #{computer.name}'s moves: "
    puts history.player_record(computer.name)
    puts
  end

  def clear_screen
    system('clear')
  end

  def choose_new_opponent?
    yes_no_question(
      "Would you like to choose a new opponent for the next match? (y/n)"
    )
  end

  def reset_opponent
    self.computer = Computer.new
  end

  def play
    loop do
      display_welcome_message
      play_match
      display_match_winner
      display_move_history if show_move_history? == true
      break unless play_again?
      reset_variables
    end
    display_goodbye_message
  end
end

RPSGame.new.play
