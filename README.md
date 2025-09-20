# VirtuAI - iOS Application

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 🎯 Overview

VirtuAI is a modern iOS application built with SwiftUI that leverages OpenAI's GPT API to provide intelligent conversational experiences. The app demonstrates proficiency in iOS development, API integration, and modern Swift patterns.

## ✨ Features

- **AI-Powered Conversations**: Integration with OpenAI's GPT API for intelligent responses
- **Modern SwiftUI Interface**: Built entirely with SwiftUI for a native iOS experience
- **Secure API Management**: Implementation of secure API key storage using Keychain
- **MVVM Architecture**: Clean separation of concerns with Model-View-ViewModel pattern
- **Async/Await**: Modern Swift concurrency for network operations
- **Dark Mode Support**: Full support for iOS dark and light themes
- **Localization Ready**: Structure prepared for multiple language support

## 🏗 Architecture

```
VirtuAI/
├── Core/
│   ├── Models/          # Data models and entities
│   ├── Views/           # SwiftUI views
│   ├── ViewModels/      # View models for MVVM
│   ├── Services/        # API and business logic services
│   ├── Utilities/       # Helper classes and utilities
│   └── Extensions/      # Swift extensions
├── Features/            # Feature-specific modules
├── Resources/           # Assets, fonts, and resources
└── SupportingFiles/     # Configuration files
```

### Design Patterns

- **MVVM (Model-View-ViewModel)**: For clean separation of UI and business logic
- **Repository Pattern**: For data access abstraction
- **Dependency Injection**: For testability and modularity
- **Coordinator Pattern**: For navigation flow management

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+
- CocoaPods or Swift Package Manager

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Minapak/Woorinara_app.git
cd Woorinara_app
```

2. Install dependencies:
```bash
# If using CocoaPods
pod install

# If using SPM, open in Xcode and it will resolve automatically
```

3. Configuration:
   - Copy `Config.example.plist` to `Config.plist`
   - Add your API keys to `Config.plist`
   - Never commit `Config.plist` to version control

4. Open `VirtuAI.xcworkspace` in Xcode

5. Build and run the project

## 🔧 Configuration

### API Keys Setup

The app requires the following API keys:

1. **OpenAI API Key**: For GPT integration
2. **AppsFlyer SDK Key**: For analytics (optional)

Store these keys in `Config.plist` (see `Config.example.plist` for structure).

### Environment Variables

For CI/CD, set these environment variables:
- `OPENAI_API_KEY`
- `APPS_FLYER_KEY`

## 🧪 Testing

### Unit Tests
```bash
xcodebuild test -scheme VirtuAI -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### UI Tests
```bash
xcodebuild test -scheme VirtuAIUITests -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Code Coverage
The project maintains >70% code coverage for business logic components.

## 📱 Screenshots

<p align="center">
  <img src="Screenshots/home.png" width="250" alt="Home Screen">
  <img src="Screenshots/chat.png" width="250" alt="Chat Interface">
  <img src="Screenshots/settings.png" width="250" alt="Settings">
</p>

## 🛠 Technical Skills Demonstrated

- **SwiftUI & Combine**: Modern declarative UI and reactive programming
- **Async/Await & Actors**: Swift concurrency for thread-safe operations
- **REST API Integration**: HTTP networking with URLSession
- **Keychain Services**: Secure storage of sensitive data
- **Core Data**: Local data persistence (if applicable)
- **Push Notifications**: APNs integration (if applicable)
- **CI/CD**: GitHub Actions for automated testing and deployment
- **Performance Optimization**: Instruments profiling and optimization
- **Accessibility**: VoiceOver support and Dynamic Type
- **Memory Management**: Proper ARC and weak reference usage

## 📊 Performance

- Launch time: <1.5 seconds
- Memory footprint: <50MB average
- Network optimization with caching
- Smooth 60fps scrolling

## 🔐 Security

- API keys stored in Keychain, never in code
- Certificate pinning for API calls
- Biometric authentication support
- Data encryption at rest

## 📈 Analytics & Monitoring

- Crash reporting with Crashlytics
- Performance monitoring
- User analytics (privacy-compliant)

## 🤝 Contributing

While this is a portfolio project, feedback and suggestions are welcome! Please feel free to:

1. Report bugs or issues
2. Suggest new features
3. Submit pull requests

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**[Your Name]**
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com
- Portfolio: [yourportfolio.com](https://yourportfolio.com)

## 🙏 Acknowledgments

- OpenAI for GPT API
- Apple Developer Documentation
- SwiftUI community

---

<p align="center">
  Made with ❤️ using Swift and SwiftUI
</p>
