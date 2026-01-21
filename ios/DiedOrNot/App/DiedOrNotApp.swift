import SwiftUI

@main
struct DiedOrNotApp: App {
  @StateObject private var supabaseManager = SupabaseManager.shared

  var body: some Scene {
    WindowGroup {
      CheckInView()
        .environmentObject(supabaseManager)
    }
  }
}