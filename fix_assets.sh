#!/bin/bash

echo "Fixing Tailwind CSS setup..."

# Remove problematic build files
rm -rf _build/dev/lib/phoenix_liveview_demo/priv/static/assets/
rm -rf priv/static/assets/

# Install/reinstall Node dependencies
echo "Installing Node.js dependencies..."
cd assets
rm -rf node_modules package-lock.json
npm install
npm install -D tailwindcss @tailwindcss/forms autoprefixer postcss
cd ..

# Try to build assets
echo "Building assets..."
mix assets.build

# Check if CSS was generated
if [ -f "priv/static/assets/app.css" ]; then
    echo "✅ CSS file generated successfully!"
    echo "File size: $(wc -c < priv/static/assets/app.css) bytes"
else
    echo "❌ CSS file not generated"
fi

echo "Setup complete! Now run: mix phx.server"
