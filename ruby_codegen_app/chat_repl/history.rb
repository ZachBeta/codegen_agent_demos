class HistoryManager
  def initialize
    @entries = []
  end

  def add_entry(input, output, generated_code = nil)
    @entries << {
      prompt: input,
      output: output,
      generated_code: generated_code,
      timestamp: Time.now
    }
  end

  def last(n=5)
    @entries.last(n).map do |entry|
      if entry[:generated_code]
        "Prompt: #{entry[:prompt]}\nGenerated Code:\n#{entry[:generated_code]}\nOutput: #{entry[:output]}"
      else
        "Command: #{entry[:prompt]}\nOutput: #{entry[:output]}"
      end
    end
  end

  def clear
    @entries = []
  end
end