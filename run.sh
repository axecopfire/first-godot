#!/bin/bash

## Run the Medieval Market game in a local web server
## Usage: ./run.sh [port]

PORT=${1:-8000}
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/build"

if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: build/ directory not found. Please export the game first."
    exit 1
fi

echo "🏰 Medieval Market - Starting Web Server"
echo "📂 Serving: $BUILD_DIR"
echo "🌐 URL: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

cd "$BUILD_DIR"
python3 -m http.server $PORT
