class ChatREPL
  def initialize
    @history = HistoryManager.new
    @executor = Executor.new
    @code_generator = CodeGenerator.new('', nil)
    @conversation_context = []
  end

  def start
    puts "Ruby CodeGen REPL - Type 'exit' to quit, 'history' to view history"
    
    loop do
      print "codegen> "
      input = gets.chomp
      
      case input
      when "exit" then break
      when "help", "?" then show_help
      when "history" then show_history
      when "clear" then @history.clear
      when /^chat:/ then handle_chat(input)
      when /^generate:/ then execute_command(input)
      else
        puts "Unknown command. Type 'help' for available commands"
      end
    end
  rescue Interrupt
    puts "\nGoodbye!"
  end

  private

  def show_help
    puts <<~HELP
    Available commands:
      chat:<message>    - Chat with the AI assistant
      generate:<prompt> - Generate and execute Ruby code
      history           - Show command history
      clear             - Clear history
      help, ?           - Show this help
      exit              - Exit the REPL
    HELP
  end

  def handle_chat(input)
    message = input.split(':', 2).last.strip
    @conversation_context << {role: "user", content: message}
    
    response = @code_generator.llm_chat(@conversation_context)
    @conversation_context << {role: "assistant", content: response}
    
    @history.add_entry(input, response)
    puts "=> #{response}"
  end

  def execute_command(input)
    if input.start_with?('generate:')
      prompt = input.split(':', 2).last.strip
      generate_and_execute(prompt)
    else
      begin
        output = @executor.execute(input)
        @history.add_entry(input, output)
        puts "=> #{output}"
      rescue => e
        error_msg = "#{e.class}: #{e.message}"
        @history.add_entry(input, error_msg)
        puts "=> #{error_msg}"
      end
    end
  end

  private

  def generate_and_execute(prompt)
    puts "Generating code for: #{prompt}"
    # Reinitialize code generator with the prompt
    @code_generator = CodeGenerator.new(prompt, nil)
    generation_result = @code_generator.call
    
    puts "Generated code:\n#{generation_result[:code]}"
    print "Run this code? (y/n) "
    return unless gets.chomp.downcase == 'y'
    
    output = @executor.execute(generation_result[:code])
    @history.add_entry(prompt, output, generation_result[:code])
    puts "=> #{output}"
  end

  def show_history
    puts "\nCommand History (last 5 entries):"
    entries = @history.last(5) || []
    entries.each_with_index do |entry, i|
      if entry.is_a?(Hash)
        command = entry[:input] || entry[:prompt] || 'Unknown command'
        output = entry[:output] || 'No output'
        
        # Clean up output formatting
        cleaned_output = output.gsub(/\n\s*\^+\n?/, '').strip
        
        puts "#{i+1}. Command: #{command}"
        puts "   Output: #{cleaned_output}\n\n"
      else
        puts "#{i+1}. #{entry.to_s.gsub(/\n\s*\^+\n?/, '').strip}"
      end
    end
  end
end