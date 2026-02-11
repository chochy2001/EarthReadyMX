import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * shakesPerUnit),
                y: amount * 0.3 * cos(animatableData * .pi * shakesPerUnit * 0.7)
            )
        )
    }
}

struct PulseEffect: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (isPulsing ? 1.05 : 1.0))
            .opacity(reduceMotion ? (isPulsing ? 1.0 : 0.85) : 1.0)
            .animation(
                reduceMotion
                    ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                    : .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

struct GlowEffect: ViewModifier {
    let color: Color
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(
                    reduceMotion ? 0.4 : (isGlowing ? 0.6 : 0.2)
                ),
                radius: reduceMotion ? 10 : (isGlowing ? 15 : 5)
            )
            .animation(
                reduceMotion
                    ? nil
                    : .easeInOut(duration: 2).repeatForever(autoreverses: true),
                value: isGlowing
            )
            .onAppear {
                if !reduceMotion {
                    isGlowing = true
                }
            }
    }
}

extension View {
    func pulseEffect() -> some View {
        modifier(PulseEffect())
    }

    func glowEffect(color: Color = .orange) -> some View {
        modifier(GlowEffect(color: color))
    }
}
