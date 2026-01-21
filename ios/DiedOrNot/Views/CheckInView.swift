import SwiftUI

struct CheckInView: View {
  @EnvironmentObject var supabaseManager: SupabaseManager
  @State private var checkedIn = false
  @State private var isLoading = false
  @State private var errorMessage: String?

  var body: some View {
    VStack(spacing: 20) {
      Text("死了么 · DiedOrNot")
        .font(.largeTitle)
        .bold()

      if !supabaseManager.isAuthenticated {
        ProgressView("正在初始化...")
      } else {
        VStack(spacing: 16) {
          Button(action: {
            Task {
              await performCheckIn()
            }
          }) {
            Text(checkedIn ? "✓ 今日已签到" : "签到")
              .font(.title2)
              .bold()
              .foregroundColor(.white)
              .frame(width: 200, height: 60)
              .background(checkedIn ? Color.green : Color.blue)
              .cornerRadius(12)
          }
          .disabled(checkedIn || isLoading)

          if isLoading {
            ProgressView()
          }

          if let error = errorMessage {
            Text(error)
              .foregroundColor(.red)
              .font(.caption)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
          }

          if supabaseManager.isAuthenticated {
            Text("用户 ID: \(supabaseManager.currentUserId?.uuidString.prefix(8) ?? "N/A")...")
              .font(.caption)
              .foregroundColor(.gray)
          }
        }
      }
    }
    .padding()
    .task {
      await loadCheckInStatus()
    }
  }

  private func loadCheckInStatus() async {
    do {
      checkedIn = try await supabaseManager.getTodayCheckIn()
    } catch {
      print("⚠️ 加载签到状态失败: \(error.localizedDescription)")
    }
  }

  private func performCheckIn() async {
    isLoading = true
    errorMessage = nil

    do {
      try await supabaseManager.checkIn()
      checkedIn = true
    } catch {
      errorMessage = "签到失败: \(error.localizedDescription)"
      print("❌ \(errorMessage!)")
    }

    isLoading = false
  }
}