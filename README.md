# codegen_agent_demos
experimenting with minimal codegen agents

## current
```
codegen_agent_demos % cd ruby_codegen_app && ruby chat_repl.rb
=== Ruby CodeGen REPL ===
Type 'exit' to quit, 'history' to view history
Ruby CodeGen REPL - Type 'exit' to quit, 'history' to view history
codegen> generate: hello world in ruby
Generating code for: hello world in ruby
Generating code for: hello world in ruby
Generated code:
puts "hello world"
Run this code? (y/n) y
=> hello world
codegen> chat: hey there
=> Hey! 👋 How's it going? I'm here to help with anything you need—questions, coding help, or just chatting. What can I do for you today? 😊
codegen> help
Available commands:
  chat:<message>    - Chat with the AI assistant
  generate:<prompt> - Generate and execute Ruby code
  history           - Show command history
  clear             - Clear history
  help, ?           - Show this help
  exit              - Exit the REPL
codegen> history

Command History (last 5 entries):
1. Prompt: hello world in ruby
Generated Code:
puts "hello world"
Output: hello world
2. Command: chat: hey there
Output: Hey! 👋 How's it going? I'm here to help with anything you need—questions, coding help, or just chatting. What can I do for you today? 😊
codegen> exit 
```

## stale
```
ruby_codegen_app % bundle exec rake
[DEBUG] Fetching model config from: https://openrouter.ai/api/v1/models/deepseek/deepseek-r1-0528/endpoints
[DEBUG] API response: {"data":{"id":"deepseek/deepseek-r1-0528","name":"DeepSeek: R1 0528","created":1748455170,"description":"May 28th update to the [original DeepSeek R1](/deepseek/deepseek-r1) Performance on par with [Op...
[DEBUG] Selected endpoint: InferenceNet
[DEBUG] Pricing: prompt=$0.0000005 completion=$0.00000215
[DEBUG] ModelConfig for deepseek/deepseek-r1-0528: {:tokenizer=>"deepseek", :tokenizer_name=>"deepseek/deepseek-r1-0528", :input_price=>5.0e-07, :output_price=>2.15e-06, :context_length=>128000, :provider=>"InferenceNet"}
[DEBUG] CostCalculator initialized with config: {:tokenizer=>"deepseek", :tokenizer_name=>"deepseek/deepseek-r1-0528", :input_price=>5.0e-07, :output_price=>2.15e-06, :context_length=>128000, :provider=>"InferenceNet"}
Welcome to the Ruby Codegen Chat! Type 'ping' or ask a question.
> sakura haiku please
Thinking...
[DEBUG] Calculating cost for 6 input @ $5.0e-07/M and 0 output @ $2.15e-06/M
[DEBUG] Total cost: $3.0e-12
Here's a sakura haiku for you, capturing the delicate beauty and fleeting nature of cherry blossoms:

**Pink petals drift down**  
**Softly as spring snowflakes fall**  
**Perfume fills the air.**

*(Breakdown:)*  
*   **Line 1 (5 syllables):** "Pink petals drift down" - Focuses on the visual image and gentle movement.  
*   **Line 2 (7 syllables):** "Softly as spring snowflakes fall" - Compares the falling petals to snow, emphasizing their lightness and the spring season (kigo).  
*   **Line 3 (5 syllables):** "Perfume fills the air" - Adds the subtle, sweet scent of the blossoms, engaging another sense.*

Enjoy the essence of sakura season! 🌸[DEBUG] Calculating cost for 0 input @ $5.0e-07/M and 166 output @ $2.15e-06/M
[DEBUG] Total cost: $3.569e-10

(Tokens: 6↑ 166↓/8000 | Cost: $3.5989999999999997e-10)
> 
```

```
rake 'codegen:generate[Create a Ruby class called FizzBuzz that implements the fizzbuzz game. It should have a class method `play` that takes a number and returns "Fizz" for multiples of 3, "Buzz" for multiples of 5, "FizzBuzz" for multiples of both, and the number otherwise.]' OUTPUT=fizzbuzz.rb
```