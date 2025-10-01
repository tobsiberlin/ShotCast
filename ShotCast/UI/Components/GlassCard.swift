// EN: Additional glass components for enhanced UI
// DE: Zusätzliche Glas-Komponenten für erweiterte UI

import SwiftUI

// EN: Enhanced filter chip with glassmorphism
// DE: Erweiterte Filter-Chip mit Glassmorphismus
struct EnhancedFilterChip: View {
    let title: LocalizedStringKey
    var icon: String? = nil
    var color: Color = GlassTheme.accentBlue
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white : color)
                }
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: GlassTheme.buttonRadius)
                    .fill(
                        isSelected ? 
                        color.opacity(0.8) :
                        isHovered ?
                        color.opacity(0.1) :
                        Color.clear
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: GlassTheme.buttonRadius)
                            .stroke(
                                isSelected ? 
                                color.opacity(0.6) :
                                isHovered ?
                                color.opacity(0.3) :
                                Color.secondary.opacity(0.2),
                                lineWidth: isSelected ? 1.0 : 0.5
                            )
                    )
                    .shadow(
                        color: isSelected ? color.opacity(0.3) : Color.clear,
                        radius: isSelected ? 6 : 0,
                        x: 0,
                        y: isSelected ? 2 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(GlassTheme.standardAnimation, value: isSelected)
            .animation(GlassTheme.quickAnimation, value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}