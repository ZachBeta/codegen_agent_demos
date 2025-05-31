require 'json'
require_relative 'token_utils'
require_relative 'open_router_wrapper'

MAX_TOKENS = 8000

class ChatApp
  def initialize
    @llm = OpenRouterWrapper.new
    @history_file = "conversation_history.jsonl"
    @current_tokens = 0
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
          @current_tokens += TokenUtils.count_message_tokens(msg)
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
    @current_tokens += TokenUtils.count_message_tokens(user_msg)
    
    save_message(user_msg)
    truncate_history
    
    full_response = ""
    @llm.generate_response(@conversation_history, stream: true) do |chunk|
      print chunk
      full_response << chunk
      STDOUT.flush
    end
    
    assistant_msg = { role: "assistant", content: full_response }
    @conversation_history << assistant_msg
    @current_tokens += TokenUtils.count_message_tokens(assistant_msg)
    
    save_message(assistant_msg)
    truncate_history
    
    puts "\n(Tokens used: #{@current_tokens}/#{MAX_TOKENS})"
  end

  def save_message(message)
    File.open(@history_file, "a") do |f|
      f.puts(JSON.pretty_generate(message))
    end
  end

  def truncate_history
    while @current_tokens > MAX_TOKENS && @conversation_history.size > 1
      removed = @conversation_history.shift
      @current_tokens -= TokenUtils.count_message_tokens(removed)
    end
  end
end

# Only run if executed directly, not when required
ChatApp.new.run if __FILE__ == $0