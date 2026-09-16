# OffScreen iOS App 📱

Native iOS port of the **OffScreen** screen-time reduction tracker, built with **SwiftUI**, **SwiftData**, and **WidgetKit** for iOS 17+.

---

## 🌟 Key Features & Parity with Android

| Feature | Android App | iOS App Equivalent |
|---|---|---|
| **Screen tracking** | Foreground Service (`ACTION_SCREEN_OFF`/`ON`) | `NotificationCenter` observing `protectedDataWillBecomeUnavailable` / `protectedDataDidBecomeAvailable` |
| **Persistence** | Room (SQLite) + SharedPreferences | **SwiftData** (`@Model` / SQLite) + `@AppStorage` / `UserDefaults` (AppGroup) |
| **Today Dashboard** | Timer card + Progress card + Session list | Collapsing Large Title `NavigationStack`, Frosted Glass materials, Donut ring, Inset grouped sessions |
| **History** | 5-week pager + 7-bar graph + Detail cards | Swipeable `TabView` pages, 7-bar graph with spring animation & selection, Inset cards |
| **Streak System** | Streak calculator + 30-day achievement log | Direct Swift port with identical consecutive streak logic + 30-day history |
| **Goal Management** | Bottom sheet with preset chips + ±30m stepper | Native `.sheet` with `.presentationDetents([.medium, .large])`, haptic feedback |
| **Home Screen Widget** | Android AppWidgetProvider with donut ring | **WidgetKit** circular donut progress ring with status badge and AppGroup sync |
| **Onboarding** | 4-step animated flow | 4-step swipeable `TabView` with SF Symbols, haptic feedback, and notifications request |
| **Design Language** | Material 3 Green Theme | **Apple HIG**: Translucent materials, continuous corner curvature (squircles), SF Pro typography, SF Symbols, and Haptics |

---

## 📁 Project Structure

```
IOS app/
├── OffScreen.xcodeproj/         # Xcode Project File
│   └── project.pbxproj
├── Package.swift                # Swift Package Manager config & tests
├── ExportOptions.plist          # IPA compilation export settings
├── scripts/
│   ├── build_ipa.sh             # Full automated build & IPA exporter
│   └── rename_ipa.sh            # Versioned renaming script
├── OffScreen/
│   ├── OffScreenApp.swift       # @main App entry point & SwiftData container
│   ├── Info.plist               # App metadata, bundle ID, background modes
│   ├── Theme/
│   │   ├── AppColors.swift      # Green-primary palette with dynamic light/dark mode
│   │   ├── AppTypography.swift  # SF Pro typography scale
│   │   └── AppStyle.swift       # Squircle continuous curvature & glassmorphic modifiers
│   ├── Models/
│   │   ├── OffScreenSession.swift # SwiftData @Model schema
│   │   ├── GoalPreferences.swift  # Goal repository with AppGroup UserDefaults
│   │   ├── StreakModels.swift     # DayAchievement & StreakInfo
│   │   └── HistoryModels.swift    # DayStat & WeekData
│   ├── Data/
│   │   ├── SessionRepository.swift# SwiftData CRUD & widget synchronization
│   │   └── StreakCalculator.swift # 30-day streak & achievement algorithm
│   ├── Services/
│   │   ├── ScreenTrackingService.swift # Device lock/unlock lifecycle detector
│   │   └── NotificationService.swift   # UNUserNotificationCenter alerts & summaries
│   ├── ViewModels/
│   │   ├── DashboardViewModel.swift   # Today tab reactive state
│   │   └── HistoryViewModel.swift     # 5-week history & averages
│   ├── Views/
│   │   ├── Main/MainTabView.swift     # Root frosted glass TabView
│   │   ├── Dashboard/DashboardView.swift # Collapsing title Dashboard
│   │   ├── History/HistoryView.swift  # 5-week swipeable history
│   │   ├── Onboarding/OnboardingView.swift # 4-step onboarding flow
│   │   └── Components/
│   │       ├── StreakBadge.swift       # 🔥 Badge with spring scale
│   │       ├── OffScreenTimerCard.swift# Pulsing timer card
│   │       ├── DailyProgressRing.swift # Donut circular progress ring
│   │       ├── SessionHistoryList.swift# Inset grouped sessions list
│   │       ├── WeeklyBarGraph.swift    # Interactive 7-bar chart
│   │       ├── DateDetailCard.swift    # Day statistics detail view
│   │       ├── WeeklyAverageCard.swift # Summary average card
│   │       └── GoalStreakSheet.swift   # Bottom sheet goal editor
│   └── Utilities/
│       ├── DurationFormatter.swift    # Time formatting ("3h 36m", "0h 00m")
│       ├── HapticManager.swift        # UIImpact & UINotification feedback
│       └── DateExtensions.swift       # Calendar & Monday-week math
├── OffScreenWidget/
│   ├── OffScreenWidget.swift          # WidgetKit donut ring widget
│   ├── OffScreenWidgetBundle.swift    # Widget bundle
│   └── Info.plist
└── Tests/
    ├── DurationFormatterTests.swift   # Unit tests for time formatting
    └── StreakCalculatorTests.swift    # Unit tests for streak calculations
```

---

## 🛠️ How to Build & Run

### 1. Opening in Xcode (macOS)
Double-click `OffScreen.xcodeproj` or run:
```bash
open OffScreen.xcodeproj
```
Select an iPhone Simulator (e.g., **iPhone 16 Pro**) and press **Cmd + R** to run.

### 2. Compiling and Exporting `.ipa` (Installer)

Run the automated build script:
```bash
chmod +x ./scripts/build_ipa.sh ./scripts/rename_ipa.sh
./scripts/build_ipa.sh 1.0.0 Release
```
This performs:
1. `xcodebuild archive` to build device binary into `build/OffScreen.xcarchive`
2. `xcodebuild -exportArchive` using `ExportOptions.plist` to produce `.ipa`
3. Automatically names the output following the Android APK pattern:
   **`OffScreen-v1.0.0-ios17-release.ipa`**

### 3. Debug Simulator Build (Command Line)
```bash
xcodebuild \
  -project OffScreen.xcodeproj \
  -scheme OffScreen \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  clean build
```

---

## 🧪 Running Tests
```bash
swift test
```
Or press **Cmd + U** in Xcode.
