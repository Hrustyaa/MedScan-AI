# MedScan AI

MedScan AI is a comprehensive mobile healthcare assistant developed for the **Infomatrix 2026** competition by team **Very Pro Nerds**. The application integrates advanced AI with mobile sensors to provide accessible health monitoring and emergency tools.

## Team: Very Pro Nerds
* **Category:** Software Development
* **Competition:** Infomatrix 2026
* **Tech Stack:** Flutter, Google Gemini API, Firebase

---

## Core Features

### 1. Context-Aware AI Doctor
Integrated with **Gemini 1.5 Flash**, the AI assistant analyzes health symptoms based on real-time biometric data. 
* **Multi-modal:** Supports text and image analysis (e.g., skin symptoms).
* **Trilingual:** Full support for English, Russian, and Kazakh languages.
* **Data-Driven:** AI considers your recent pulse and stress levels for more accurate advice.

### 2. Contactless Pulse Scanner (PPG)
The app uses the smartphone camera and LED flash to estimate heart rate.
* **Technology:** Photoplethysmography (PPG) signal processing.
* **Metrics:** Heart Rate (BPM), Stress Level classification, and SpO2 estimation.
* **Real-time Visualization:** Live waveform rendering during measurement.

### 3. Emergency Toolkit
A specialized module for critical situations that functions offline:
* **First Aid Guide:** A semantic-search enabled database of medical instructions.
* **CPR Metronome:** Visual and haptic rhythm (110 BPM) following AHA guidelines.
* **SOS Beacon:** Programmatic Morse code (SOS) signal using the device flashlight.

### 4. Medication Management
* Smart reminders for medication schedules.
* Automated local notifications with "alarm clock" persistence.
* Treatment history tracking.

### 5. Health Services
* **Doctor Booking:** Catalog of medical specialists with profile details and booking slots.
* **Breathing Exercises:** Guided 4-7-8 breathing technique for stress reduction.

---

## System Architecture

The project follows a **Layered Architecture** to ensure scalability:
* **Presentation Layer:** Flutter UI components and Reactive Data Flow.
* **Service Layer:** Business logic, Gemini API integration, and PPG algorithms.
* **Data Layer:** Firebase Firestore for real-time synchronization and offline persistence.

---

## Technical Setup

### Prerequisites
* Flutter SDK (Latest version)
* Dart 3.x
* Gemini API Key

### Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/Hrustyaa/MedScan-AI.git](https://github.com/Hrustyaa/MedScan-AI.git)
2. Install dependencies:
   ```bash
   flutter pub get
3. Configure API Key:
   For security reasons, the API key is not included in the repository. You must create a new file lib/api_config.dart and add your Gemini API key (or replace it directly in lib/services/ai_service.dart):
   ```bash
   class ApiConfig {
     static const String geminiApiKey = 'YOUR_API_KEY_HERE';
   }
4. Run the app:
   ```bash
   flutter run

### Disclaimer
   Important: MedScan AI is an educational project developed for the Infomatrix competition. It is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of a physician or other qualified health provider with any questions you       may have regarding a medical condition. The AI-generated responses are for informational purposes only.
