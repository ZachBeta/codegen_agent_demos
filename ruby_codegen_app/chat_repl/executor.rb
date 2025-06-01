class Executor
  def execute(code)
    sanitized_code = code.gsub("'", "'\\\\''")
    output = `docker run --rm -i ruby:3.3-slim ruby -e '#{sanitized_code}' 2>&1`
    
    if $?.success?
      output
    else
      # Extract just the error message without code snippet
      output.lines.first.to_s.strip
    end
  rescue => e
    "Error: #{e.message}"
  end
end