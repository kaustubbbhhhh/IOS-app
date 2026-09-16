import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

public struct AppColors {
    // Base Palette
    public static let green10 = Color(hex: 0x0D3B0D)
    public static let green20 = Color(hex: 0x1B5E20)
    public static let green30 = Color(hex: 0x2E7D32)
    public static let green40 = Color(hex: 0x388E3C)
    public static let green80 = Color(hex: 0xA5D6A7)
    public static let green90 = Color(hex: 0xC8E6C9)
    public static let green95 = Color(hex: 0xE8F5E9)

    public static let blue40 = Color(hex: 0x1565C0)
    public static let blue80 = Color(hex: 0x90CAF9)

    public static let amber40 = Color(hex: 0xFFA000)
    public static let amber80 = Color(hex: 0xFFE082)
    public static let amber90 = Color(hex: 0xFFFFF8E1)

    public static let surfaceLight = Color(hex: 0xF8FBF8)
    public static let surfaceDark = Color(hex: 0x0F1A0F)
    public static let onSurfaceDark = Color(hex: 0xDDE5DD)
    
    // Dynamic Semantic Colors
    public static func primary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? green80 : green40
    }
    
    public static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? surfaceDark : surfaceLight
    }
    
    public static func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: 0x1E2E1E).opacity(0.85) : green95.opacity(0.9)
    }
    
    public static func textPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? onSurfaceDark : green10
    }
    
    public static func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? green80.opacity(0.8) : green30.opacity(0.9)
    }
    
    public static func tertiary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? amber80 : amber40
    }
    
    public static let flameColor = Color(hex: 0xFF6D00)
}
