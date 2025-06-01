FROM ruby:3.3-slim

# Install required system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Set environment variables
ENV OPENROUTER_API_KEY=${OPENROUTER_API_KEY}

# Run the application
CMD ["ruby", "chat_app.rb"]