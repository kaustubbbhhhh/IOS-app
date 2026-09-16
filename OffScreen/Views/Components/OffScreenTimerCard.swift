import SwiftUI

public struct OffScreenTimerCard: View {
    let todayTotalMillis: Int64
    let isActive: Bool

    @Environment(\.colorScheme) private var colorScheme
    @State private var isPulsing = false

    public init(todayTotalMillis: Int64, isActive: Bool) {
        self.todayTotalMillis = todayTotalMillis
        self.isActive = isActive
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("TODAY'S OFF-SCREEN TIME")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
                
                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(isActive ? AppColors.green40 : Color.gray.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(isActive && isPulsing ? 1.3 : 1.0)
                        .opacity(isActive && isPulsing ? 0.6 : 1.0)
                    
                    Text(isActive ? "Tracking Active" : "Screen On")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isActive ? AppColors.green40 : AppColors.textSecondary(for: colorScheme))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isActive ? AppColors.green40.opacity(0.12) : Color.gray.opacity(0.1))
                )
            }

            Text(DurationFormatter.formatDuration(millis: todayTotalMillis))
                .font(AppTypography.displayLarge)
                .foregroundColor(AppColors.primary(for: colorScheme))
                .contentTransition(.numericText())
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: todayTotalMillis)

            Text("Time spent with your screen powered off today")
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(cornerRadius: 24, padding: 22)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
