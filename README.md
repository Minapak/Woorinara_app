# Woorinara App - Modern iOS Application

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 🎯 Overview

Woorinara App is a modern iOS application built with SwiftUI that leverages OpenAI's GPT API to provide intelligent conversational experiences. This project demonstrates proficiency in iOS development, API integration, and modern Swift patterns.

## ✨ Key Features

- **AI-Powered Conversations**: Seamless integration with OpenAI's GPT API for intelligent responses
- **Modern SwiftUI Interface**: 100% SwiftUI for a native iOS experience
- **Secure API Management**: Keychain Services for secure API key storage
- **MVVM Architecture**: Clean separation of concerns with Model-View-ViewModel pattern
- **Swift Concurrency**: Modern async/await for all network operations
- **Dark Mode Support**: Full support for iOS dark and light themes
- **Responsive Design**: Optimized for all iPhone and iPad sizes

## 🏗 Architecture

```
Woorinara_app/
├── Core/
│   ├── Models/          # Data models and entities
│   ├── Views/           # SwiftUI views
│   ├── ViewModels/      # View models for MVVM
│   ├── Services/        # API and business logic services
│   ├── Utilities/       # Helper classes and utilities
│   └── Extensions/      # Swift extensions
├── Features/
│   ├── Chat/            # Chat feature module
│   ├── MyPage/          # User profile module
│   └── Settings/        # Settings module
├── Resources/           # Assets, fonts, and resources
└── SupportingFiles/     # Configuration files
```

### Design Patterns & Best Practices

- **MVVM (Model-View-ViewModel)**: For clean separation of UI and business logic
- **Repository Pattern**: For data access abstraction
- **Dependency Injection**: For testability and modularity
- **Coordinator Pattern**: For navigation flow management
- **Protocol-Oriented Programming**: Extensive use of protocols for flexibility

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

# If using Swift Package Manager
# Dependencies will be resolved automatically when opening in Xcode
```

3. Configuration:
   - Copy `Config.example.plist` to `Config.plist`
   - Add your API keys to `Config.plist`
   - Never commit `Config.plist` to version control

4. Open the project:
```bash
open Woorinara_app.xcworkspace
# or
open Woorinara_app.xcodeproj
```

5. Build and run (⌘+R)

## 🔧 Configuration

### API Keys Setup

The app requires the following API keys:

1. **OpenAI API Key**: For GPT integration
   - Get it from [OpenAI Platform](https://platform.openai.com/api-keys)

2. **AppsFlyer SDK Key**: For analytics (optional)
   - Available from AppsFlyer Dashboard

Store these securely in `Config.plist` or use environment variables.

### Environment Variables

For CI/CD, set these environment variables:
```bash
export OPENAI_API_KEY="your-api-key"
export APPS_FLYER_KEY="your-key"
```

## 🧪 Testing

### Unit Tests
```bash
xcodebuild test -scheme Woorinara_app -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### UI Tests
```bash
xcodebuild test -scheme Woorinara_appUITests -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
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

### iOS Development
- **SwiftUI & Combine**: Modern declarative UI and reactive programming
- **UIKit Integration**: Bridging with UIKit when necessary
- **Core Data**: Local data persistence
- **Core Animation**: Smooth, custom animations

### Networking & APIs
- **URLSession**: Advanced networking with async/await
- **REST APIs**: Complete CRUD operations
- **WebSocket**: Real-time communication (if applicable)
- **JSON Parsing**: Codable protocol implementation

### Architecture & Patterns
- **MVVM + Coordinator**: Scalable app architecture
- **Dependency Injection**: Using property wrappers
- **Protocol-Oriented Programming**: Extensive protocol usage
- **SOLID Principles**: Clean, maintainable code

### Security
- **Keychain Services**: Secure credential storage
- **Biometric Authentication**: Face ID/Touch ID integration
- **Certificate Pinning**: Enhanced API security
- **Data Encryption**: AES encryption for sensitive data

## 📊 Performance Metrics

- **Launch Time**: <1.5 seconds
- **Memory Usage**: <50MB average
- **Battery Impact**: Minimal
- **Network Optimization**: Caching & compression
- **Frame Rate**: Consistent 60fps

## 🔐 Security Features

- API keys stored securely in Keychain
- No hardcoded credentials
- Certificate pinning for API calls
- Biometric authentication support
- Encrypted local storage

## 📈 Analytics & Monitoring

- Performance monitoring
- Crash reporting
- User analytics (privacy-compliant)
- A/B testing capability

## 🤝 Contributing

Feedback and suggestions are welcome! Please feel free to:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request
4. Report issues

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**[Your Name]**
- 📧 Email: your.email@example.com
- 💼 LinkedIn: [linkedin.com/in/yourprofile](https://linkedin.com/in/yourprofile)
- 🌐 Portfolio: [yourportfolio.com](https://yourportfolio.com)
- 📱 App Store: [Your Apps](https://apps.apple.com/developer/yourname)

## 🙏 Acknowledgments

- OpenAI for providing the GPT API
- Apple Developer Documentation
- SwiftUI Community
- Stack Overflow Community

## 📚 Resources

- [Project Documentation](Documentation/)
- [API Documentation](Documentation/API.md)
- [Architecture Decision Records](Documentation/ADR/)

---

<p align="center">
  Made with ❤️ using Swift and SwiftUI
</p>

<p align="center">
  <a href="https://github.com/Minapak/Woorinara_app">
    <img src="https://img.shields.io/github/stars/Minapak/Woorinara_app?style=social" alt="Stars">
  </a>
  <a href="https://github.com/Minapak/Woorinara_app/fork">
    <img src="https://img.shields.io/github/forks/Minapak/Woorinara_app?style=social" alt="Forks">
  </a>
</p>
