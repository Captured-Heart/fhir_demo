# FHIR Demo Project

A comprehensive Flutter application demonstrating the implementation of **FHIR (Fast Healthcare Interoperability Resources)** standards for healthcare data management and interoperability.

## 📋 Table of Contents

- [What is FHIR?](#what-is-fhir)
- [Purpose in Healthcare](#purpose-in-healthcare)
- [Project Overview](#project-overview)
- [Features](#features)
- [Code Structure](#code-structure)
- [Libraries Used](#libraries-used)
- [Installation Guide](#installation-guide)
- [Usage](#usage)
- [Configuration](#configuration)

## 🏥 What is FHIR?

**FHIR (Fast Healthcare Interoperability Resources)** is a modern healthcare data exchange standard developed by HL7 (Health Level Seven International). FHIR provides a standardized way to represent and exchange healthcare information electronically between different healthcare systems, applications, and devices.

Key characteristics of FHIR:

- **RESTful API**: Uses standard HTTP protocols for data exchange
- **Resource-based**: Healthcare data is organized into modular "resources" (Patient, Observation, Medication, etc.)
- **JSON/XML Support**: Data can be represented in modern, widely-supported formats
- **Interoperability**: Enables seamless communication between disparate healthcare systems

## 🎯 Purpose in Healthcare

FHIR addresses critical healthcare challenges:

1. **Data Interoperability**: Enables different healthcare systems to communicate and share patient data seamlessly
2. **Patient Care Continuity**: Ensures patient information is accessible across different healthcare providers
3. **Mobile Health Applications**: Facilitates development of patient-facing apps with secure access to health records
4. **Clinical Decision Support**: Provides standardized data for AI and analytics tools
5. **Regulatory Compliance**: Supports healthcare data standards required by regulations (e.g., HIPAA, GDPR)
6. **Research & Analytics**: Standardized data format enables large-scale health data analysis

## 🚀 Project Overview

This Flutter application demonstrates a complete FHIR-compliant healthcare management system with the following capabilities:

### Use Cases

- **Patient Registration**: Register new patients with FHIR Patient resources
- **Clinical Observations**: Record vital signs, lab results, and other health observations
- **Prescriptions Management**: Create and manage medication prescriptions
- **Diagnosis Recording**: Document patient diagnoses and conditions
- **Appointments Scheduling**: Book and manage healthcare appointments
- **Laboratory Results**: Track and display lab test results
- **Multi-language Support**: English and German localization
- **Secure Data Storage**: Encrypted local storage with Hive
- **Multi-server Support**: Connect to different FHIR servers (HAPI, Kodjin, Firefly, or custom)

## 🎯 Features

### Medical Forms Management

- **Register Patient** - Add new patient records with complete demographic information
- **Diagnosis** - Record medical diagnoses with severity levels and clinical status
- **Prescriptions** - Manage medication prescriptions with dosage and frequency
- **Observations** - Track vital signs (blood pressure, heart rate, temperature, etc.)
- **Appointments** - Schedule and manage patient appointments
- **Lab Results** - Record and view laboratory test results

### FHIR Server Integration

- ✅ Support for multiple FHIR servers:
  - HAPI FHIR Server (`https://hapi.fhir.org/baseR4`)
  - Kodjin (`https://demo.kodjin.com/fhir`)
  - Firefly Server (`https://server.fire.ly`)
  - Custom server URL configuration
- ✅ API key authentication support
- ✅ Connection testing

### Technical Features

- 🔐 Secure token-based authentication
- 🔄 Automatic token refresh
- 🌐 Network connectivity monitoring
- 🔁 Smart retry mechanism with exponential backoff
- 📱 Responsive UI with Material Design
- 🌍 Multi-language support (English, German)
- 💾 Local data persistence with Hive
- 🎨 Custom reusable UI components
- 🌙 Dark/Light theme support

## 📁 Code Structure

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── main.dart                          # Application entry point
├── constants/                         # App-wide constants and configurations
│   ├── api_constants.dart            # API endpoints and configurations
│   ├── api_url.dart                  # FHIR server URLs
│   ├── app_colors.dart               # Color scheme
│   ├── app_images.dart               # Image assets
│   ├── fhir_server_type_enum.dart    # FHIR server types
│   ├── nav_routes.dart               # Navigation routes
│   └── ...                           # Other constants
├── hive_helper/                       # Local database configuration
│   ├── cache_helper.dart             # Hive initialization
│   ├── hive_adapters.dart            # Custom type adapters
│   └── register_adapters.dart        # Adapter registration
├── src/
│   ├── controller/                    # Business logic (Riverpod)
│   │   ├── auth_controller.dart      # Authentication logic
│   │   ├── patient_controller.dart   # Patient management
│   │   ├── observations_controller.dart
│   │   ├── prescriptions_controller.dart
│   │   ├── diagnosis_controller.dart
│   │   ├── appointments_controller.dart
│   │   ├── lab_results_controller.dart
│   │   └── ...                       # Other controllers
│   ├── domain/                        # Business entities and contracts
│   │   ├── entities/                 # Domain models
│   │   │   ├── patient_entity.dart
│   │   │   ├── project_observation_entity.dart
│   │   │   ├── project_prescription_entity.dart
│   │   │   └── ...
│   │   ├── models/                   # Data models
│   │   └── repository/               # Repository interfaces
│   │       ├── auth_repository.dart
│   │       ├── fhir_repositories/    # FHIR-specific repos
│   │       └── network/              # Network layer
│   └── presentation/                  # UI layer
│       ├── views/                    # Application screens
│       │   ├── auth_view.dart
│       │   ├── splash_view.dart
│       │   ├── bottom_nav_view.dart
│       │   └── forms/                # Medical form views
│       │       ├── register_patient_view.dart
│       │       ├── observations_view.dart
│       │       ├── prescriptions_view.dart
│       │       ├── diagnosis_view.dart
│       │       ├── appointments_view.dart
│       │       └── lab_view.dart
│       └── widgets/                  # Reusable UI components
│           └── themes/               # App theming
└── utils/                            # Utility functions
    ├── loader_util.dart
    ├── shared_pref_util.dart
    ├── token_utils.dart
    └── validations.dart
```

### Architecture Pattern

- **Clean Architecture**: Separation of concerns with domain, data, and presentation layers
- **State Management**: Riverpod for reactive state management
- **Repository Pattern**: Abstracts data sources from business logic
- **Dependency Injection**: Providers for dependency management

## 📦 Libraries Used

### Core Dependencies

| Library                            | Version | Purpose                                    |
| ---------------------------------- | ------- | ------------------------------------------ |
| `fhir_r4`                          | ^0.4.3  | FHIR R4 resource models and validation     |
| `flutter_riverpod`                 | ^2.6.1  | State management solution                  |
| `dio`                              | ^5.9.0  | HTTP client for API requests               |
| `dio_smart_retry`                  | ^7.0.1  | Automatic retry for failed requests        |
| `hive`                             | ^2.2.3  | Lightweight local database                 |
| `hive_flutter`                     | ^1.1.0  | Hive integration for Flutter               |
| `flutter_secure_storage`           | ^9.2.4  | Secure storage for sensitive data (tokens) |
| `easy_localization`                | ^3.0.7  | Internationalization support               |
| `internet_connection_checker_plus` | ^2.7.2  | Network connectivity monitoring            |
| `flutter_animate`                  | ^4.5.2  | Animation utilities                        |
| `uuid`                             | ^4.5.1  | Generate unique identifiers                |
| `crypto`                           | ^3.0.6  | Cryptographic functions                    |
| `intl`                             | ^0.20.2 | Internationalization utilities             |

### Dev Dependencies

| Library          | Version | Purpose                |
| ---------------- | ------- | ---------------------- |
| `build_runner`   | ^2.4.13 | Code generation        |
| `hive_generator` | ^2.0.1  | Generate Hive adapters |
| `flutter_lints`  | ^5.0.0  | Linting rules          |

## 🔧 Installation Guide

### Prerequisites

- **Flutter SDK**: Version 3.7.0 or higher
- **Dart SDK**: Version 3.7.0 or higher
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Xcode**: (macOS only) For iOS development
- **Android Studio**: For Android development

### Step-by-Step Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/Captured-Heart/fhir_demo.git
   cd fhir_demo
   ```

2. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate required files**

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**

   For iOS:

   ```bash
   flutter run -d ios
   ```

   For Android:

   ```bash
   flutter run -d android
   ```

   For Web:

   ```bash
   flutter run -d chrome
   ```

### Platform-Specific Setup

#### iOS Setup

1. Navigate to the iOS directory:

   ```bash
   cd ios
   ```

2. Install CocoaPods dependencies:

   ```bash
   pod install
   ```

3. Open the workspace in Xcode:

   ```bash
   open Runner.xcworkspace
   ```

4. Configure signing & capabilities in Xcode

#### Android Setup

1. Ensure you have Android SDK installed
2. The project uses Gradle Kotlin DSL (`.kts` files)
3. Minimum SDK: Check `android/app/build.gradle.kts`
4. Update `local.properties` with your Android SDK path

## 🎮 Usage

### First Launch

1. **Authentication**: Login with FHIR server credentials
2. **Server Configuration**: Select or configure your FHIR server:
   - HAPI FHIR (Public test server)
   - Kodjin Demo
   - Firefly
   - Custom server URL

### Main Features

#### Patient Management

- Register new patients with demographic information
- Search and view existing patients
- Update patient records

#### Clinical Observations

- Record vital signs (blood pressure, heart rate, temperature, etc.)
- Document clinical findings
- View observation history

#### Prescriptions

- Create medication prescriptions
- Specify dosage, frequency, and duration
- Track prescription status

#### Diagnosis

- Document patient conditions
- Record diagnosis codes
- Link diagnoses to patients

#### Appointments

- Schedule patient appointments
- View appointment calendar
- Manage appointment status

#### Laboratory Results

- View lab test results
- Track lab orders
- Display result trends

## ⚙️ Configuration

### FHIR Server Configuration

Edit `lib/constants/fhir_server_type_enum.dart` to add custom servers:

```dart
enum FhirServerType {
  hapi('https://hapi.fhir.org/baseR4'),
  kodjin('https://demo.kodjin.com/fhir'),
  firefly('https://server.fire.ly'),
  custom('https://your-server.com/fhir');

  final String baseUrl;
  const FhirServerType(this.baseUrl);
}
```

### API Configuration

Modify `lib/constants/api_constants.dart` for timeout and retry settings:

```dart
static const Duration connectTimeout = Duration(seconds: 10);
static const Duration receiveTimeout = Duration(seconds: 15);
static const int maxRetries = 3;
```

### Localization

Add new translations in `assets/l10n/`:

- `en-US.json` - English translations
- `de-DE.json` - German translations

### Theme Configuration

Customize app themes in `lib/src/presentation/widgets/themes/app_themes.dart`

## 🔐 Security Features

- **Secure Storage**: Sensitive data encrypted using `flutter_secure_storage`
- **Token Management**: JWT token handling with automatic refresh
- **HTTPS Only**: All API communications use secure protocols
- **Data Validation**: Input validation before FHIR resource creation
- **Error Handling**: Comprehensive error handling with user-friendly messages

## 🌐 Supported FHIR Resources

- Patient
- Observation
- MedicationRequest
- Appointment
- DiagnosticReport (Lab Results)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Marcel** - [Captured-Heart](https://github.com/Captured-Heart)

**Captured-Heart** on X: [@\_Captured_Heart](https://x.com/_Captured_Heart)

## 🙏 Acknowledgments

- [HAPI FHIR](https://hapifhir.io/) - Open-source FHIR server
- [HAPI Swagger](https://hapi.fhir.org/baseR4/swagger-ui/) - HAPI Demo Server R4 Endpoint Swagger docs
- [HL7 FHIR](https://www.hl7.org/fhir/) - FHIR specification
- [FHIR-FLI](https://fhir-fli.github.io/fhir_fli_documentation/docs) - FHIR-FLI Documentation
- Flutter Community for amazing packages and support

## 📞 Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/Captured-Heart/fhir_demo) or email knkpozi@gmail.com.

## ⚠️ Disclaimer

This is a demo application for educational and development purposes. It should **not** be used in production healthcare environments without proper:

- Security audits
- Compliance certifications (HIPAA, GDPR, etc.)
- Medical device regulations approval
- Professional healthcare IT review

Always consult with healthcare compliance experts before deploying healthcare applications in production.

---

**Version**: 0.0.3+3

**Last Updated**: January 2026

**Built with 💜 using Flutter and FHIR**
