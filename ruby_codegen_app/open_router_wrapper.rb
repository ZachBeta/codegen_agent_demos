require 'httparty'
require 'json'
require 'dotenv'

Dotenv.load

class OpenRouterWrapper
  API_URL = "https://openrouter.ai/api/v1/chat/completions".freeze

  def initialize(model: "deepseek/deepseek-r1-0528", provider: nil)
    validate_api_key!
    @model = model
    @provider = provider
    @headers = {
      "Authorization" => "Bearer #{ENV['OPENROUTER_API_KEY']}",
      "Content-Type" => "application/json",
      "HTTP-Referer" => "https://github.com/zachbeta/ruby_codegen_app",
      "X-Title" => "Ruby Codegen Chat"
    }
  end

  # Public API Methods
  public

  def provider
    @provider || ModelConfig.for(@model)[:provider]
  end

  def generate_response(messages, stream: false, &chunk_handler)
    body = {
      model: @model,
      messages: messages,
      stream: stream
    }.to_json

    if stream
      process_streaming_response(body, &chunk_handler)
    else
      response = HTTParty.post(API_URL, headers: @headers, body: body)
      parse_response(response)
    end
  end

  def process_streaming_response(body, &chunk_handler)
    full_content = ""
    HTTParty.post(API_URL, {
      headers: @headers,
      body: body,
      stream_body: true
    }) do |fragment|
      next if fragment.empty?
      
      # Process SSE format
      fragment.each_line do |line|
        next unless line.start_with?('data:')
        
        data = line[5..-1].strip
        next if data == "[DONE]"
        
        begin
          json = JSON.parse(data)
          delta = json.dig("choices", 0, "delta", "content")
          if delta
            full_content << delta
            chunk_handler.call(delta) if chunk_handler
          end
        rescue JSON::ParserError
          # Skip malformed chunks
        end
      end
    end
    full_content
  end

  def parse_response(response)
    if response.success?
      response.dig("choices", 0, "message", "content")
    else
      "Error: #{response.code} - #{response.body}"
    end
  end

  # Private Methods
  private

  def validate_api_key!
    unless ENV['OPENROUTER_API_KEY']
      raise "OPENROUTER_API_KEY environment variable not set"
    end
  end
end