// EN: GlassTheme defines the glassmorphism design system
// DE: GlassTheme definiert das Glassmorphismus-Designsystem

import SwiftUI

struct GlassTheme {
    // EN: Colors with transparency for glass effect
    // DE: Farben mit Transparenz für Glaseffekt
    static let glassBackground = Color.white.opacity(0.15)
    static let glassBorder = Color.white.opacity(0.3)
    static let glassBackgroundDark = Color.black.opacity(0.2)
    static let glassBorderDark = Color.white.opacity(0.2)
    
    // EN: Accent colors with glow
    // DE: Akzentfarben mit Leuchten
    static let accentBlue = Color(hex: "#007AFF")
    static let accentPurple = Color(hex: "#AF52DE")
    static let accentGreen = Color(hex: "#34C759")
    static let accentOrange = Color(hex: "#FF9500")
    static let accentRed = Color(hex: "#FF3B30")
    
    // EN: Blur intensity values for different UI elements
    // DE: Unschärfe-Intensitätswerte für verschiedene UI-Elemente
    static let standardBlur: CGFloat = 25
    static let lightBlur: CGFloat = 15
    static let heavyBlur: CGFloat = 35
    static let ultraBlur: CGFloat = 45
    
    // EN: Corner radius values
    // DE: Eckenradius-Werte
    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 10
    static let smallRadius: CGFloat = 6
    
    // EN: Spacing values
    // DE: Abstandswerte
    static let tinySpacing: CGFloat = 4
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    
    // EN: Animation values
    // DE: Animationswerte
    static let standardAnimation = Animation.spring(response: 0.35, dampingFraction: 0.8)
    static let quickAnimation = Animation.spring(response: 0.25, dampingFraction: 0.85)
    static let slowAnimation = Animation.spring(response: 0.5, dampingFraction: 0.75)
}

// EN: Glass effect view modifier
// DE: Glaseffekt-View-Modifier
struct GlassEffect: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var blurRadius: CGFloat = GlassTheme.standardBlur
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(
                colorScheme == .dark ? 
                GlassTheme.glassBackgroundDark : 
                GlassTheme.glassBackground
            )
            .overlay(
                RoundedRectangle(cornerRadius: GlassTheme.cardRadius)
                    .stroke(
                        colorScheme == .dark ?
                        GlassTheme.glassBorderDark :
                        GlassTheme.glassBorder,
                        lineWidth: 0.5
                    )
            )
    }
}

// EN: Multi-layer shadow for glass cards
// DE: Mehrschichtige Schatten für Glaskarten
struct GlassCardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 8)
    }
}

// EN: Reusable glass card component
// DE: Wiederverwendbare Glaskarten-Komponente
struct GlassCard<Content: View>: View {
    let content: () -> Content
    var padding: CGFloat = GlassTheme.mediumSpacing
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .modifier(GlassEffect())
            .cornerRadius(GlassTheme.cardRadius)
            .modifier(GlassCardShadow())
    }
}

// EN: Glass button style
// DE: Glas-Button-Stil
struct GlassButtonStyle: ButtonStyle {
    @State private var isHovered = false
    var color: Color = GlassTheme.accentBlue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, GlassTheme.mediumSpacing)
            .padding(.vertical, GlassTheme.smallSpacing)
            .background(
                RoundedRectangle(cornerRadius: GlassTheme.buttonRadius)
                    .fill(color.opacity(configuration.isPressed ? 0.3 : (isHovered ? 0.2 : 0.1)))
                    .overlay(
                        RoundedRectangle(cornerRadius: GlassTheme.buttonRadius)
                            .stroke(color.opacity(0.3), lineWidth: 0.5)
                    )
            )
            .foregroundColor(color)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(GlassTheme.quickAnimation, value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// EN: Extension for easy view modifier application
// DE: Erweiterung für einfache View-Modifier-Anwendung
extension View {
    func glassEffect(blurRadius: CGFloat = GlassTheme.standardBlur) -> some View {
        modifier(GlassEffect(blurRadius: blurRadius))
    }
    
    func glassCardShadow() -> some View {
        modifier(GlassCardShadow())
    }
}