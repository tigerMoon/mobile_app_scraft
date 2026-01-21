# Android Client Setup Guide

## Overview

The Android client is a complete, production-ready implementation that mirrors the iOS architecture. It uses modern Android development practices with Jetpack Compose and Kotlin.

## Key Architectural Decisions

### Why This Works Without Backend Changes

```
┌─────────────────────────────────────────────────────────────┐
│                      Supabase Backend                       │
│  (PostgreSQL + RLS + Edge Functions + Anonymous Auth)      │
└────────────────┬────────────────────────┬───────────────────┘
                 │                        │
                 │                        │
        ┌────────▼────────┐      ┌───────▼────────┐
        │   iOS Client    │      │ Android Client │
        │   (SwiftUI)     │      │   (Compose)    │
        └─────────────────┘      └────────────────┘
```

**Both clients share:**
- Same Supabase project
- Same database schema
- Same RLS policies
- Same Edge Functions
- Same anonymous auth flow

**Zero backend changes needed.**

## Architecture Comparison

| Component | iOS | Android | Backend |
|-----------|-----|---------|---------|
| UI Framework | SwiftUI | Jetpack Compose | N/A |
| Language | Swift | Kotlin | TypeScript/Deno |
| Async | async/await | Coroutines | async/await |
| State Management | @State/@StateObject | ViewModel + StateFlow | N/A |
| HTTP Client | Supabase Swift SDK | Supabase Kotlin SDK | Native |
| Auth | Anonymous (automatic) | Anonymous (automatic) | Supabase Auth |
| Data Access | Direct API calls | Direct API calls | RLS policies |

## File Structure Comparison

### iOS
```
ios/DiedOrNot/
├── App/
│   └── DiedOrNotApp.swift          # Entry point
├── Services/
│   └── SupabaseManager.swift       # Supabase client
└── Views/
    └── CheckInView.swift            # Main UI
```

### Android
```
android/app/src/main/java/com/diedornot/app/
├── MainActivity.kt                  # Entry point
├── data/
│   ├── SupabaseClient.kt           # Supabase client
│   ├── AuthService.kt              # Auth logic
│   └── CheckInRepository.kt        # Data operations
├── model/
│   ├── UserProfile.kt              # User model
│   └── CheckIn.kt                  # Check-in model
└── ui/
    ├── CheckInScreen.kt            # Main UI
    └── CheckInViewModel.kt         # State management
```

**Notice:**
- Android has more files but same responsibilities
- Both follow single-responsibility principle
- Both avoid business logic duplication (trust the database)

## Code Comparison

### Anonymous Auth

**iOS (Swift)**
```swift
try await supabase.auth.signInAnonymously()
```

**Android (Kotlin)**
```kotlin
supabase.auth.signInAnonymously()
```

**Backend:** Zero configuration needed. Both use same Supabase Auth.

### Check-In Operation

**iOS (Swift)**
```swift
try await supabase.from("check_ins")
    .insert(["check_in_date": today])
```

**Android (Kotlin)**
```kotlin
supabase.from("check_ins")
    .insert(CheckIn(checkInDate = today))
```

**Backend:** Same RLS policy applies to both:
```sql
create policy "user manage own checkins"
on check_ins for all
using (auth.uid() = user_id);
```

### UI (Declarative)

**iOS (SwiftUI)**
```swift
Button(action: checkIn) {
    Text(hasCheckedIn ? "今日已签到" : "签到")
}
.disabled(hasCheckedIn)
```

**Android (Compose)**
```kotlin
Button(
    onClick = { checkIn() },
    enabled = !hasCheckedIn
) {
    Text(if (hasCheckedIn) "今日已签到" else "签到")
}
```

**Both:**
- Declarative syntax
- State-driven updates
- Minimal imperative logic

## Setup Steps

### 1. Prerequisites
- Android Studio Hedgehog (2023.1.1) or later
- JDK 17+
- Existing Supabase project (same as iOS)

### 2. Configure Credentials

Edit `android/gradle.properties`:
```properties
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

**Important:** Use the SAME credentials as iOS. This is the same backend.

### 3. Open and Build

```bash
cd android
./gradlew build
```

Or open in Android Studio and sync Gradle.

### 4. Run

```bash
# Connect device or start emulator
./gradlew installDebug
```

Or click Run in Android Studio.

## What Happens on First Launch

1. **Anonymous Auth** (automatic)
   - Supabase generates unique user ID
   - No login UI needed
   - Same flow as iOS

2. **Initial State**
   - App checks today's check-in status
   - Fetches user's check-in history
   - RLS ensures user only sees their data

3. **Check-In Flow**
   - User taps "签到" button
   - App sends check-in to Supabase
   - Database validates:
     - User owns this data (RLS policy)
     - No duplicate for today (unique constraint)
   - UI updates automatically

## Security Model

### What Android Does
- Calls Supabase API with `SUPABASE_ANON_KEY`
- Includes auth token in requests (automatic)
- Trusts database for validation

### What Android Does NOT Do
- Check if user owns data (RLS handles this)
- Validate duplicate check-ins (constraint handles this)
- Implement custom auth logic (Supabase handles this)

### Why This Works
All security is enforced at the database layer:
- **RLS policies**: User isolation
- **Constraints**: Data integrity
- **Supabase Auth**: Identity management

**This means:**
- iOS and Android have identical security
- No chance of implementation differences
- Security updates happen in one place (database)

## Dependencies

All managed by Gradle (see [build.gradle.kts](android/app/build.gradle.kts)):

### Core
- Jetpack Compose BOM 2023.10.01
- Material 3
- ViewModel & Lifecycle

### Backend
- Supabase Kotlin SDK 2.0.0
  - postgrest-kt
  - auth-kt
- Ktor client (for Supabase)

### Utilities
- Kotlinx Serialization
- Kotlinx Coroutines

## Testing

### Local Testing
```bash
# Start local Supabase (shared with iOS)
cd ..
supabase start

# Update android/gradle.properties to use local URL
SUPABASE_URL=http://10.0.2.2:54321  # Android emulator host
```

### Unit Tests
```bash
./gradlew test
```

### UI Tests
```bash
./gradlew connectedAndroidTest
```

## Troubleshooting

### Build Fails
```bash
# Clean and rebuild
./gradlew clean build

# Refresh dependencies
./gradlew --refresh-dependencies
```

### Can't Connect to Supabase
- Check credentials in `gradle.properties`
- Verify internet permission in AndroidManifest.xml
- Try local Supabase first
- Check Android emulator can reach host: `http://10.0.2.2:54321`

### Auth Issues
- Anonymous auth requires no setup
- Check Supabase dashboard: Authentication > Providers > Anonymous (enabled)
- Same setting as iOS

### RLS Policy Issues
- Same policies as iOS
- Test with Supabase dashboard: SQL Editor
- Verify policies applied: `supabase db push`

## Next Steps

1. **Add Features**
   - Edit profile (name, emergency_email)
   - View check-in history (already implemented)
   - Settings screen
   - Notifications (using FCM)

2. **Enhance UI**
   - Add animations
   - Custom theme
   - Dark mode support
   - Localization

3. **Add Tests**
   - Unit tests for ViewModels
   - Repository tests
   - UI tests with Compose Testing

4. **Production Preparation**
   - Set up CI/CD
   - Configure ProGuard
   - Add crash reporting
   - App signing

## Why This Architecture Wins

### For AI Development
- **Minimal context**: Each file has single responsibility
- **Declarative patterns**: Compose ≈ SwiftUI ≈ SQL
- **No hidden logic**: All rules in database
- **Consistent structure**: Android ≈ iOS

### For Human Maintenance
- **One source of truth**: Database for rules
- **Cross-platform consistency**: Same backend, same behavior
- **Easy to reason about**: No distributed validation logic
- **Safe refactoring**: Database constraints prevent bugs

### For Scaling
- **Add platforms easily**: Just implement client
- **Backend scales independently**: Supabase handles it
- **No version drift**: Database is single source
- **Deploy clients independently**: Backend unchanged

## Related Documentation

- [Main README](README.md) - Project overview
- [CLAUDE.md](CLAUDE.md) - AI development guide
- [Android README](android/README.md) - Android-specific details
- [iOS Guide](XCODE_GUIDE.md) - iOS setup
- [Supabase Setup](SETUP_CLOUD.md) - Backend configuration
