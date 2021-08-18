# rock_paper_scissors.rb

class Move
  VALUES = %w(rock paper scissors).freeze
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

  def >(other_move)
    rock? && other_move.scissors? ||
      paper? && other_move.rock? ||
      scissors? && other_move.paper?
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
      puts "Please choose rock, paper, or scissors:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'CHappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSGame
  attr_accessor :human, :computer
  WINS_LIMIT = 3

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
    puts "The first to win #{WINS_LIMIT} games is the champion."
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Good bye!"
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
    puts "#{human.name} has #{human.score} points."
    puts "#{computer.name} has #{computer.score} points."
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
      update_score
      display_moves
      display_winner
      break if ( human.score >= WINS_LIMIT || computer.score >= WINS_LIMIT )
      display_scores
    end
  end

  def display_match_winner
    if human.score > computer.score
      puts "#{human.name} won #{WINS_LIMIT} games and is the CHAMPION!"
    else
      puts "#{computer.name} won #{WINS_LIMIT} games and is the CHAMPION!"
    end
  end

  def play
    display_welcome_message
    loop do
      play_match
      display_match_winner
      break unless play_again?
      human.score, computer.score = 0, 0
    end
    display_goodbye_message
  end
end

RPSGame.new.play
