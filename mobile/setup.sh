#!/bin/bash
# Setup script untuk dashboard - jalankan setelah clone

echo "🚀 Dashboard Setup Script"
echo "========================="
echo ""

# 1. Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo ""

# 2. Create necessary directories
echo "📁 Creating directories..."
mkdir -p lib/constants
mkdir -p lib/configs

echo "✅ Directories created"

echo ""

# 3. Verify files
echo "🔍 Verifying files..."

FILES=(
    "lib/models/dashboard_model.dart"
    "lib/services/dashboard_service.dart"
    "lib/repositories/dashboard_repository.dart"
    "lib/providers/dashboard_provider.dart"
    "lib/screens/home/home_screen.dart"
    "lib/screens/home/widgets/dashboard_header.dart"
    "lib/screens/home/widgets/dashboard_content.dart"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ Missing: $file"
    fi
done

echo ""

# 4. Check main.dart
if grep -q "MultiProvider" lib/main.dart; then
    echo "✅ main.dart already configured with Provider"
else
    echo "⚠️  main.dart needs to be updated with MultiProvider"
    echo "   See QUICK_START_GUIDE.md for instructions"
fi

echo ""
echo "========================="
echo "✨ Setup complete!"
echo ""
echo "📖 Documentation:"
echo "   - QUICK_START_GUIDE.md"
echo "   - DASHBOARD_REFACTOR_SUMMARY.md"
echo "   - DASHBOARD_ARCHITECTURE.md"
echo "   - lib/screens/home/README.md"
echo "   - lib/screens/home/API_INTEGRATION_GUIDE.md"
echo ""
echo "🎯 Next steps:"
echo "   1. Review QUICK_START_GUIDE.md"
echo "   2. Update main.dart with MultiProvider"
echo "   3. Run: flutter run"
echo ""
