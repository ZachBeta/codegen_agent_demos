namespace :codegen do
  desc "Generate code from a prompt"
  task :generate, [:prompt] do |t, args|
    require_relative '../services/code_generator'
    
    output_file = ENV['OUTPUT']
    generator = CodeGenerator.new(args[:prompt], output_file)
    
    begin
      result = generator.call
      
      if result[:execution_result]
        puts "\nExecution Results:"
        if result[:execution_result][:status] == :success
          puts "✅ Code executed successfully"
          puts "Output: #{result[:execution_result][:output]}"
        else
          puts "❌ Execution failed"
          puts "Error: #{result[:execution_result][:error] || result[:execution_result][:errors]}"
        end
      end
    rescue StandardError => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Generate and test prime factorization solution"
  task :prime_factors do
    require_relative '../services/code_generator'
    
    prompt = <<~PROMPT
      Write a Ruby program that performs prime factorization.
      The program should:
      1. Accept an integer input via STDIN
      2. Output an array of prime factors via STDOUT
      3. Handle edge cases (numbers < 2)
      4. Use efficient factorization algorithm
    PROMPT

    generator = CodeGenerator.new(prompt, 'prime_factors.rb')
    result = generator.call
    
    puts "\nGenerated prime factorization solution:"
    puts result[:code]
    
    if result[:execution_result]
      puts "\n=== Benchmark Results ==="
      test_cases = {
        60 => [2, 2, 3, 5],
        17 => [17],
        1 => [],
        997 => [997],
        1000000 => [2, 2, 2, 2, 2, 2, 5, 5, 5, 5, 5, 5]
      }
      
      benchmark_data = {
        timestamp: Time.now.utc.iso8601,
        test_cases: {},
        stats: {
          total_tests: 0,
          passed: 0,
          failed: 0,
          avg_time: 0
        }
      }
      
      total_time = 0
      
      test_cases.each do |input, expected|
        puts "\nTesting with input: #{input}"
        puts "Expected output: #{expected.inspect}"
        
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        runner = CodeRunner.new
        test_result = runner.run(result[:code], input)
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
        
        test_data = {
          input: input,
          expected: expected,
          time: elapsed.round(4),
          status: nil,
          output: nil,
          error: nil
        }
        
        if test_result[:status] == :success
          actual = eval(test_result[:output]) rescue test_result[:output]
          if actual == expected
            puts "✅ PASSED in #{elapsed.round(4)}s"
            benchmark_data[:stats][:passed] += 1
            test_data[:status] = :passed
          else
            puts "❌ FAILED in #{elapsed.round(4)}s (got #{actual.inspect})"
            benchmark_data[:stats][:failed] += 1
            test_data[:status] = :failed
            test_data[:output] = actual
          end
        else
          puts "❌ EXECUTION ERROR in #{elapsed.round(4)}s: #{test_result[:error] || test_result[:errors]}"
          benchmark_data[:stats][:failed] += 1
          test_data[:status] = :error
          test_data[:error] = test_result[:error] || test_result[:errors]
        end
        
        test_data[:output] = test_result[:output] if test_result[:output]
        benchmark_data[:test_cases][input] = test_data
        total_time += elapsed
        benchmark_data[:stats][:total_tests] += 1
      end
      
      benchmark_data[:stats][:avg_time] = total_time / benchmark_data[:stats][:total_tests]
      
      # Write benchmark results to file
      File.write('prime_factors_benchmark.json', JSON.pretty_generate(benchmark_data))
      puts "\nBenchmark summary:"
      puts "Total tests: #{benchmark_data[:stats][:total_tests]}"
      puts "Passed: #{benchmark_data[:stats][:passed]}"
      puts "Failed: #{benchmark_data[:stats][:failed]}"
      puts "Average time: #{benchmark_data[:stats][:avg_time].round(4)}s"
      puts "Results saved to prime_factors_benchmark.json"
    end
  end
end