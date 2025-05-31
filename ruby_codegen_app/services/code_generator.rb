require_relative '../open_router_wrapper'

class CodeGenerator
  SYSTEM_PROMPT = <<~PROMPT
    You are an expert Ruby programmer. Generate clean, idiomatic Ruby code based on the user's prompt.
    Follow these rules:
    1. Only output the code itself, no explanations or markdown formatting
    2. Include all necessary require statements
    3. Use best practices and proper error handling
    4. Include comments only when they add significant value
  PROMPT

  def initialize(prompt, output_file = nil)
    @prompt = prompt
    @output_file = output_file
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

    cleaned_code
  rescue StandardError => e
    puts "Error during code generation: #{e.message}"
    raise
  end
end