import SwiftUI

public struct CardStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 18

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColors.cardBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(0.04), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.05), radius: 10, x: 0, y: 4)
    }
}

public struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 18

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 5)
    }
}

public struct SpringPressModifier: ViewModifier {
    @State private var isPressed = false

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    public func cardStyle(cornerRadius: CGFloat = 20, padding: CGFloat = 18) -> some View {
        modifier(CardStyleModifier(cornerRadius: cornerRadius, padding: padding))
    }
    
    public func glassCard(cornerRadius: CGFloat = 20, padding: CGFloat = 18) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
    
    public func springPress() -> some View {
        modifier(SpringPressModifier())
    }
}
