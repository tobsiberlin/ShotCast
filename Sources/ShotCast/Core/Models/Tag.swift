// EN: Tag model for organizing clipboard items
// DE: Tag-Modell zur Organisation von Zwischenablage-Elementen

import Foundation
import SwiftData
import SwiftUI

@Model
final class Tag {
    // EN: Unique identifier
    // DE: Eindeutige Kennung
    var id: UUID = UUID()
    
    // EN: Tag name
    // DE: Tag-Name
    var name: String = ""
    
    // EN: Hex color string for tag
    // DE: Hex-Farbstring für Tag
    var colorHex: String = "#007AFF"
    
    // EN: Creation date
    // DE: Erstellungsdatum
    var createdAt: Date = Date()
    
    // EN: Relationship to clipboard items
    // DE: Beziehung zu Zwischenablage-Elementen
    var items: [ClipboardItem]? = []
    
    // EN: Computed property for SwiftUI Color
    // DE: Berechnete Eigenschaft für SwiftUI Color
    var color: Color {
        Color(hex: colorHex)
    }
    
    // EN: Initialize a new tag
    // DE: Initialisiert einen neuen Tag
    init(name: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
        self.items = []
    }
}

// EN: Extension for hex color support
// DE: Erweiterung für Hex-Farb-Unterstützung
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}