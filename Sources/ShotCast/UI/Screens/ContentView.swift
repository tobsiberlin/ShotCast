// EN: Main content view for the application window
// DE: Hauptinhaltsansicht für das Anwendungsfenster

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ClipboardItem]
    
    // EN: Selected item for detail view
    // DE: Ausgewähltes Element für Detailansicht
    @State private var selectedItem: ClipboardItem?
    
    // EN: View layout
    // DE: Ansichtslayout
    var body: some View {
        NavigationSplitView {
            // EN: Sidebar with item list
            // DE: Seitenleiste mit Elementliste
            LibraryView(selectedItem: $selectedItem)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            // EN: Detail view for selected item
            // DE: Detailansicht für ausgewähltes Element
            if let item = selectedItem {
                DetailView(item: item)
            } else {
                EmptyStateView()
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(
            // EN: Glassmorphism background
            // DE: Glassmorphismus-Hintergrund
            VisualEffectView()
                .ignoresSafeArea()
        )
    }
}

// EN: Visual effect blur background
// DE: Visueller Effekt Unschärfe-Hintergrund
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// EN: Empty state when no item selected
// DE: Leerer Zustand wenn kein Element ausgewählt
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: GlassTheme.mediumSpacing) {
            Image(systemName: "square.on.square")
                .font(.system(size: 60))
                .foregroundColor(GlassTheme.accentBlue.opacity(0.6))
            
            Text("Select an item")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Choose an item from the sidebar to view details")
                .font(.caption)
                .foregroundColor(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}