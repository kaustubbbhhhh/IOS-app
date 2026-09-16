import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    let dashboardViewModel: DashboardViewModel
    let historyViewModel: HistoryViewModel

    @Environment(\.colorScheme) private var colorScheme

    public init(dashboardViewModel: DashboardViewModel, historyViewModel: HistoryViewModel) {
        self.dashboardViewModel = dashboardViewModel
        self.historyViewModel = historyViewModel
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(
                viewModel: dashboardViewModel,
                onNavigateToHistory: {
                    HapticManager.shared.selection()
                    selectedTab = 1
                }
            )
            .tabItem {
                Label("Today", systemImage: "calendar")
            }
            .tag(0)

            HistoryView(viewModel: historyViewModel)
                .tabItem {
                    Label("History", systemImage: "chart.bar.xaxis")
                }
                .tag(1)
        }
        .tint(AppColors.primary(for: colorScheme))
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}
