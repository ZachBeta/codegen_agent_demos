require 'faraday'
require 'json'
require 'time'

class ModelConfig
  OPENROUTER_API_URL = "https://openrouter.ai/api/v1/models/%s/endpoints"
  CACHE_TTL = 3600 # 1 hour in seconds

  class << self
    def validate_api_key!
      unless ENV['OPENROUTER_API_KEY']
        raise "OPENROUTER_API_KEY environment variable not set"
      end
    end

    def for(model_name)
      validate_api_key!
      
      @cache ||= {}
      cached = @cache[model_name]

      if cached && cached[:expires_at] > Time.now
        return cached[:config]
      end

      begin
        config = fetch_model_config(model_name)
        @cache[model_name] = {
          config: config,
          expires_at: Time.now + CACHE_TTL
        }
        config
      rescue => e
        puts "[ERROR] Failed to fetch model config: #{e.message}"
        puts e.backtrace.join("\n")
        raise
      end
    end

    private

    def fetch_model_config(model_name)
      url = OPENROUTER_API_URL % model_name
      puts "[DEBUG] Fetching model config from: #{url}"
      
      response = Faraday.get(url) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{ENV['OPENROUTER_API_KEY']}"
      end

      unless response.success?
        puts "[ERROR] API request failed: #{response.status} - #{response.body}"
        raise "Failed to fetch model: #{response.status}"
      end

      puts "[DEBUG] API response: #{response.body[0..200]}..."
      data = JSON.parse(response.body)
      model_data = data['data']
      endpoints = model_data['endpoints'] || []
      
      if endpoints.empty?
        puts "[WARN] No endpoints found for model"
        raise "No endpoints available for model"
      end

      # Get the cheapest available provider by default
      endpoint = endpoints.min_by do |ep|
        prompt = ep.dig('pricing', 'prompt').to_f
        completion = ep.dig('pricing', 'completion').to_f
        (prompt * 1000) + (completion * 1000)
      end

      puts "[DEBUG] Selected endpoint: #{endpoint['provider_name']}"
      puts "[DEBUG] Pricing: prompt=$#{endpoint.dig('pricing', 'prompt')} completion=$#{endpoint.dig('pricing', 'completion')}"

      config = {
        tokenizer: 'deepseek', # Hardcoded since we know this model
        tokenizer_name: 'deepseek/deepseek-r1-0528',
        input_price: endpoint.dig('pricing', 'prompt').to_f,
        output_price: endpoint.dig('pricing', 'completion').to_f,
        context_length: endpoint['context_length'],
        provider: endpoint['provider_name']
      }

      puts "[DEBUG] ModelConfig for #{model_name}: #{config.inspect}"
      config
    rescue => e
      {
        tokenizer: 'character',
        tokenizer_name: nil,
        input_price: 0,
        output_price: 0,
        context_length: 4096 # Default fallback
      }
    end
  end
end