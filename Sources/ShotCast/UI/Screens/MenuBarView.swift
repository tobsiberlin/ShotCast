// EN: Menu bar view for quick access
// DE: Menüleisten-Ansicht für schnellen Zugriff

import SwiftUI
import SwiftData

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClipboardItem.timestamp, order: .reverse) private var recentItems: [ClipboardItem]
    
    // EN: Limit recent items display
    // DE: Anzahl der anzuzeigenden kürzlichen Elemente begrenzen
    private var displayItems: [ClipboardItem] {
        Array(recentItems.prefix(10))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // EN: Header
            // DE: Kopfzeile
            HStack {
                Label("ShotCast", systemImage: "square.on.square")
                    .font(.headline)
                Spacer()
                Button(action: { NSApp.activate(ignoringOtherApps: true) }) {
                    Image(systemName: "arrow.up.forward.app")
                        .help("Open ShotCast")
                }
                .buttonStyle(.plain)
            }
            .padding(GlassTheme.smallSpacing)
            .background(GlassTheme.glassBackground)
            
            Divider()
            
            // EN: Recent items list
            // DE: Liste der kürzlichen Elemente
            ScrollView {
                VStack(spacing: 2) {
                    if displayItems.isEmpty {
                        Text("No items yet")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(displayItems) { item in
                            MenuItemRow(item: item)
                        }
                    }
                }
                .padding(.vertical, GlassTheme.tinySpacing)
            }
            .frame(maxHeight: 400)
            
            Divider()
            
            // EN: Footer actions
            // DE: Fußzeilen-Aktionen
            HStack {
                Button(action: quitApp) {
                    Label("Quit", systemImage: "power")
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: openSettings) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
            }
            .padding(GlassTheme.smallSpacing)
            .background(GlassTheme.glassBackground)
        }
        .frame(width: 320)
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    private func openSettings() {
        // EN: TODO: Implement settings
        // DE: TODO: Einstellungen implementieren
        NSApp.activate(ignoringOtherApps: true)
    }
}

// EN: Menu item row component
// DE: Menüelement-Zeilen-Komponente
struct MenuItemRow: View {
    let item: ClipboardItem
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: GlassTheme.smallSpacing) {
            // EN: Item type icon
            // DE: Elementtyp-Symbol
            Image(systemName: item.itemType.icon)
                .font(.system(size: 16))
                .foregroundColor(item.itemType.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 13))
                    .lineLimit(1)
                
                Text(item.displayDate)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if item.isFavorite {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, GlassTheme.smallSpacing)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: GlassTheme.smallRadius)
                .fill(isHovered ? GlassTheme.accentBlue.opacity(0.1) : Color.clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            // EN: TODO: Copy to clipboard
            // DE: TODO: In Zwischenablage kopieren
        }
    }
}