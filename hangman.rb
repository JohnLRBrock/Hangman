# John Brock
# The Odin Project
# 2016/10/5
# Hangman
GameStats = Struct.new(:secret_word, :number_wrong, :letters_guessed, :victory, :turns)

# make sure $game exists and each attribute has a value other than nil
def game_conditional_assignment
  $game ||= GameStats.new
  $game.secret_word ||= ''
  $game.number_wrong ||= 0
  $game.letters_guessed ||= []
  $game.victory ||= false
end

# load the dictionary and return an array
def load_dictionary(file_name)
  return File.readlines(file_name).map(&:chomp) if File.exist?(file_name)
  abort("#{file_name} is missing.")
end

# return random word in array
def random_word(dictionary)
  return dictionary[rand(dictionary.size)] if dictionary.is_a? Array
  puts "#{dictionary} isn't an array!"
  ""
end

def set_word(word)
  game_conditional_assignment
  $game.secret_word = word.downcase
end

# get guess from user
# save_game exits the program
def guess
  game_conditional_assignment
  loop do
    puts "\nGuess a letter or type 'save'."
    guess = gets.chomp.downcase
    save_game if guess == 'save'
    return guess if ("a".."z").cover?(guess) && !$game.letters_guessed.include?(guess)
  end
end

# add guess to game
def add_guess(guess)
  game_conditional_assignment
  $game.letters_guessed.push(guess)
  $game.letters_guessed.sort!
  if $game.secret_word.include?(guess)
    puts "\nThere is a(n) '#{guess}'"
  else
    $game.number_wrong += 1
    puts "\nThere is no '#{guess}'"
  end
end

# returns a string with the score
def display_score
  game_conditional_assignment
  score = ''
  $game.victory = true
  $game.secret_word.each_char do |letter|
    if $game.letters_guessed.include?(letter)
      score.concat("#{letter} ")
    else
      score.concat('_ ')
      $game.victory = false
    end
  end
  score.concat("\nYou have #{$game.number_wrong} wrong guesses.\n" \
               "Letters guessed:#{$game.letters_guessed.join(', ')}")
end

# checks the saved games folder and returns true if there are any
def saved_games?
  return true unless Dir.entries(Dir.pwd).drop(2).empty?
  false
end

# returns true if new game
# returns false if saved game
def new_game_or_saved_game?
  return true unless saved_games?
  loop do
    puts 'Would you like to play a new game or a saved game? (new/saved)'
    response = gets.chomp.downcase
    return true if response == 'new'
    return false if response == 'saved'
  end
end

# returns a list of saved games to the player
def list_saved_games
  games = Dir.entries(Dir.pwd).drop(2)
  return games.join("\n") unless games.empty?
  'No saved games.'
end

# asks player to select a game to play
def select_game
  Dir.chdir('saved_games')
  loop do
    puts "\nWhich game would you like to play?"
    puts list_saved_games
    file_name = gets.chomp
    return file_name if File.exist?(file_name)
    puts "#{file_name} doesn't exist!\n\n"
  end
end

def save_game
  i = 1
  begin
    Dir.chdir('saved_games')
  rescue
    loop do
      file_handle = "game#{i}.txt"
      unless File.exist?(file_handle)
        save_file = File.new(file_handle, 'w')
        save_file.puts "#{$game.secret_word}\n#{$game.number_wrong}" \
                       "\n#{$game.letters_guessed.join(' ')}\n#{$game.turns}"
        save_file.close
        abort('Game saved!')
      end
      i += 1
    end
  end
end

# starts a saved game
def load_game(file)
  game_conditional_assignment
  game = File.readlines(file).map(&:chomp)
  $game.secret_word = game[0]
  $game.number_wrong = game[1].to_i
  $game.letters_guessed = game[2].scan(/[a-z]/)
  $game.victory = false
  $game.turns = game[3].to_i
end

def delete_game(file_name)
  File.delete(file_name)
end

def new_game_start
  game_conditional_assignment
  file_name = '5desk.txt'
  dict = load_dictionary(file_name)
  $game.secret_word = random_word(dict)
  $game.turns = rand(2..10)
end

def save_game_start
  file_name = select_game
  load_game(file_name)
  delete_game(file_name)
end

puts "\nLet's play Russian Hangman!" \
     "\nThe more incorrect guesses you" \
     " make the more likely you'll be to lose!\n\n"
if new_game_or_saved_game?
  new_game_start
else
  save_game_start
end
puts "\n\n\n"
puts display_score

loop do
  add_guess(guess)
  puts display_score
  if $game.victory
    puts 'You won the game!'
    break
  elsif $game.number_wrong == $game.turns
    puts 'You lost the game!'
    puts "The word was '#{$game.secret_word}'"
    break
  end
end
