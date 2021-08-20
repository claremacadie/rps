# rock_paper_scissors.rb

class History
  attr_accessor :round, :record
  attr_reader :player_1, :player_2

  def initialize(player_1, player_2)
    @player_1 = player_1.to_sym
    @player_2 = player_2.to_sym
    @round = 1
    @record = {@player_1 => {round => []}, @player_2 => {round => []}}
  end

  def round
    "Round_#{@round}".to_sym
  end

  def update(player_1_move, player_2_move)
    record[player_1][round] << player_1_move.value
    record[player_2][round] << player_2_move.value
  end

  def set_next_round
    @round += 1
    record[player_1][round] = []
    record[player_2][round] = []
  end
end

class Move
  attr_reader :value
  VALUES = %w(rock paper scissors spock lizard).freeze
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
    rock? && ( other_move.scissors? || other_move.lizard?) ||
      paper? && ( other_move.rock? || other_move.spock?) ||
      scissors? && ( other_move.paper? || other_move.lizard? ) ||
      spock? && ( other_move.rock? || other_move.scissors? ) ||
      lizard? && ( other_move.paper? || other_move.spock? )
  end

  def to_s
    @value
  end
end

class Player
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
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, spock or lizard:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    case self.name
    when 'R2D2'
      self.move = Move.new('rock')
    when 'Hal'
      self.move = Move.new(['paper', 'scissors', 'scissors', 'scissors', 'scissors', 'spock', 'lizard'].sample)
    when 'Chappie'
      self.move = Move.new(Move::VALUES.sample)
    when 'Sonny'
      self.move = Move.new(['rock', 'paper', 'scissors'].sample)
    when 'Number 5'
      self.move = Move.new(['spock', 'lizard'].sample)
    end
  end
end

class RPSGame
  attr_reader :human, :computer, :history
  WINS_LIMIT = 3

  def initialize
    @human = Human.new
    @computer = Computer.new
    @history = History.new(human.name, computer.name)
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard!"
    puts "The first to win #{WINS_LIMIT} games is the champion of the round."
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Spock, Lizard. Good bye!"
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
  end

  def display_scores
    puts "#{human.name} has #{human.score} #{human.point_string}."
    puts "#{computer.name} has #{computer.score} #{computer.point_string}."
    puts "Remember, the first to #{WINS_LIMIT} is the champion of the round."
  end

  def update_score
    if human.move > computer.move
      human.increment_score
    elsif computer.move > human.move
      computer.increment_score
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must be y or n."
    end

    return true if answer.downcase == 'y'
    return false if answer.downcase == 'n'
  end

  def play_match
    loop do
      human.choose
      computer.choose
      history.update(human.move, computer.move)
      update_score
      display_moves
      display_winner
      break if ( human.score >= WINS_LIMIT || computer.score >= WINS_LIMIT )
      display_scores
    end
  end

  def display_match_winner
    if human.score > computer.score
      puts "#{human.name} won #{WINS_LIMIT} games and is the CHAMPION of the round!"
    else
      puts "#{computer.name} won #{WINS_LIMIT} games and is the CHAMPION of the round!"
    end
  end

  def reset_variables
    human.score = 0
    computer.score = 0
    history.set_next_round
  end

  def display_move_history
    puts "These were #{human.name}'s moves: #{history.record["#{human.name}".to_sym]}."
    puts "These were #{computer.name}'s moves: #{history.record["#{computer.name}".to_sym]}."
  end

  def play
    display_welcome_message
    loop do
      play_match
      display_match_winner
      break unless play_again?
      reset_variables
    end
    display_move_history
    display_goodbye_message
  end
end

RPSGame.new.play
