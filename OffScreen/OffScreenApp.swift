import SwiftUI
import SwiftData

@main
struct OffScreenApp: App {
    let container: ModelContainer
    let repository: SessionRepository
    let dashboardViewModel: DashboardViewModel
    let historyViewModel: HistoryViewModel

    @State private var goalPreferences = GoalPreferences.shared

    init() {
        do {
            let schema = Schema([OffScreenSession.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            self.container = modelContainer
            
            let repo = SessionRepository(modelContext: modelContainer.mainContext)
            self.repository = repo
            self.dashboardViewModel = DashboardViewModel(repository: repo)
            self.historyViewModel = HistoryViewModel(repository: repo)

            // Configure screen tracking service
            ScreenTrackingService.shared.configure(with: repo)
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if !goalPreferences.isOnboardingCompleted {
                OnboardingView(onComplete: {
                    dashboardViewModel.refresh()
                    historyViewModel.refresh()
                })
            } else {
                MainTabView(
                    dashboardViewModel: dashboardViewModel,
                    historyViewModel: historyViewModel
                )
            }
        }
        .modelContainer(container)
    }
}
