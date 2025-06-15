#!/bin/bash

echo "Checking if Tailwind CSS is installed..."
cd assets && npm list tailwindcss

echo "Checking if CSS file exists..."
ls -la priv/static/assets/app.css

echo "Checking Tailwind config..."
cat assets/tailwind.config.js

echo "Trying to compile assets..."
mix assets.build
