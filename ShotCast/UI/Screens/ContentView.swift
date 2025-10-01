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
    
    // EN: Clipboard monitor for live tracking
    // DE: Zwischenablage-Monitor für Live-Verfolgung
    @State private var clipboardMonitor = ClipboardMonitor()
    
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
            // EN: Transparent glassmorphism background
            // DE: Transparenter Glassmorphismus-Hintergrund
            TransparentBackground()
                .ignoresSafeArea()
        )
        .onAppear {
            // EN: Start clipboard monitoring and setup auto-save
            // DE: Starte Zwischenablage-Überwachung und Setup Auto-Save
            setupClipboardMonitoring()
        }
        .onDisappear {
            // EN: Stop monitoring when view disappears
            // DE: Stoppe Überwachung wenn View verschwindet
            clipboardMonitor.stopMonitoring()
        }
    }
    
    // EN: Setup clipboard monitoring with auto-save to SwiftData
    // DE: Setup Zwischenablage-Überwachung mit Auto-Save zu SwiftData
    private func setupClipboardMonitoring() {
        // EN: Configure callback for new clipboard items
        // DE: Konfiguriere Callback für neue Zwischenablage-Elemente
        clipboardMonitor.onNewItem = { [modelContext] newItem in
            Task { @MainActor in
                // EN: Check for duplicates based on content hash
                // DE: Prüfe auf Duplikate basierend auf Content-Hash
                let existingItems = items.filter { 
                    $0.contentHash == newItem.contentHash 
                }
                
                if let existingItem = existingItems.first {
                    // EN: Update existing item timestamp
                    // DE: Aktualisiere Zeitstempel des vorhandenen Elements
                    existingItem.timestamp = Date()
                    print("📋 Updated existing item: \(existingItem.title)")
                } else {
                    // EN: Insert new item
                    // DE: Füge neues Element hinzu
                    modelContext.insert(newItem)
                    print("📋 Saved new clipboard item: \(newItem.title)")
                }
                
                // EN: Save context
                // DE: Speichere Kontext
                do {
                    try modelContext.save()
                } catch {
                    print("⚠️ Error saving clipboard item: \(error)")
                }
            }
        }
        
        // EN: Start monitoring
        // DE: Starte Überwachung
        clipboardMonitor.startMonitoring()
    }
}

// EN: Transparent background with glassmorphism
// DE: Transparenter Hintergrund mit Glassmorphismus
struct TransparentBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow
        view.isEmphasized = false
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// EN: Legacy visual effect view
// DE: Legacy visueller Effekt View
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
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}