require 'json'
require_relative 'token_utils'
require_relative 'open_router_wrapper'
require_relative 'cost_calculator'

MAX_TOKENS = 8000

class ChatApp
  def initialize
    @model_name = "deepseek/deepseek-r1-0528" # Default model
    model_config = ModelConfig.for(@model_name)
    @llm = OpenRouterWrapper.new(model: @model_name, provider: model_config[:provider])
    @history_file = "conversation_history.jsonl"
    @input_tokens = 0
    @output_tokens = 0
    @total_cost = 0.0
    @cost_calculator = CostCalculator.new(@model_name)
    load_history
  end

  def run
    puts "Welcome to the Ruby Codegen Chat! Type 'ping' or ask a question."
    
    loop do
      print "> "
      user_input = gets
      break if user_input.nil?
      user_input = user_input.chomp
      
      case user_input.downcase
      when "ping"
        puts "pong"
      when "exit", "quit"
        puts "Goodbye!"
        break
      else
        handle_user_input(user_input)
      end
    end
  end

  private

  def load_history
    @conversation_history = if File.exist?(@history_file)
      File.readlines(@history_file).each_with_object([]) do |line, history|
        next if line.strip.empty?
        begin
          msg = JSON.parse(line, symbolize_names: true)
          history << msg
          tokens = TokenUtils.count_message_tokens(@model_name, msg)
          if msg[:role] == "user"
            @input_tokens += tokens
          else
            @output_tokens += tokens
          end
        rescue JSON::ParserError
          # Skip malformed entries
        end
      end
    else
      []
    end
  end

  def handle_user_input(input)
    puts "Thinking..."
    user_msg = { role: "user", content: input }
    @conversation_history << user_msg
    
    # Track input tokens and cost
    input_tokens = TokenUtils.count_message_tokens(@model_name, user_msg)
    @input_tokens += input_tokens
    @total_cost += @cost_calculator.calculate(input_tokens, 0)
    
    save_message(user_msg)
    truncate_history
    
    full_response = ""
    @llm.generate_response(@conversation_history, stream: true) do |chunk|
      print chunk
      full_response << chunk
      STDOUT.flush
    end
    
    # Finalize output token count
    output_tokens = TokenUtils.count_message_tokens(@model_name,
      { role: "assistant", content: full_response })
    @output_tokens += output_tokens
    @total_cost += @cost_calculator.calculate(0, output_tokens)
    
    assistant_msg = { role: "assistant", content: full_response }
    @conversation_history << assistant_msg
    save_message(assistant_msg)
    truncate_history
    
    puts "\n(Tokens: #{@input_tokens}↑ #{@output_tokens}↓/#{MAX_TOKENS} | Cost: $#{@total_cost})"
  end

  def save_message(message)
    File.open(@history_file, "a") do |f|
      f.puts(JSON.pretty_generate(message))
    end
  end

  def truncate_history
    while (@input_tokens + @output_tokens) > MAX_TOKENS && @conversation_history.size > 1
      removed = @conversation_history.shift
      tokens = TokenUtils.count_message_tokens(@model_name, removed)
      if removed[:role] == "user"
        @input_tokens -= tokens
      else
        @output_tokens -= tokens
      end
    end
  end
end

# Only run if executed directly, not when required
ChatApp.new.run if __FILE__ == $0