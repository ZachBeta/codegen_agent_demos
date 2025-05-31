require 'tiktoken'

class TokenUtils
  ENCODING = Tiktoken.encoding_for_model("gpt-4")

  def self.count_tokens(text)
    return 0 unless text
    ENCODING.encode(text.to_s).length
  end

  def self.count_message_tokens(message)
    # Count tokens for role + content
    count_tokens(message[:role].to_s) + count_tokens(message[:content].to_s) + 3 # Add 3 for message overhead
  end
end