import SwiftUI
import SwiftData

@main
struct AutismApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                GetStarted()
            }
            .preferredColorScheme(.light)
            .environmentObject(LanguageManager.shared)
            .modelContainer(for: [OfflineAssessment.self, OfflineResponse.self])
        }
    }
}
