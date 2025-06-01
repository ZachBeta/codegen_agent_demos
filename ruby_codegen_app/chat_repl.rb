require_relative 'chat_repl/repl'
require_relative 'chat_repl/history'
require_relative 'chat_repl/executor'
require_relative 'services/code_generator'
require 'colorize'

begin
  puts "=== Ruby CodeGen REPL ==="
  puts "Type 'exit' to quit, 'history' to view history"
  
  repl = ChatREPL.new
  repl.start
rescue Interrupt
  puts "\nExiting REPL...".colorize(:yellow)
rescue => e
  puts "Fatal error: #{e.message}".colorize(:red)
  puts e.backtrace.join("\n")
end