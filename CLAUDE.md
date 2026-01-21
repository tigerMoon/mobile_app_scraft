# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Died Or Not** is an AI-friendly fullstack app scaffold designed for rapid MVP development. The architecture prioritizes declarative patterns and minimal context to maximize AI code generation accuracy.

### Core Philosophy
- **Frontend is Fullstack**: No custom backend servers
- **Declarative First**: UI (SwiftUI), SQL, and permissions (RLS)
- **Database as Rule Center**: Security and business rules enforced at the database layer
- **Minimal Context, Maximum Certainty**: Designed for AI-assisted development

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | SwiftUI (iOS), Jetpack Compose (Android) |
| Backend | Supabase (BaaS) |
| Auth | Anonymous Auth |
| Database | PostgreSQL + Row Level Security (RLS) |
| Server Logic | Supabase Edge Functions (Deno) |
| Scheduled Tasks | Supabase Cron Jobs |

## Common Development Commands

### Supabase Setup
```bash
# Initialize Supabase (first time)
supabase init

# Push database migrations
supabase db push

# Deploy Edge Functions
supabase functions deploy

# Deploy specific function
supabase functions deploy check-missed-check-ins
supabase functions deploy send-notification-email

# Start local Supabase
supabase start

# Stop local Supabase
supabase stop
```

### Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Required environment variables:
# - SUPABASE_URL
# - SUPABASE_ANON_KEY
# - SUPABASE_SERVICE_ROLE_KEY
```

### iOS Development
```bash
# Open iOS project in Xcode
open ios/DiedOrNot
```

In Xcode, configure Supabase credentials before running the app.

### Android Development
```bash
# Open Android project in Android Studio
open android/

# Or build from command line
cd android
./gradlew build

# Install on connected device
./gradlew installDebug
```

Configure Supabase credentials in `android/gradle.properties` before running the app.

## Architecture Details

### Authentication Flow
- **Anonymous Auth**: Users are automatically authenticated on first app launch
- Supabase generates a unique `user_id` automatically
- No registration, passwords, or login UI required
- Data isolation handled automatically via RLS policies

### Database Schema

**users table** (`supabase/migrations/001_init.sql:1-6`):
- `id`: UUID (references auth.users)
- `name`: User's name
- `emergency_email`: Contact email for notifications
- `created_at`: Timestamp

**check_ins table** (`supabase/migrations/001_init.sql:8-14`):
- `id`: UUID (auto-generated)
- `user_id`: Foreign key to users
- `check_in_date`: Date of check-in
- `created_at`: Timestamp
- **Constraint**: `unique (user_id, check_in_date)` prevents duplicate check-ins

### Row Level Security (RLS)

All security rules are defined at the database layer in `supabase/migrations/002_rls.sql`:

```sql
-- Users can only manage their own data
create policy "user manage self"
on users for all
using (auth.uid() = id);

-- Users can only manage their own check-ins
create policy "user manage own checkins"
on check_ins for all
using (auth.uid() = user_id);
```

**Important**: Do NOT implement permission checks in application code. RLS policies handle all authorization automatically.

### Edge Functions

**check-missed-check-ins** (`supabase/functions/check-missed-check-ins/index.ts`):
- Triggered by Supabase Cron (scheduled task)
- Scans all users to find their last check-in date
- If 2+ days since last check-in, triggers notification
- Uses `SUPABASE_SERVICE_ROLE_KEY` to bypass RLS for admin operations

**send-notification-email** (`supabase/functions/send-notification-email/index.ts`):
- Receives user information from check-missed-check-ins
- Logs notification (placeholder for actual email/SMS/webhook implementation)
- Extensible to integrate real notification services

### iOS App Structure

**DiedOrNotApp.swift** (`ios/DiedOrNot/App/DiedOrNotApp.swift:1-10`):
- Main app entry point
- Minimal SwiftUI app structure

**CheckInView.swift** (`ios/DiedOrNot/Views/CheckInView.swift:1-11`):
- Main check-in interface (currently placeholder)
- Needs Supabase client integration for real functionality
- Should call Supabase API to insert check-in records

### Android App Structure

The Android app mirrors the iOS architecture using Kotlin and Jetpack Compose:

```
android/app/src/main/java/com/diedornot/app/
├── MainActivity.kt              # App entry point
├── data/
│   ├── SupabaseClient.kt       # Supabase singleton (mirrors iOS SupabaseManager)
│   ├── AuthService.kt          # Anonymous authentication
│   └── CheckInRepository.kt    # Check-in data operations
├── model/
│   ├── UserProfile.kt          # User model (maps to 'users' table)
│   └── CheckIn.kt              # Check-in model (maps to 'check_ins' table)
└── ui/
    ├── CheckInScreen.kt        # Main UI (Jetpack Compose, mirrors iOS CheckInView)
    ├── CheckInViewModel.kt     # State management
    └── theme/                  # Material 3 theming
```

**Key Design Parallels with iOS**:
- `SupabaseClient.kt` ≈ iOS `SupabaseManager.swift`
- `CheckInScreen.kt` (Compose) ≈ iOS `CheckInView.swift` (SwiftUI)
- `CheckInViewModel` ≈ iOS `@StateObject` pattern
- Both use declarative UI (Compose ≈ SwiftUI)
- Both use same Supabase backend (zero backend changes needed)

## Key Design Patterns

### Security Through Database Constraints
Instead of validating business rules in code, enforce them in the database:
- Duplicate prevention: `unique (user_id, check_in_date)`
- Data isolation: RLS policies with `auth.uid() = user_id`
- This reduces AI-generated bugs and ensures consistency

### Minimal Server Logic
Edge Functions are deliberately simple and deterministic:
- Single responsibility per function
- Clear input/output contracts
- Easy to understand and modify
- Reduces context needed for AI code generation

### Declarative UI
Both iOS and Android use declarative UI frameworks that align with AI code generation:
- **iOS**: SwiftUI
- **Android**: Jetpack Compose
- Both: State-driven UI updates, minimal imperative logic, clear component boundaries
- This consistency across platforms reduces cognitive load and simplifies maintenance

## Development Guidelines

### When Modifying Database Schema
1. Create new migration file in `supabase/migrations/`
2. Follow naming convention: `00X_description.sql`
3. Apply RLS policies in separate migration or same file
4. Test locally with `supabase db push`

### When Adding Edge Functions
1. Create new directory in `supabase/functions/`
2. Include `index.ts` and `deno.json`
3. Use `createClient` with `SUPABASE_SERVICE_ROLE_KEY` for admin access
4. Use `SUPABASE_ANON_KEY` for user-level operations
5. Deploy with `supabase functions deploy <function-name>`

### When Modifying iOS Views
1. Integrate Supabase Swift client if not already present
2. Use async/await for Supabase API calls
3. Handle authentication state properly
4. Leverage SwiftUI's state management (@State, @StateObject)

### When Modifying Android Views
1. Use Jetpack Compose for declarative UI
2. Use Kotlin coroutines for async operations (Supabase calls)
3. Manage state with ViewModel + StateFlow
4. Follow Material 3 design guidelines
5. Keep UI logic parallel to iOS implementation

## Configuration Files

- `supabase/config.toml`: Local Supabase development configuration
  - API port: 54321
  - Database port: 54322
  - Studio port: 54323
  - Inbucket (email testing): 54324

- `.env.example`: Template for required environment variables
  - Copy to `.env` and fill in actual Supabase credentials

- `android/gradle.properties`: Android-specific Supabase configuration
  - Set `SUPABASE_URL` and `SUPABASE_ANON_KEY`
  - These are loaded as BuildConfig fields at compile time

## Testing Strategy

### Local Development
- Use Supabase local development (`supabase start`)
- Test Edge Functions locally before deployment
- Use Inbucket for email testing (port 54324)
- Verify RLS policies by testing with different auth contexts

### Edge Function Testing
```bash
# Test function locally
supabase functions serve <function-name>

# Send test request
curl -i --location --request POST 'http://localhost:54321/functions/v1/<function-name>' \
  --header 'Authorization: Bearer <anon-key>' \
  --header 'Content-Type: application/json' \
  --data '{"key":"value"}'
```

## Important Notes for AI Code Generation

1. **Never bypass RLS**: Application code should not implement permission checks. Trust RLS policies.

2. **Unique constraints prevent duplicates**: Don't write code to check for duplicate check-ins; the database constraint handles this.

3. **Use appropriate keys**:
   - `SUPABASE_ANON_KEY` for client-side operations (respects RLS)
   - `SUPABASE_SERVICE_ROLE_KEY` for admin operations (bypasses RLS)

4. **Anonymous auth is automatic**: Don't implement login/signup flows. Users are authenticated on first app launch.

5. **Edge Functions use Deno**: Not Node.js. Use Deno-compatible imports (e.g., `https://esm.sh/...`).

6. **Keep context minimal**: Each component should have clear, limited responsibilities to reduce complexity.

7. **Multi-platform by design**: iOS and Android share the same backend (Supabase). No backend changes needed to support new platforms. Just implement another client following the same patterns.
