class CostCalculator
  def initialize(model_name)
    @model_config = ModelConfig.for(model_name)
    puts "[DEBUG] CostCalculator initialized with config: #{@model_config.inspect}"
  end

  def calculate(input_tokens, output_tokens)
    input_price = @model_config[:input_price] || 0
    output_price = @model_config[:output_price] || 0
    
    puts "[DEBUG] Calculating cost for #{input_tokens} input @ $#{input_price}/M and #{output_tokens} output @ $#{output_price}/M"
    
    input_cost = input_tokens * input_price / 1_000_000.0
    output_cost = output_tokens * output_price / 1_000_000.0
    
    total = input_cost + output_cost
    puts "[DEBUG] Total cost: $#{total}"
    total
  end

  def estimate_output_cost(text)
    tokens = text.size / 4 # Rough estimate for streaming display
    price = @model_config[:output_price] || 0
    cost = tokens * price / 1_000_000.0
    puts "[DEBUG] Estimated output cost: #{tokens} tokens @ $#{price}/M = $#{cost}"
    cost
  end
end