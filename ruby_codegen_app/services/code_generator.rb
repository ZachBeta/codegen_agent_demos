require_relative '../open_router_wrapper'
require_relative 'code_runner'

class CodeGenerator
  CHAT_SYSTEM_PROMPT = <<~PROMPT
    You are a helpful AI assistant. Provide clear, concise responses to user questions.
    Follow these rules:
    1. Be professional but friendly
    2. Keep responses under 200 words unless more detail is requested
    3. Format code examples clearly when needed
  PROMPT

  SYSTEM_PROMPT = <<~PROMPT
    You are an expert Ruby programmer. Generate clean, idiomatic Ruby code based on the user's prompt.
    Follow these rules:
    1. Only output the code itself, no explanations or markdown formatting
    2. Include all necessary require statements
    3. Use best practices and proper error handling
    4. Include comments only when they add significant value
    5. The code should accept input via STDIN and output to STDOUT
  PROMPT

  def initialize(prompt, output_file = nil)
    @prompt = prompt
    @output_file = output_file
    @runner = CodeRunner.new
  end

  def call
    puts "Generating code for: #{@prompt}"
    puts "Output file: #{@output_file}" if @output_file

    messages = [
      { role: "system", content: SYSTEM_PROMPT },
      { role: "user", content: @prompt }
    ]

    wrapper = OpenRouterWrapper.new
    generated_code = wrapper.generate_response(messages)
    
    # Clean up markdown formatting if present
    cleaned_code = generated_code.gsub(/^```ruby\n/, '')
                                .gsub(/\n```$/, '')
                                .strip

    if @output_file
      File.write(@output_file, cleaned_code)
      puts "Code written to #{@output_file}"
    end

    # Execute and verify the generated code
    test_input = 60 # Default test case
    execution_result = @runner.run(cleaned_code, test_input)
    
    {
      code: cleaned_code,
      execution_result: execution_result
    }
  rescue StandardError => e
    puts "Error during code generation: #{e.message}"
    raise
  end

  def llm_chat(messages)
    wrapper = OpenRouterWrapper.new
    chat_messages = [
      { role: "system", content: CHAT_SYSTEM_PROMPT }
    ] + messages
    
    response = wrapper.generate_response(chat_messages)
    response.gsub(/^```.*?\n/, '').gsub(/\n```$/, '').strip
  end
end