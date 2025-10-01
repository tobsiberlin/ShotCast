// EN: Main app entry point for ShotCast
// DE: Haupt-App-Einstiegspunkt für ShotCast

import SwiftUI
import SwiftData

@main
struct ShotCastApp: App {
    // EN: Shared app state for global access
    // DE: Geteilter App-Zustand für globalen Zugriff
    @StateObject private var appState = AppState()
    
    // EN: Model container for SwiftData persistence
    // DE: Model-Container für SwiftData-Persistenz
    let modelContainer: ModelContainer
    
    init() {
        do {
            // EN: Initialize SwiftData container with our models
            // DE: SwiftData-Container mit unseren Modellen initialisieren
            modelContainer = try ModelContainer(for: 
                ClipboardItem.self,
                Tag.self
            )
        } catch {
            // EN: Fatal error if we can't create the model container
            // DE: Fataler Fehler wenn wir den Model-Container nicht erstellen können
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        // EN: Main window group with glassmorphism styling
        // DE: Hauptfenstergruppe mit Glassmorphismus-Stil
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .modelContainer(modelContainer)
                .preferredColorScheme(.dark) // EN: Better for glass effects / DE: Besser für Glaseffekte
                .onAppear {
                    // EN: Ensure app appears in dock and is visible
                    // DE: Sicherstellen dass App im Dock erscheint und sichtbar ist
                    NSApp.setActivationPolicy(.regular)
                    
                    // EN: Bring app to front when window appears
                    // DE: App in Vordergrund bringen wenn Fenster erscheint
                    NSApp.activate(ignoringOtherApps: true)
                }
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 900, height: 600)
        .defaultPosition(.center)
        
        // EN: Menu bar extra for quick access
        // DE: Menüleisten-Extra für schnellen Zugriff
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
                .modelContainer(modelContainer)
        } label: {
            Image(systemName: "square.on.square")
                .symbolRenderingMode(.hierarchical)
        }
        .menuBarExtraStyle(.window)
    }
}

// EN: Global app state management
// DE: Globale App-Zustandsverwaltung
class AppState: ObservableObject {
    // EN: Track if main window is visible
    // DE: Verfolgt ob Hauptfenster sichtbar ist
    @Published var isMainWindowVisible = false
    
    // EN: Current search query
    // DE: Aktuelle Suchanfrage
    @Published var searchQuery = ""
    
    // EN: Selected filter
    // DE: Ausgewählter Filter
    @Published var selectedFilter: ItemType?
    
    // EN: Is app in trial mode
    // DE: Ist App im Testmodus
    @Published var isTrialMode = true
    
    // EN: Remaining trial days
    // DE: Verbleibende Testtage
    @Published var trialDaysRemaining = 7
}