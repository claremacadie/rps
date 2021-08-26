# test.rb

prob = [3, 2, 5]

moves = ['r', 'p', 's']

allowed_moves = []

moves.each_with_index do |move, idx|
  prob[idx].times {allowed_moves << move}
end

p allowed_moves