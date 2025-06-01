require 'json'
require_relative '../model_config'

class BenchmarkRunner
  def initialize(code_generator)
    @code_generator = code_generator
    @results = []
  end

  def run(prompt, iterations: 1, output_file: nil)
    iterations.times do |i|
      start_time = Time.now
      
      # Run code generation and capture output
      generated_code = @code_generator.call
      end_time = Time.now
      
      # Calculate metrics
      latency = (end_time - start_time).round(4)
      input_tokens = estimate_tokens(@code_generator.prompt)
      output_tokens = estimate_tokens(generated_code)
      
      # Get cost data from model config
      model_config = ModelConfig.for(@code_generator.model)
      cost = calculate_cost(input_tokens, output_tokens, model_config)
      
      # Store results
      @results << {
        iteration: i + 1,
        prompt: prompt,
        latency: latency,
        input_tokens: input_tokens,
        output_tokens: output_tokens,
        cost: cost,
        timestamp: Time.now.iso8601
      }
    end

    if output_file
      File.write(output_file, JSON.pretty_generate(@results))
    end

    @results
  end

  private

  def estimate_tokens(text)
    # Simple token estimation (4 chars ~= 1 token)
    (text.size / 4.0).ceil
  end

  def calculate_cost(input_tokens, output_tokens, model_config)
    input_cost = (input_tokens / 1000.0) * model_config[:input_price]
    output_cost = (output_tokens / 1000.0) * model_config[:output_price]
    (input_cost + output_cost).round(6)
  end
end