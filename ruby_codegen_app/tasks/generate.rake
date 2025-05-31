namespace :codegen do
  desc "Generate code from a prompt"
  task :generate, [:prompt] do |t, args|
    require_relative '../services/code_generator'
    
    output_file = ENV['OUTPUT']
    generator = CodeGenerator.new(args[:prompt], output_file)
    
    begin
      generator.call
    rescue StandardError => e
      puts "Error: #{e.message}"
      exit 1
    end
  end
end