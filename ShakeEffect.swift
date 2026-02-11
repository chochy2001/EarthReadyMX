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
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

struct GlowEffect: ViewModifier {
    let color: Color
    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(isGlowing ? 0.6 : 0.2), radius: isGlowing ? 15 : 5)
            .animation(
                .easeInOut(duration: 2).repeatForever(autoreverses: true),
                value: isGlowing
            )
            .onAppear { isGlowing = true }
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
