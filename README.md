# BMI Calculator

A polished Flutter BMI Calculator app focused on a clean user experience, accessible input, local persistence, and practical health-oriented feedback.

This project started as a simple BMI calculator and now includes settings, themed UI, BMI education, saved result history, and shareable results. It is built as a local-first mobile app with room for future feature expansion.

## Overview

The app helps users:

- calculate Body Mass Index using metric or imperial units
- review BMI category feedback and health tips
- set and persist a target BMI
- save BMI results locally for later review
- share results with others
- switch between light, dark, and system theme modes

## Current Features

- **BMI calculation**
  - Calculates BMI from height and weight
  - Supports both `Metric` and `Imperial` measurement systems
  - Displays category-based results such as underweight, normal, overweight, and obese

- **Guided result experience**
  - Shows BMI value prominently
  - Includes category-aware guidance and tips
  - Displays target-BMI-related messaging

- **Accessible input controls**
  - Supports sliders for quick adjustment
  - Includes inline numeric text fields for height, weight, and target BMI

- **History**
  - Save results locally on device
  - View saved BMI entries in a dedicated history screen
  - Open result details for saved entries
  - Delete individual entries or clear history

- **Share**
  - Share a plain-text BMI result summary through the platform share sheet

- **Settings and personalization**
  - Persist default measurement unit
  - Persist target BMI
  - Persist theme mode

- **Extra screens**
  - Animated splash screen
  - BMI information screen
  - Modern card-based settings screen

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **State approach:** Stateful widgets with local app state
- **Persistence:** `shared_preferences`
- **Typography:** `google_fonts`
- **Sharing:** `share_plus`
- **Testing:** `flutter_test`

## Project Structure

```text
lib/
  core/
    constants/
    repositories/
    theme/
    utils/
  models/
  ui/
    navigation/
    screens/

test/
  core/
  models/
  ui/
```

## Getting Started

### Prerequisites

Make sure you have:

- Flutter SDK installed
- Dart SDK included with Flutter
- An emulator, simulator, or physical device available

To confirm your setup:

```bash
flutter doctor
```

### Installation

1. Clone the repository:

```bash
git clone https://github.com/najeeb-karimi/flutter-bmi-calculator.git
cd flutter-bmi-calculator
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Useful Commands

Run tests:

```bash
flutter test
```

Analyze the codebase:

```bash
flutter analyze
```

## Roadmap

Currently at version 1.1.0, the project is actively evolving. More features are on the way, including broader health insights, richer goal tracking, charting, reminders, localization, and further accessibility improvements.

## Notes

- This app is intended for informational and educational use.
- BMI is a useful screening metric, but it is not a diagnosis.
- For medical decisions, users should consult a qualified healthcare professional.