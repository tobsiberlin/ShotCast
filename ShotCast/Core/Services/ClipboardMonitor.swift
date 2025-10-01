// EN: ClipboardMonitor observes pasteboard changes and processes new content
// DE: ClipboardMonitor überwacht Zwischenablage-Änderungen und verarbeitet neue Inhalte

import Foundation
import SwiftUI
import SwiftData

@Observable
final class ClipboardMonitor {
    private var changeCount: Int = 0
    private var timer: Timer?
    private let pasteboard = NSPasteboard.general
    private let contentDetector = ContentTypeDetector()
    private let thumbnailGenerator = ThumbnailGenerator()
    
    // EN: Callback triggered when new item is detected
    // DE: Callback wird ausgelöst, wenn ein neues Element erkannt wird
    var onNewItem: ((ClipboardItem) -> Void)?
    
    // EN: Start monitoring clipboard changes every 0.5 seconds
    // DE: Starte Überwachung der Zwischenablage alle 0.5 Sekunden
    func startMonitoring() {
        print("📋 Starting clipboard monitoring...")
        changeCount = pasteboard.changeCount
        
        // EN: Poll every 0.5 seconds
        // DE: Prüfe alle 0.5 Sekunden
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }
    
    func stopMonitoring() {
        print("📋 Stopping clipboard monitoring...")
        timer?.invalidate()
        timer = nil
    }
    
    // EN: Check if clipboard content has changed
    // DE: Prüfe ob sich der Zwischenablage-Inhalt geändert hat
    private func checkForChanges() {
        let currentChangeCount = pasteboard.changeCount
        
        // EN: Compare changeCount
        // DE: Vergleiche changeCount
        if currentChangeCount != changeCount {
            changeCount = currentChangeCount
            
            // EN: Detect new content
            // DE: Erkenne neue Inhalte
            if let newItem = processClipboardContent() {
                print("📋 New clipboard item detected: \(newItem.title)")
                
                // EN: Call onNewItem callback
                // DE: Rufe onNewItem-Callback auf
                onNewItem?(newItem)
            }
        }
    }
    
    // EN: Process clipboard content and create ClipboardItem
    // DE: Verarbeite Zwischenablage-Inhalt und erstelle ClipboardItem
    private func processClipboardContent() -> ClipboardItem? {
        // EN: Detect type: image, text, URL, file
        // DE: Erkenne Typ: Bild, Text, URL, Datei
        let itemType = contentDetector.detectType(from: pasteboard)
        
        // EN: Extract content based on type
        // DE: Extrahiere Inhalt basierend auf Typ
        var title = "Untitled"
        var content: Data?
        var fileURL: URL?
        var ocrText: String?
        
        switch itemType {
        case .text:
            if let textContent = pasteboard.string(forType: .string) {
                title = String(textContent.prefix(50))
                content = textContent.data(using: .utf8)
            }
            
        case .image:
            if let image = NSImage(pasteboard: pasteboard) {
                title = "Image - \(Int(image.size.width))x\(Int(image.size.height))"
                content = image.tiffRepresentation
            }
            
        case .link:
            if let urlString = pasteboard.string(forType: .URL) {
                title = urlString
                content = urlString.data(using: .utf8)
            }
            
        default:
            // EN: Handle file URLs
            // DE: Behandle Datei-URLs
            if let fileURLString = pasteboard.string(forType: .fileURL),
               let url = URL(string: fileURLString) {
                fileURL = url
                title = url.lastPathComponent
                
                // EN: Try to read file data
                // DE: Versuche Datei-Daten zu lesen
                do {
                    content = try Data(contentsOf: url)
                } catch {
                    print("⚠️ Could not read file data: \(error)")
                }
            }
        }
        
        guard content != nil else {
            print("⚠️ No valid content found in clipboard")
            return nil
        }
        
        // EN: Extract metadata
        // DE: Extrahiere Metadaten
        let sourceApp = detectSourceApp()
        let fileSize = Int64(content?.count ?? 0)
        
        // EN: Create ClipboardItem
        // DE: Erstelle ClipboardItem
        let item = ClipboardItem(
            title: title,
            content: content!,
            itemType: itemType,
            sourceApp: sourceApp,
            fileURL: fileURL,
            ocrText: ocrText,
            fileSize: fileSize
        )
        
        // EN: Generate thumbnail asynchronously
        // DE: Generiere Vorschaubild asynchron
        Task {
            if let thumbnailData = await thumbnailGenerator.generateThumbnail(for: item) {
                item.thumbnailData = thumbnailData
            }
        }
        
        return item
    }
    
    // EN: Try to detect source application name
    // DE: Versuche Quell-Anwendungsnamen zu erkennen
    private func detectSourceApp() -> String {
        // EN: Try to detect source application
        // DE: Versuche Quell-Anwendung zu erkennen
        if let frontmostApp = NSWorkspace.shared.frontmostApplication {
            return frontmostApp.localizedName ?? "Unknown"
        }
        
        // EN: Fallback to "Unknown"
        // DE: Fallback auf "Unbekannt"
        return "Unknown"
    }
}