# Died Or Not - Android Client

Android client for the Died Or Not app, built with Jetpack Compose and Kotlin.

## Architecture

This Android app mirrors the iOS architecture:
- **UI**: Jetpack Compose (declarative UI, similar to SwiftUI)
- **Language**: Kotlin with coroutines
- **Backend**: Supabase (shared with iOS, no backend changes needed)
- **Auth**: Anonymous authentication (automatic on first launch)
- **State Management**: ViewModel + StateFlow

## Project Structure

```
app/src/main/java/com/diedornot/app/
├── MainActivity.kt              # App entry point
├── data/
│   ├── SupabaseClient.kt       # Supabase singleton
│   ├── AuthService.kt          # Anonymous auth
│   └── CheckInRepository.kt    # Check-in operations
├── model/
│   ├── UserProfile.kt          # User model
│   └── CheckIn.kt              # Check-in model
└── ui/
    ├── CheckInScreen.kt        # Main UI (Compose)
    ├── CheckInViewModel.kt     # State management
    └── theme/                  # Material 3 theming
```

## Setup

### Prerequisites
- Android Studio Hedgehog (2023.1.1) or later
- JDK 17 or later
- Android SDK API 34
- Supabase project (shared with iOS)

### Configuration

1. Configure Supabase credentials in `gradle.properties`:

```properties
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

2. Open the project in Android Studio:
```bash
cd android
open .
# Or: studio .
```

3. Sync Gradle and build the project

## Running the App

### From Android Studio
1. Connect a device or start an emulator
2. Click Run (▶️) or press Shift+F10

### From Command Line
```bash
# Build the app
./gradlew build

# Install on connected device
./gradlew installDebug

# Build and install in one command
./gradlew installDebug
```

## Key Features

### Anonymous Authentication
- Users are authenticated automatically on first launch
- No login/signup UI required
- Supabase generates a unique user ID

### Check-In System
- Tap to check in for today
- Database constraint prevents duplicate check-ins
- RLS policies ensure data isolation

### Security
- All security enforced at database layer (RLS)
- No permission checks in app code
- Unique constraint prevents duplicates

## Architecture Principles

### Backend is Shared
- Zero backend changes needed for Android support
- Same Supabase instance as iOS
- Same database schema, RLS policies, Edge Functions

### Declarative UI
- Jetpack Compose ≈ SwiftUI
- State-driven updates
- Minimal imperative logic

### Minimal Context
- Each component has a single responsibility
- Clear separation of concerns
- Easy for AI to understand and modify

## Dependencies

### Core
- Jetpack Compose (UI)
- Material 3 (Design system)
- ViewModel + StateFlow (State management)

### Backend
- Supabase Kotlin SDK 2.0.0
  - `postgrest-kt` (database operations)
  - `auth-kt` (authentication)
- Ktor (HTTP client for Supabase)

### Utilities
- Kotlinx Serialization (JSON parsing)
- Kotlinx Coroutines (async operations)

## Development Notes

### Adding New Features
1. Follow the same patterns as iOS implementation
2. Use coroutines for async operations
3. Manage state with ViewModel + StateFlow
4. Keep UI logic declarative

### Database Changes
- Database migrations are shared with iOS
- Located in `supabase/migrations/`
- No Android-specific changes needed

### Testing
- Unit tests for ViewModels and repositories
- UI tests with Compose Testing
- Integration tests with local Supabase

## Troubleshooting

### Build Issues
```bash
# Clean and rebuild
./gradlew clean build

# Sync Gradle files
./gradlew --refresh-dependencies
```

### Supabase Connection Issues
- Verify credentials in `gradle.properties`
- Check internet permissions in AndroidManifest.xml
- Test with local Supabase instance first

### Authentication Issues
- Anonymous auth requires no configuration
- Check Supabase dashboard for auth settings
- Verify RLS policies are applied

## Related Documentation
- [Project README](../README.md)
- [CLAUDE.md](../CLAUDE.md) - AI-friendly development guide
- [iOS App](../ios/DiedOrNot/) - iOS implementation
- [Supabase Setup](../supabase/) - Backend configuration
