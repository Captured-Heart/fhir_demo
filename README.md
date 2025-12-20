# FHIR Medical System - Flutter Demo Application

![Flutter](https://img.shields.io/badge/Flutter-3.7.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.7.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A comprehensive Flutter application demonstrating **FHIR (Fast Healthcare Interoperability Resources)** integration for managing medical data. This application provides a modern, user-friendly interface for healthcare operations including patient registration, diagnosis, prescriptions, vital signs monitoring, appointments, and lab results.

## 🎯 Features

### Medical Forms Management

- **Register Patient** - Add new patient records with complete demographic information
- **Diagnosis** - Record medical diagnoses with severity levels and clinical status
- **Prescriptions** - Manage medication prescriptions with dosage and frequency
- **Observations** - Track vital signs (blood pressure, heart rate, temperature, etc.)
- **Appointments** - Schedule and manage patient appointments
- **Lab Results** - Record and view laboratory test results

### FHIR Integration

- ✅ Dynamic server configuration (HAPI FHIR, Azure, AWS, Custom)
- ✅ Real-time base URL switching without app restart
- ✅ Configurable request timeouts
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

## 🏗️ Architecture

### Clean Architecture Pattern

```
lib/
├── constants/          # App-wide constants (API, colors, routes, etc.)
├── hive_helper/        # Local storage helpers and adapters
├── src/
│   ├── controller/     # Riverpod state management controllers
│   ├── data/           # Data layer (repositories, network)
│   │   └── repository/
│   │       └── network/  # Dio HTTP client implementation
│   ├── domain/         # Business logic layer
│   │   ├── entities/   # Domain entities
│   │   ├── models/     # Data models
│   │   └── repository/ # Repository interfaces
│   └── presentation/   # UI layer
│       ├── views/      # Screen views
│       │   └── forms/  # Medical form views
│       └── widgets/    # Reusable widgets
└── utils/             # Utility functions
```

### Key Technologies

- **State Management**: Riverpod
- **HTTP Client**: Dio with interceptors
- **Local Storage**: Hive
- **FHIR Library**: fhir_r4
- **Internationalization**: easy_localization
- **Connectivity**: internet_connection_checker_plus

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK (3.7.0 or higher)
- Android Studio / Xcode (for mobile development)
- A FHIR server (default: HAPI FHIR public server)

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/fhir_demo.git
cd fhir_demo
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run code generation** (for Hive adapters)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**

```bash
flutter run
```

## ⚙️ Configuration

### FHIR Server Setup

The app comes pre-configured with the HAPI FHIR public test server. You can change this in the Settings view:

1. Open the app and navigate to **Settings**
2. Select **Server Type** (HAPI, Azure, AWS, or Custom)
3. Enter your **Server Base URL**
4. Configure **Authentication** if required
5. Set **Request Timeout** (default: 30 seconds)
6. Test the connection

**Default Configuration:**

```dart
Server Type: HAPI
Base URL: https://hapi.fhir.org/baseR4
Authentication: Disabled
Timeout: 30 seconds
```

### Dynamic Base URL

The app supports dynamic base URL changes at runtime:

```dart
// In your code
ref.read(fhirSettingsProvider.notifier).updateServerUrl('https://your-server.com/fhir');
// All API calls will now use the new URL automatically
```

## 📱 App Structure

### Home Screen

Grid view displaying all available medical forms:

- Color-coded cards for easy identification
- Icon representation for each form type
- Quick navigation to form details

### Medical Forms

#### 1. Register Patient

- Personal information (name, DOB, gender)
- Contact details (phone, email, address)
- Emergency contact information
- Form validation

#### 2. Diagnosis

- Patient ID lookup
- Condition/diagnosis entry
- Severity levels (Mild, Moderate, Severe)
- Clinical status tracking
- Diagnosing doctor information
- Clinical notes

#### 3. Prescriptions

- Medication details
- Dosage and route of administration
- Frequency and duration
- Prescribing doctor
- Special instructions

#### 4. Observations (Vital Signs)

- Blood pressure
- Heart rate
- Temperature
- Respiratory rate
- Oxygen saturation
- Weight and height
- Clinical notes

#### 5. Appointments

- Patient and doctor assignment
- Appointment type selection
- Date and time scheduling
- Status tracking
- Location details
- Visit reason

#### 6. Lab Results

- Test information
- Result values with units
- Reference ranges
- Interpretation (Normal, High, Low, Critical)
- Status tracking
- Specimen details

### Settings View

- Server configuration
- Authentication settings
- Timeout configuration
- Connection testing
- Reset to defaults

## 🔧 Key Components

### Network Layer

- **DioRepository**: HTTP client with automatic retries
- **TokenRepository**: Authentication token management
- **Interceptors**: Logging, retry, and authentication
- **Dynamic base URL**: Real-time server switching

### State Management

- **Riverpod Providers**: For dependency injection and state
- **Notifiers**: For complex state management
- **Auto-dispose**: Efficient memory management

### Custom Widgets

- **MoodTextfield**: Enhanced text input field
- **MoodPrimaryButton**: Primary action button with loading states
- **MoodOutlineButton**: Secondary action button
- **MedicalFormCard**: Reusable card for medical forms

## 🌐 API Integration

### FHIR Resources Supported

- Patient
- Condition (Diagnosis)
- MedicationRequest (Prescriptions)
- Observation (Vital Signs)
- Appointment
- DiagnosticReport (Lab Results)

### Example API Call

```dart
final dioRepo = ref.read(dioRepositoryProvider);
await dioRepo.initialize();

// POST request to create a patient
final response = await dioRepo.post(
  '/Patient',
  data: patientData,
);
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📦 Dependencies

### Core

- `flutter_riverpod: ^2.6.1` - State management
- `dio: ^5.9.0` - HTTP client
- `hive: ^2.2.3` - Local storage
- `fhir_r4: ^0.4.3` - FHIR resources

### Network

- `dio_smart_retry: ^7.0.1` - Automatic retries
- `internet_connection_checker_plus: ^2.7.2` - Connectivity monitoring

### UI/UX

- `flutter_animate: ^4.5.2` - Animations
- `easy_localization: ^3.0.7` - Internationalization

### Security

- `flutter_secure_storage: ^9.2.4` - Secure token storage
- `crypto: ^3.0.6` - Cryptographic operations

## 🎨 Theming

The app supports both light and dark themes with custom colors:

- **Primary**: Brown (#926247)
- **Primary Container**: Tan (#C3A381)
- **Medical Green**: #4CAF50
- **Medical Blue**: #2196F3
- **Medical Orange**: #FF9800

## 🌍 Localization

Supported languages:

- 🇺🇸 English (en-US)
- 🇩🇪 German (de-DE)

Add translations in `assets/l10n/`

## 🚧 Roadmap

- [ ] Complete FHIR API integration for all forms
- [ ] Offline data synchronization
- [ ] Biometric authentication
- [ ] PDF report generation
- [ ] Search and filtering capabilities
- [ ] Advanced analytics dashboard
- [ ] Role-based access control
- [ ] Push notifications
- [ ] Image upload support (X-rays, documents)
- [ ] Video consultations

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

**Captured-Heart** on X: (https://x.com/_Captured_Heart)


## 🙏 Acknowledgments

- [HAPI FHIR](https://hapifhir.io/) - Open-source FHIR server
- [HAPI Swagger](https://hapi.fhir.org/baseR4/swagger-ui/) - HAPI Demo Server R4 Endpoint Swagger docs
- [HL7 FHIR](https://www.hl7.org/fhir/) - FHIR specification
- [FHIR-FLI](https://fhir-fli.github.io/fhir_fli_documentation/docs) - FHI-FLI Docs
- Flutter Community

## 📞 Support

For support, email knkpozi@gmail.com or open an issue in the repository.

## ⚠️ Disclaimer

This is a demo application for educational and development purposes. It should not be used in production healthcare environments without proper security audits, compliance certifications (HIPAA, GDPR, etc.), and medical device regulations approval.

---

**Built with 💜 using Flutter and FHIR**
