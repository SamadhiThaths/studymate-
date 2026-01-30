# StudyMate - Personal Productivity Assistant

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

StudyMate is a comprehensive personal productivity application built with Flutter that helps you manage your daily tasks, study schedules, expenses, and academic assignments all in one place.

## 🚀 Features

### 📋 Task Management
- Create, edit, and delete daily tasks
- Mark tasks as completed
- Organize tasks with priorities and due dates
- Clean and intuitive task interface

### 📚 Study Task Management
- Track academic study sessions
- Set study goals and deadlines
- Monitor study progress
- Organize study tasks by subject or topic

### 💰 Expense Tracking
- Record and categorize expenses
- View expense summaries and analytics
- Track spending patterns over time
- Visual charts and graphs for expense analysis
- Filter expenses by date range and category

### 📝 Assignment Management
- Create and manage academic assignments
- Track assignment status (Not Started, In Progress, Completed, Overdue)
- Set due dates and module codes
- Assignment analytics and summary views
- Filter assignments by status, module, and date range

### 🔔 Smart Notifications
- Real-time notifications for completed assignments
- Notification badge showing unread count
- Comprehensive notification management screen
- Mark notifications as read or delete them

### 📊 Analytics & Insights
- Visual charts and graphs for all modules
- Expense breakdown by category
- Assignment status distribution
- Progress tracking over time

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Database**: SQLite (via sqflite package)
- **State Management**: Provider pattern
- **Charts**: FL Chart for data visualization
- **Architecture**: Clean Architecture with MVC pattern

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🏗️ Project Structure

```
lib/
├── controllers/          # Business logic controllers
│   ├── assignment_controller.dart
│   ├── expense_controller.dart
│   ├── notification_controller.dart
│   ├── study_task_controller.dart
│   └── task_controller.dart
├── models/              # Data models
│   ├── assignment.dart
│   ├── expense.dart
│   ├── notification.dart
│   ├── study_task.dart
│   └── task.dart
├── providers/           # State management providers
│   ├── assignment_provider.dart
│   ├── expense_provider.dart
│   ├── notification_provider.dart
│   ├── study_task_provider.dart
│   └── task_provider.dart
├── services/            # External services
│   └── db_service.dart
├── utils/               # Utility classes
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_utils.dart
├── views/               # UI screens and widgets
│   ├── assignments/
│   ├── expenses/
│   ├── notifications/
│   ├── study_tasks/
│   ├── tasks/
│   └── home_screen.dart
└── main.dart           # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/tasl.git
   cd tasl
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

**Web**
```bash
flutter build web --release
```

**Desktop (macOS/Windows/Linux)**
```bash
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

## 📦 Dependencies

### Core Dependencies
- `flutter`: SDK
- `provider`: State management
- `sqflite`: SQLite database
- `path`: File path utilities
- `uuid`: Unique ID generation

### UI Dependencies
- `fl_chart`: Charts and graphs
- `intl`: Internationalization

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Linting rules

## 🎨 Design Principles

- **Clean Architecture**: Separation of concerns with clear layers
- **SOLID Principles**: Maintainable and extensible code
- **Material Design**: Consistent and intuitive UI/UX
- **Responsive Design**: Works across all screen sizes
- **Performance Optimized**: Efficient memory and CPU usage
- **Security First**: Secure data handling and storage

## 🔧 Configuration

### Database
The app uses SQLite for local data storage. The database is automatically created on first run with the following tables:
- `tasks`
- `study_tasks`
- `expenses`
- `assignments`
- `notifications`

### Customization
You can customize the app's appearance by modifying:
- `lib/utils/app_colors.dart` - Color scheme
- `lib/utils/app_text_styles.dart` - Typography
- `lib/utils/app_utils.dart` - Utility functions

## 🧪 Testing

Run tests with:
```bash
flutter test
```

For integration tests:
```bash
flutter test integration_test/
```

## 📈 Performance

- **Memory Efficient**: Optimized data structures and lazy loading
- **Fast Startup**: Minimal initialization overhead
- **Smooth Animations**: 60fps UI performance
- **Offline First**: Works without internet connection
- **Battery Optimized**: Minimal background processing

## 🔒 Security

- Local data storage only (no cloud sync)
- No personal data collection
- Secure SQLite database
- Input validation and sanitization
- No external API dependencies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features
- Ensure code passes linting

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community packages that made this project possible
- Material Design for UI/UX guidelines

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/tasl/issues) page
2. Create a new issue with detailed information
3. Contact the maintainers

## 🗺️ Roadmap

- [ ] Cloud synchronization
- [ ] Dark mode support
- [ ] Export data functionality
- [ ] Reminder notifications
- [ ] Multi-language support
- [ ] Advanced analytics
- [ ] Collaboration features

---

**Made with ❤️ using Flutter**
