import Foundation
import Supabase

@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()

    let client: SupabaseClient
    @Published var currentUserId: UUID?
    @Published var isAuthenticated = false

    private init() {
        client = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )

        Task {
            await signInAnonymously()
        }
    }

    func signInAnonymously() async {
        do {
            // 尝试获取现有 session
            if let session = try? await client.auth.session {
                currentUserId = session.user.id
                isAuthenticated = true
                print("✅ 已有匿名登录 session: \(session.user.id)")
                return
            }

            // 创建新的匿名登录
            let session = try await client.auth.signInAnonymously()
            currentUserId = session.user.id
            isAuthenticated = true
            print("✅ 匿名登录成功: \(session.user.id)")

            // 创建用户记录
            try await createUserProfile()

        } catch {
            print("❌ 匿名登录失败: \(error.localizedDescription)")
        }
    }

    private func createUserProfile() async throws {
        guard let userId = currentUserId else { return }

        let user: [String: Any] = [
            "id": userId.uuidString,
            "name": "匿名用户",
            "emergency_email": "example@example.com"
        ]

        do {
            try await client.from("users")
                .insert(user)
                .execute()
            print("✅ 用户记录创建成功")
        } catch {
            // 如果记录已存在，忽略错误
            print("ℹ️ 用户记录可能已存在: \(error.localizedDescription)")
        }
    }

    func checkIn() async throws {
        guard let userId = currentUserId else {
            throw NSError(domain: "DiedOrNot", code: -1, userInfo: [NSLocalizedDescriptionKey: "未登录"])
        }

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let today = dateFormatter.string(from: Date())

        let checkIn: [String: Any] = [
            "user_id": userId.uuidString,
            "check_in_date": today
        ]

        try await client.from("check_ins")
            .insert(checkIn)
            .execute()

        print("✅ 签到成功: \(today)")
    }

    func getTodayCheckIn() async throws -> Bool {
        guard let userId = currentUserId else { return false }

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let today = dateFormatter.string(from: Date())

        let response = try await client.from("check_ins")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("check_in_date", value: today)
            .execute()

        let data = String(data: response.data, encoding: .utf8) ?? ""
        let hasCheckedIn = data != "[]"

        print("ℹ️ 今日签到状态: \(hasCheckedIn)")
        return hasCheckedIn
    }
}
