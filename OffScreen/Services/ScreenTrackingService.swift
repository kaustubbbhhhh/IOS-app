import Foundation
import UIKit
import SwiftData
import Combine

@MainActor
public final class ScreenTrackingService: ObservableObject {
    public static let shared = ScreenTrackingService()

    private var repository: SessionRepository?
    private var cancellables = Set<AnyCancellable>()

    @Published public private(set) var isTracking: Bool = false
    @Published public private(set) var activeSessionStartTime: Date?

    private init() {}

    public func configure(with repository: SessionRepository) {
        self.repository = repository
        registerObservers()
        checkInitialState()
    }

    private func registerObservers() {
        cancellables.removeAll()

        // 1. Device locked (Protected data becomes unavailable)
        NotificationCenter.default.publisher(for: UIApplication.protectedDataWillBecomeUnavailableNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handleDeviceLocked()
                }
            }
            .store(in: &cancellables)

        // 2. Device unlocked (Protected data becomes available)
        NotificationCenter.default.publisher(for: UIApplication.protectedDataDidBecomeAvailableNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handleDeviceUnlocked()
                }
            }
            .store(in: &cancellables)

        // 3. App enters background while device is being locked
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.repository?.syncWithWidget()
                }
            }
            .store(in: &cancellables)

        // 4. App will enter foreground (user returned to app)
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.checkInitialState()
                }
            }
            .store(in: &cancellables)
    }

    private func checkInitialState() {
        guard let repository = repository else { return }
        if let active = repository.getActiveSession() {
            self.isTracking = true
            self.activeSessionStartTime = active.startTime
        } else {
            self.isTracking = false
            self.activeSessionStartTime = nil
        }
    }

    private func handleDeviceLocked() {
        guard let repository = repository else { return }
        repository.startSession(at: Date())
        self.isTracking = true
        self.activeSessionStartTime = Date()
    }

    private func handleDeviceUnlocked() {
        guard let repository = repository else { return }
        repository.endSession(at: Date())
        self.isTracking = false
        self.activeSessionStartTime = nil

        // Trigger local notification summary if enabled
        let todayTotal = repository.getTodayTotalMillis()
        NotificationService.shared.sendSessionSummaryNotification(totalMillis: todayTotal)
    }
}
