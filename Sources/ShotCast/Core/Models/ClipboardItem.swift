// EN: ClipboardItem model represents a single clipboard entry
// DE: ClipboardItem-Modell repräsentiert einen einzelnen Zwischenablage-Eintrag

import Foundation
import SwiftData
import SwiftUI

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
    
    // EN: File size in bytes
    // DE: Dateigröße in Bytes
    var fileSize: Int64 = 0
    
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
        itemType: ItemType,
        sourceApp: String = "",
        data: Data? = nil,
        thumbnailData: Data? = nil,
        ocrText: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.itemTypeRaw = itemType.rawValue
        self.sourceApp = sourceApp
        self.timestamp = Date()
        self.originalData = data
        self.thumbnailData = thumbnailData
        self.ocrText = ocrText
        self.fileSize = Int64(data?.count ?? 0)
        self.isFavorite = false
        self.tags = []
    }
}