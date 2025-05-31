class FizzBuzz
  def self.play(number)
    raise ArgumentError, "Input must be an integer" unless number.is_a?(Integer)
    
    if (number % 3).zero? && (number % 5).zero?
      "FizzBuzz"
    elsif (number % 3).zero?
      "Fizz"
    elsif (number % 5).zero?
      "Buzz"
    else
      number.to_s
    end
  end
end