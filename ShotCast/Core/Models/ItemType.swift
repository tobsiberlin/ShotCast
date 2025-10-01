// EN: Enum defining types of clipboard content with comprehensive file type support
// DE: Enum zur Definition von Zwischenablage-Inhaltstypen mit umfassender Dateityp-Unterstützung

import SwiftUI

enum ItemType: String, Codable, CaseIterable, Identifiable {
    // EN: Images
    // DE: Bilder
    case screenshot = "screenshot"
    case image = "image"           // jpg, jpeg, png, heic, gif, bmp, tiff, webp
    
    // EN: Documents
    // DE: Dokumente
    case text = "text"              // txt, rtf
    case pdf = "pdf"
    case word = "word"              // doc, docx
    case excel = "excel"            // xls, xlsx, csv
    case powerpoint = "powerpoint"  // ppt, pptx
    case pages = "pages"            // pages
    case numbers = "numbers"        // numbers
    case keynote = "keynote"        // key
    
    // EN: Code & Development (30+ languages)
    // DE: Code & Entwicklung (30+ Sprachen)
    case code = "code"              // swift, py, js, html, css, json, xml, etc.
    
    // EN: Media
    // DE: Medien
    case audio = "audio"            // mp3, wav, aac, flac, m4a, ogg
    case video = "video"            // mp4, mov, avi, mkv, webm
    
    // EN: Archives
    // DE: Archive
    case archive = "archive"        // zip, rar, 7z, tar, gz
    
    // EN: Other
    // DE: Andere
    case link = "link"              // URLs
    case file = "file"              // generic file fallback
    
    var id: String { self.rawValue }
    
    // EN: Returns appropriate SF Symbol for each type
    // DE: Gibt passendes SF Symbol für jeden Typ zurück
    var icon: String {
        switch self {
        case .screenshot: return "camera.viewfinder"
        case .image: return "photo"
        case .text: return "doc.text"
        case .pdf: return "doc.fill"
        case .word: return "doc.richtext"
        case .excel: return "tablecells"
        case .powerpoint: return "doc.text.image"
        case .pages: return "doc.richtext.fill"
        case .numbers: return "tablecells.fill"
        case .keynote: return "play.rectangle"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .audio: return "waveform"
        case .video: return "play.rectangle.fill"
        case .archive: return "doc.zipper"
        case .link: return "link"
        case .file: return "doc"
        }
    }
    
    // EN: Returns color for each type
    // DE: Gibt Farbe für jeden Typ zurück
    var color: Color {
        switch self {
        case .screenshot, .image: return .blue
        case .text, .word, .pages: return .purple
        case .pdf: return .red
        case .excel, .numbers: return .green
        case .powerpoint, .keynote: return .orange
        case .code: return .indigo
        case .audio: return .pink
        case .video: return .cyan
        case .archive: return .brown
        case .link: return .teal
        case .file: return .gray
        }
    }
    
    // EN: Localized display name
    // DE: Lokalisierter Anzeigename
    var displayName: LocalizedStringKey {
        switch self {
        case .screenshot: return "Screenshot"
        case .image: return "Image"
        case .text: return "Text"
        case .pdf: return "PDF"
        case .word: return "Word"
        case .excel: return "Excel"
        case .powerpoint: return "PowerPoint"
        case .pages: return "Pages"
        case .numbers: return "Numbers"
        case .keynote: return "Keynote"
        case .code: return "Code"
        case .audio: return "Audio"
        case .video: return "Video"
        case .archive: return "Archive"
        case .link: return "Link"
        case .file: return "File"
        }
    }
    
    // EN: Get ItemType from file extension
    // DE: ItemType aus Dateierweiterung ermitteln
    static func from(fileExtension ext: String) -> ItemType {
        switch ext.lowercased() {
        // Images
        case "jpg", "jpeg", "png", "heic", "gif", "bmp", "tiff", "webp":
            return .image
            
        // Documents
        case "txt", "rtf", "md":
            return .text
        case "pdf":
            return .pdf
        case "doc", "docx":
            return .word
        case "xls", "xlsx", "csv":
            return .excel
        case "ppt", "pptx":
            return .powerpoint
        case "pages":
            return .pages
        case "numbers":
            return .numbers
        case "key", "keynote":
            return .keynote
            
        // Code (30+ languages)
        case "swift", "py", "python", "js", "javascript", "ts", "typescript",
             "html", "htm", "css", "scss", "sass", "json", "xml", "yaml", "yml",
             "c", "cpp", "cc", "h", "hpp", "m", "mm", "java", "kt", "kotlin",
             "rs", "rust", "go", "rb", "ruby", "php", "sh", "bash", "zsh",
             "sql", "r", "dart", "vue", "jsx", "tsx":
            return .code
            
        // Media
        case "mp3", "wav", "aac", "flac", "m4a", "ogg", "wma", "aiff":
            return .audio
        case "mp4", "mov", "avi", "mkv", "webm", "flv", "wmv", "m4v":
            return .video
            
        // Archives
        case "zip", "rar", "7z", "tar", "gz", "bz2", "xz":
            return .archive
            
        default:
            return .file
        }
    }
}