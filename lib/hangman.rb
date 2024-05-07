# 1.  Download the google-10000-english-no-swears.txt dictionary file from the
#     first20hours GitHub repository google-10000-english.
#     DONE

# 2.  When a new game is started, your script should load in the dictionary and
#     randomly select a word between 5 and 12 characters long for the secret word.
#     DONE

# 3.  You don’t need to draw an actual stick figure (though you can if you want to!),
#     but do display some sort of count so the player knows how many more incorrect
#     guesses they have before the game ends. You should also display which correct
#     letters have already been chosen (and their position in the word, e.g.
#     _ r o g r a _ _ i n g) and which incorrect letters have already been chosen.
#     DONE

# 4.  Every turn, allow the player to make a guess of a letter. It should be case
#     insensitive. Update the display to reflect whether the letter was correct or
#     incorrect. If out of guesses, the player should lose.
#     DONE

# 5.  Now implement the functionality where, at the start of any turn, instead
#     of making a guess the player should also have the option to save the game.
#     Remember what you learned about serializing objects… you can serialize
#     your game class too!
#     DONE

# 6.  When the program first loads, add in an option that allows you to open
#     one of your saved games, which should jump you exactly back to where you
#     were when you saved. Play on!
#     DONE


require 'json'

class Hangman
  GUESSES = 8
  FILENAME = "hangman.sav"

  def initialize
    @secret_word = ""
    @used_letters = []
    @guesses = GUESSES
  end

  def start_new_game
    puts "New game was started"
    @secret_word = load_word(5..12)
  end

  def load_game
    file_content = File.read(FILENAME)
    parsed_data = JSON.parse(file_content)

    @secret_word = parsed_data["secret"]
    @used_letters = parsed_data["used_letters"]
    @guesses = parsed_data["moves_left"]

    puts "Game was loaded"
  end

  def play_game
    answer = ask_load_game
    answer[0].eql?('y') ? load_game : start_new_game

    show_guessed_letters

    @guesses.downto(1) do |n|
      guess_letter = ask_for_guess(n)
      make_move(guess_letter)
    end

    print "\nEnter guessed word now: "
    guessed_word = gets.chomp

    puts "The secret word was: #{@secret_word.downcase}"
    puts "You #{guessed_word.downcase.eql?(@secret_word.downcase) ? "WIN !!!" : "lose :("}"
  end

  private

  def ask_load_game
    print "Load game? (y/n): "
    gets.downcase
  end

  def show_guessed_letters
    guessed_part = @secret_word.gsub(/[a-z]/, '.').downcase
    puts guessed_part
    puts "used letters: #{@used_letters.sort}"
  end

  def load_word(range)
    words_array = File.readlines("google-10000-english-no-swears.txt")

    loop do
      word = words_array.sample.chomp
      return word if range.include?(word.size)
    end
  end

  def make_move(letter)
    @used_letters << letter
    @secret_word.gsub!(letter, letter.upcase)
    show_guessed_letters
  end

  def ask_for_guess(guesses_left)
    print "\nYou have #{guesses_left} guesses left. Please make your guess (press ENTER to save the game): "
    guess_letter = gets.chomp[0].downcase
  rescue
    save_game_state(guesses_left)
    puts "Your game was saved !!!"
    retry
  end

  def save_game_state(guesses_left)
    current_state = {
      secret:       @secret_word,
      moves_left:   guesses_left,
      used_letters: @used_letters
    }

    File.open(FILENAME, "w") {|f| f.puts JSON.generate(current_state) }
  end
end

# Instantiate and play the game
hangman = Hangman.new
hangman.play_game
