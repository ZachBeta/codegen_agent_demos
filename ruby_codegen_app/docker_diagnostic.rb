require 'docker'

File.open('docker_diagnostic.log', 'w') do |f|
  f.puts "=== Docker Diagnostic Tool ==="
  f.puts "Timestamp: #{Time.now}"

  # 1. Check Docker connection
  begin
    f.puts "\n1. Testing Docker connection..."
    f.puts "Docker version: #{Docker.version}"
    version = Docker.version rescue nil
    f.puts "Docker version: #{version || 'Unable to get version'}"
    info = Docker.info rescue nil
    f.puts "Docker info: #{info || 'Unable to get info'}"
  rescue => e
    f.puts "❌ Docker connection failed: #{e.message}"
    f.puts "Docker.url: #{Docker.url rescue 'N/A'}"
    f.puts "Backtrace:\n#{e.backtrace.join("\n")}"
    exit 1
  end

  # 2. Check image availability
  begin
    f.puts "\n2. Checking image ruby:3.3-slim"
    image = Docker::Image.get('ruby:3.3-slim')
    f.puts "✅ Image found: #{image.id}"
    f.puts "Image details: #{image.json}"
  rescue Docker::Error::NotFoundError => e
    f.puts "❌ Image not found locally"
    f.puts "Attempting to pull image..."
    begin
      Docker::Image.create('fromImage' => 'ruby:3.3-slim')
      image = Docker::Image.get('ruby:3.3-slim')
      f.puts "✅ Successfully pulled image: #{image.id}"
    rescue => e
      f.puts "❌ Failed to pull image: #{e.message}"
    end
  rescue => e
    f.puts "❌ Error checking image: #{e.message}"
  end

  f.puts "\n=== Diagnostic Complete ==="
end

puts "Diagnostic complete. Results saved to docker_diagnostic.log"