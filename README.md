# MatMate - Advanced Mathematics Calculator

A modern, feature-rich mathematics calculator built with Flutter that solves complex mathematical problems with step-by-step explanations.

## 🚀 Features

### **Core Functionality**
- **Advanced Math Engine**: Solve equations, perform calculus, matrix operations, and statistical calculations
- **Landscape Mode**: Advanced features unlock in landscape orientation
- **Simple Mode**: Simplified interface for portrait mode or manual toggle
- **Step-by-Step Solutions**: Detailed explanations for every calculation
- **History Tracking**: Save and review past calculations
- **Modern UI**: Material 3 design with dark/light theme support

### **Mathematical Capabilities**

#### **Basic Arithmetic**
- Order of operations
- Parentheses grouping
- Constants (π, e)
- Functions: sin, cos, tan, log, sqrt, exp

#### **Equations**
- Linear equations: `2x + 3 = 7`
- Quadratic equations: `x^2 - 5x + 6 = 0`
- Polynomial equations: `x^3 - 8 = 0`

#### **Calculus**
- Derivatives: `d/dx(x^2)`
- Definite integrals: `integral(x^2, 0, 1)`
- Limits: `limit(1/x, x, 0)`

#### **Matrices**
- Determinant: `det([1,2;3,4])`
- Inverse: `inv([2,1;1,2])`
- Linear systems: `solve([[1,2],[3,4]], [5,6])`

#### **Statistics**
- Mean: `mean([1,2,3,4,5])`
- Median: `median([1,3,5,7,9])`
- Sum: `sum([1,2,3,4,5])`

#### **Functions**
- Function definition: `f(x) = x^2 + 2x + 1`
- Function evaluation: `f(3)`
- Function composition: `f(g(x)) = x^2`

## 📱 Usage

### **Input Methods**
1. **Text Input**: Type expressions directly
2. **Calculator Keypad**: Use the built-in keypad for easy input
3. **Example Chips**: Tap example chips for quick calculations

### **Modes**
- **Simple Mode**: Basic calculator with essential functions
- **Advanced Mode**: Full feature set (available in landscape)

### **Navigation**
- **Solve Tab**: Main calculator interface
- **History Tab**: View past calculations
- **Settings Tab**: Customize theme, precision, and mode

## 🛠️ Technical Details

### **Platform Support**
- **Android**: API 21+ (Android 5.0+)
- **Target**: Android 15 compatible
- **Architecture**: ARM64, ARMv7, x86_64

### **Dependencies**
- `flutter_riverpod`: State management
- `math_expressions`: Mathematical expression parsing
- `equations`: Equation solving
- `flutter_math_fork`: LaTeX rendering
- `google_fonts`: Typography
- `shared_preferences`: Data persistence

### **Build Requirements**
- Flutter 3.19+
- Dart 3.3+
- Android SDK 21+
- Gradle 8.0+

## 🏗️ Project Structure

```
lib/
├── main.dart              # Main application entry point
├── pubspec.yaml           # Dependencies and project configuration
└── android/               # Android-specific configuration
    ├── app/
    │   ├── build.gradle.kts
    │   └── src/main/AndroidManifest.xml
    └── build.gradle
```

## 🚀 Getting Started

### **Prerequisites**
1. Install [Flutter](https://flutter.dev/docs/get-started/install)
2. Install [Android Studio](https://developer.android.com/studio)
3. Set up Android SDK and emulator

### **Installation**
```bash
# Clone the repository
git clone https://github.com/aminegames125/matmate.git
cd matmate

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **Building for Release**
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

## 📦 GitHub Actions

The project includes automated CI/CD workflows:

### **Build Workflow**
- **Triggers**: Push to main, Pull Requests
- **Actions**:
  - Code analysis with `flutter analyze`
  - Unit tests with `flutter test`
  - Build APK for Android
  - Upload artifacts to GitHub Releases

### **Release Workflow**
- **Triggers**: New GitHub Release
- **Actions**:
  - Build signed release APK
  - Attach APK to release
  - Generate release notes

## 🎨 Customization

### **Themes**
- System theme (follows device setting)
- Light theme
- Dark theme

### **Precision**
- Adjustable decimal precision (0-10 places)
- Real-time preview of precision changes

### **Simple Mode**
- Toggle between simple and advanced interfaces
- Automatic mode switching based on orientation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Guidelines**
- Follow Flutter/Dart style guidelines
- Add tests for new features
- Update documentation as needed
- Ensure all linter checks pass

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [math_expressions](https://pub.dev/packages/math_expressions) for mathematical parsing
- [equations](https://pub.dev/packages/equations) for equation solving
- [flutter_math_fork](https://pub.dev/packages/flutter_math_fork) for LaTeX rendering
- Flutter team for the amazing framework

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/aminegames125/matmate/issues)
- **Discussions**: [GitHub Discussions](https://github.com/aminegames125/matmate/discussions)
- **Email**: your.email@example.com

---

**MatMate** - Making mathematics accessible and beautiful! 🧮✨
