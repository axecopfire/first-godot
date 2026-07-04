#!/bin/bash

## Export Medieval Market game to HTML5 web build
## Usage: ./export.sh

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
EXPORT_FILE="$BUILD_DIR/index.html"

echo "🔨 Building Medieval Market..."
echo "📝 Project: $PROJECT_DIR"
echo "📦 Output: $BUILD_DIR"
echo ""

mkdir -p "$BUILD_DIR"

# Clean old builds
rm -f "$BUILD_DIR"/index.* 2>/dev/null

# Export web build
godot --path "$PROJECT_DIR" --headless --export-debug "Web" "$EXPORT_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build complete!"
    echo ""
    echo "To run the game:"
    echo "  ./run.sh"
    echo ""
    echo "Or manually:"
    echo "  cd build && python3 -m http.server 8000"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi
