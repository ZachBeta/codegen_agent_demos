# Ruby Codegen Chat App

A Ruby CLI chat application with streaming responses and conversation history.

## Features

- **Streaming Responses**: Real-time display of LLM responses
- **Conversation History**: Persistent chat history in JSONL format
- **Token Counting**: Context window management with token limits
- **Rake Integration**: Easy execution via `rake chat`

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set your OpenRouter API key in `.env`:
   ```
   OPENROUTER_API_KEY=your_api_key_here
   ```

## Usage

Run the chat app:
```bash
bundle exec rake chat
```

Or run directly:
```bash
ruby chat_app.rb
```

## Commands

- `ping` - Test response
- `exit`/`quit` - End session
- Normal input - Chat with the AI

## Configuration

- `MAX_TOKENS` in `chat_app.rb` - Set context window size
- `history_file` - Change history storage location

## Implementation Details

- Uses OpenRouter API for LLM access
- Implements token counting with `tiktoken_ruby`
- Stores history in pretty-printed JSONL format
- Handles streaming responses via SSE