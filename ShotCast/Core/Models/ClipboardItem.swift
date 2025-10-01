// EN: ClipboardItem model represents a single clipboard entry
// DE: ClipboardItem-Modell repräsentiert einen einzelnen Zwischenablage-Eintrag

import Foundation
import SwiftData
import SwiftUI
import CryptoKit

@Model
final class ClipboardItem {
    // EN: Unique identifier for the item
    // DE: Eindeutige Kennung für das Element
    var id: UUID = UUID()
    
    // EN: User-editable title or auto-generated name
    // DE: Vom Benutzer bearbeitbarer Titel oder automatisch generierter Name
    var title: String = ""
    
    // EN: Timestamp when item was captured
    // DE: Zeitstempel wann das Element erfasst wurde
    var timestamp: Date = Date()
    
    // EN: Type of clipboard content
    // DE: Art des Zwischenablage-Inhalts
    var itemTypeRaw: String = ItemType.text.rawValue
    
    // EN: Source application bundle identifier
    // DE: Quellanwendungs-Bundle-Identifier
    var sourceApp: String = ""
    
    // EN: Whether item is marked as favorite
    // DE: Ob Element als Favorit markiert ist
    var isFavorite: Bool = false
    
    // EN: OCR extracted text from images
    // DE: OCR extrahierter Text aus Bildern
    var ocrText: String?
    
    // EN: Thumbnail data for preview
    // DE: Vorschaubilddaten für Preview
    @Attribute(.externalStorage)
    var thumbnailData: Data?
    
    // EN: Original clipboard data
    // DE: Original-Zwischenabagedaten
    @Attribute(.externalStorage)
    var originalData: Data?
    
    // EN: Current working data (for processing)
    // DE: Aktuelle Arbeitsdaten (für Verarbeitung)
    @Attribute(.externalStorage)
    var content: Data?
    
    // EN: File URL if applicable
    // DE: Datei-URL falls zutreffend
    var fileURL: URL?
    
    // EN: Creation timestamp
    // DE: Erstellungszeitstempel
    var createdAt: Date = Date()
    
    // EN: File size in bytes
    // DE: Dateigröße in Bytes
    var fileSize: Int64 = 0
    
    // EN: Content hash for duplicate detection
    // DE: Content-Hash für Duplikatserkennung
    var contentHash: String {
        guard let data = content ?? originalData else { return "" }
        return data.sha256
    }
    
    // EN: Relationships to tags
    // DE: Beziehungen zu Tags
    @Relationship(inverse: \Tag.items)
    var tags: [Tag]? = []
    
    // EN: Computed property for ItemType enum
    // DE: Berechnete Eigenschaft für ItemType Enum
    var itemType: ItemType {
        get { ItemType(rawValue: itemTypeRaw) ?? .file }
        set { itemTypeRaw = newValue.rawValue }
    }
    
    // EN: Formatted date display
    // DE: Formatierte Datumsanzeige
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: timestamp)
    }
    
    // EN: Human-readable file size
    // DE: Menschenlesbare Dateigröße
    var displayFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    // EN: Initialize a new clipboard item with all required properties
    // DE: Initialisiert ein neues Zwischenablage-Element mit allen erforderlichen Eigenschaften
    init(
        title: String,
        content: Data,
        itemType: ItemType,
        sourceApp: String = "",
        fileURL: URL? = nil,
        ocrText: String? = nil,
        fileSize: Int64 = 0
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.itemTypeRaw = itemType.rawValue
        self.sourceApp = sourceApp
        self.fileURL = fileURL
        self.timestamp = Date()
        self.createdAt = Date()
        self.originalData = content
        self.ocrText = ocrText
        self.fileSize = fileSize > 0 ? fileSize : Int64(content.count)
        self.isFavorite = false
        self.tags = []
    }
}

// EN: Extension for Data to compute SHA256 hash
// DE: Erweiterung für Data um SHA256-Hash zu berechnen
extension Data {
    var sha256: String {
        let digest = SHA256.hash(data: self)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}