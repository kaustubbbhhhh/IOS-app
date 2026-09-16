import SwiftUI

public struct OnboardingView: View {
    let onComplete: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var currentStep = 0

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            AppColors.background(for: colorScheme)
                .ignoresSafeArea()

            VStack {
                TabView(selection: $currentStep) {
                    // Step 0: Welcome
                    onboardingPage(
                        iconName: "moon.stars.fill",
                        title: "Welcome to OffScreen",
                        subtitle: "Track your time away from your device and build healthy digital habits effortlessly.",
                        buttonText: "Continue",
                        showSkip: false,
                        onAction: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentStep = 1
                            }
                        }
                    )
                    .tag(0)

                    // Step 1: Notifications
                    onboardingPage(
                        iconName: "bell.badge.fill",
                        title: "Stay Notified",
                        subtitle: "Get gentle progress milestones and celebrations when you achieve your daily goals.",
                        buttonText: "Enable Notifications",
                        showSkip: true,
                        onAction: {
                            Task {
                                _ = await NotificationService.shared.requestAuthorization()
                                await MainActor.run {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        currentStep = 2
                                    }
                                }
                            }
                        },
                        onSkip: {
                            withAnimation { currentStep = 2 }
                        }
                    )
                    .tag(1)

                    // Step 2: Background Tracking
                    onboardingPage(
                        iconName: "lock.shield.fill",
                        title: "Effortless Tracking",
                        subtitle: "OffScreen automatically detects when your device is locked and records your downtime.",
                        buttonText: "Got It",
                        showSkip: true,
                        onAction: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentStep = 3
                            }
                        },
                        onSkip: {
                            withAnimation { currentStep = 3 }
                        }
                    )
                    .tag(2)

                    // Step 3: Ready
                    onboardingPage(
                        iconName: "rocket.fill",
                        title: "You're All Set!",
                        subtitle: "Put your phone down, live in the moment, and watch your daily streak grow.",
                        buttonText: "Start Tracking",
                        showSkip: false,
                        onAction: {
                            HapticManager.shared.notification(.success)
                            GoalPreferences.shared.isOnboardingCompleted = true
                            onComplete()
                        }
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
        }
    }

    private func onboardingPage(
        iconName: String,
        title: String,
        subtitle: String,
        buttonText: String,
        showSkip: Bool,
        onAction: @escaping () -> Void,
        onSkip: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppColors.primary(for: colorScheme).opacity(0.12))
                    .frame(width: 130, height: 130)

                Image(systemName: iconName)
                    .font(.system(size: 58))
                    .foregroundColor(AppColors.primary(for: colorScheme))
            }
            .padding(.bottom, 16)

            Text(title)
                .font(AppTypography.displayMedium)
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(AppTypography.bodyLarge)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    HapticManager.shared.impact(.light)
                    onAction()
                }) {
                    Text(buttonText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(AppColors.primary(for: colorScheme))
                        )
                        .shadow(color: AppColors.primary(for: colorScheme).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .springPress()

                if showSkip, let onSkip = onSkip {
                    Button(action: {
                        HapticManager.shared.impact(.light)
                        onSkip()
                    }) {
                        Text("Skip for now")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(height: 38)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
    }
}
