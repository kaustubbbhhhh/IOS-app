import SwiftUI

public struct StreakBadge: View {
    let streakDays: Int
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    public init(streakDays: Int, action: @escaping () -> Void) {
        self.streakDays = streakDays
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            action()
        }) {
            HStack(spacing: 5) {
                Text("🔥")
                    .font(.system(size: 15))
                Text("\(streakDays)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(streakDays > 0 ? AppColors.flameColor : AppColors.textSecondary(for: colorScheme))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(streakDays > 0 ? AppColors.flameColor.opacity(0.15) : Color.gray.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(streakDays > 0 ? AppColors.flameColor.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .springPress()
    }
}
