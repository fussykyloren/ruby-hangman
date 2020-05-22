require "yaml"

class Hangman
    def initialize
        @secret_word = ""
        @secret_word_display = ""
        @num_guesses = 12
        @guessed_letters = []
        start_game
    end

    def get_word
        choices = File.open("5desk.txt")
        valid_words = []
        while !choices.eof?
            line = choices.readline
            if line.length > 5 || line.length < 12
                valid_words << line
            end
        end
        @secret_word = valid_words[rand(valid_words.length + 1)]
        @secret_word = @secret_word.split("")
        @secret_word.each_with_index do |letter, i|
            @secret_word[i] = @secret_word[i].upcase
        end
        @secret_word = @secret_word[0..(@secret_word.length - 2)]
        @secret_word_display = "_" * (@secret_word.length - 1)
    end

    def load_game
        game_save_file = File.open("hangman_saved_games.txt", "r") {|file| file.read}
        game_save_file = YAML::load(game_save_file)
        @secret_word = game_save_file[0]
        @secret_word_display = game_save_file[1]
        @num_guesses = game_save_file[2]
    end

    def save_game(secret_word, secret_word_display, num_guesses)
        save_data = [secret_word, secret_word_display, num_guesses]
        saved_game = YAML::dump(save_data)
        File.open("hangman_saved_games.txt", "w"){|file| file.puts saved_game}
        puts "Game saved."
    end

    def start_game
        get_word
        puts "Would you like to load a previously saved game? (Y/N)"
        input = gets.chomp.upcase
        if input == "Y"
            load_game
        end

        while @secret_word_display.include?("_") && @num_guesses > 0
            puts "Guess a letter or type 'save' to load last saved game."
            correct_guess = false

            input = gets.chomp.upcase
            if input.upcase == "SAVE"
                save_game(@secret_word, @secret_word_display, @num_guesses)
                puts "Guess a letter!"
                input = gets.chomp.upcase
            end

            @guessed_letters << input
            @secret_word.each_with_index do |letter, i|
                if input == letter.upcase
                    @secret_word_display[i] = letter.upcase
                    correct_guess = true
                end
            end

            if correct_guess == false
                @num_guesses -= 1
                puts "Sorry, that letter is not part of the word."
                puts "You have #{@num_guesses} left."
                puts "The letters you have guessed are '#{@guessed_letters.join}'"
            else
                puts "Nice! '#{input}' is in the word.'"
                puts "You have #{@num_guesses} left."
            end
            puts @secret_word_display
        end

        if @num_guesses == 0
            puts "Sorry, you are out of guesses. The answer was '#{@secret_word.join}'"
        else
            puts "You win! Good job."
        end
    end
end