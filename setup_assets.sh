#!/bin/bash

echo "Setting up Phoenix LiveView Demo assets..."

# Install Node dependencies
echo "Installing Node.js dependencies..."
cd assets
npm install

# Install Tailwind and forms plugin
echo "Installing Tailwind CSS..."
npm install -D tailwindcss @tailwindcss/forms autoprefixer postcss

# Go back to root
cd ..

# Install Elixir dependencies
echo "Installing Elixir dependencies..."
mix deps.get

# Setup assets
echo "Setting up assets..."
mix assets.setup

# Build assets
echo "Building assets..."
mix assets.build

echo "Assets setup complete!"
echo "Now run: mix phx.server"
