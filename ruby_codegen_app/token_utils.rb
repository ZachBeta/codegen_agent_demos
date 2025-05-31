require 'tiktoken_ruby'
require_relative 'model_config'

class TokenUtils
  class TokenizerAdapter
    def count(text)
      raise NotImplementedError
    end
  end

  class TiktokenAdapter < TokenizerAdapter
    def initialize(model_name)
      @encoding = Tiktoken.encoding_for_model(model_name)
    end

    def count(text)
      @encoding.encode(text.to_s).length
    end
  end

  class CharacterAdapter < TokenizerAdapter
    def count(text)
      text.to_s.length / 4 # Rough estimate
    end
  end

  def self.count_tokens(model_name, text)
    return 0 unless text
    adapter_for(model_name).count(text)
  end

  def self.count_message_tokens(model_name, message)
    config = ModelConfig.for(model_name)
    overhead = config[:tokenizer] == 'tiktoken' ? 3 : 1
    
    count_tokens(model_name, message[:role].to_s) +
    count_tokens(model_name, message[:content].to_s) +
    overhead
  end

  private

  def self.adapter_for(model_name)
    config = ModelConfig.for(model_name)
    
    case config[:tokenizer]
    when 'tiktoken' then TiktokenAdapter.new(config[:tokenizer_name])
    else CharacterAdapter.new
    end
  end
end