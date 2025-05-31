require_relative 'open_router_wrapper'
require 'json'

def chat_app
  llm = OpenRouterWrapper.new
  history_file = "conversation_history.jsonl"
  MAX_TOKENS = 8000
  current_tokens = 0
  
  # Load existing history if file exists
  conversation_history = if File.exist?(history_file)
    File.readlines(history_file).each_with_object([]) do |line, history|
      next if line.strip.empty?
      begin
        msg = JSON.parse(line, symbolize_names: true)
        history << msg
        current_tokens += TokenUtils.count_message_tokens(msg)
      rescue JSON::ParserError
        # Skip malformed entries
      end
    end
  else
    []
  end
  
  puts "Welcome to the Ruby Codegen Chat! Type 'ping' or ask a question."
  
  loop do
    print "> "
    user_input = gets
    break if user_input.nil? # Handle EOF/ctrl+D
    user_input = user_input.chomp
    
    case user_input.downcase
    when "ping"
      puts "pong"
    when "exit", "quit"
      puts "Goodbye!"
      break
    else
      puts "Thinking..."
      conversation_history << { role: "user", content: user_input }
      # Save user prompt immediately
      File.open(history_file, "a") do |f|
        f.puts(JSON.pretty_generate(conversation_history.last))
      end
      
      # Keep last 4 exchanges (8 messages)
      conversation_history = conversation_history.last(8)
      full_response = ""
      print "Assistant: "
      llm.generate_response(conversation_history, stream: true) do |chunk|
        print chunk
        full_response << chunk
        STDOUT.flush
      end
      puts "\n"
      
      conversation_history << { role: "assistant", content: full_response }
      
      # Save assistant response
      File.open(history_file, "a") do |f|
        f.puts(JSON.pretty_generate(conversation_history.last))
      end
    end
  end
end

chat_app