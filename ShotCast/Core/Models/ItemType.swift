// EN: Enum defining types of clipboard content with comprehensive file type support
// DE: Enum zur Definition von Zwischenablage-Inhaltstypen mit umfassender Dateityp-Unterstützung

import SwiftUI

enum ItemType: String, Codable, CaseIterable, Identifiable {
    // EN: Images
    // DE: Bilder
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
    
    // EN: Creative & Design
    // DE: Kreativ & Design
    case design = "design"          // psd, ai, sketch, fig, xd
    case font = "font"              // ttf, otf, woff, woff2
    
    // EN: Archives & Installation
    // DE: Archive & Installation
    case archive = "archive"        // zip, rar, 7z, tar, gz
    case installer = "installer"    // dmg, pkg, msi, exe, app
    
    // EN: 3D & Data
    // DE: 3D & Daten
    case threeDModel = "threedmodel" // obj, fbx, blend, dae
    case data = "data"              // csv, json, xml, db
    
    // EN: Other
    // DE: Andere
    case link = "link"              // URLs
    case file = "file"              // generic file fallback
    
    var id: String { self.rawValue }
    
    // EN: Returns brand-appropriate SF Symbol for each type
    // DE: Gibt markenkonformes SF Symbol für jeden Typ zurück
    var icon: String {
        switch self {
        case .image: return "photo.fill"
        case .text: return "doc.plaintext"
        case .pdf: return "doc.richtext.fill"
        case .word: return "w.square.fill"
        case .excel: return "x.square.fill"
        case .powerpoint: return "p.square.fill"
        case .pages: return "doc.richtext"
        case .numbers: return "tablecells.fill"
        case .keynote: return "k.square.fill"
        case .code: return "curlybraces"
        case .audio: return "music.note"
        case .video: return "video.fill"
        case .design: return "paintpalette.fill"
        case .font: return "textformat.abc"
        case .archive: return "archivebox.fill"
        case .installer: return "arrow.down.app.fill"
        case .threeDModel: return "view.3d"
        case .data: return "chart.bar.doc.horizontal.fill"
        case .link: return "link.circle.fill"
        case .file: return "doc.text.fill"
        }
    }
    
    // EN: Returns color for each type
    // DE: Gibt Farbe für jeden Typ zurück
    var color: Color {
        switch self {
        case .image: return .blue
        case .text, .word, .pages: return .purple
        case .pdf: return .red
        case .excel, .numbers: return .green
        case .powerpoint, .keynote: return .orange
        case .code: return .indigo
        case .audio: return .pink
        case .video: return .cyan
        case .design: return .purple
        case .font: return .indigo
        case .archive: return .brown
        case .installer: return .blue
        case .threeDModel: return .orange
        case .data: return .green
        case .link: return .teal
        case .file: return .gray
        }
    }
    
    // EN: Localized display name for SwiftUI
    // DE: Lokalisierter Anzeigename für SwiftUI
    var displayName: LocalizedStringKey {
        switch self {
        case .image: return "Bild"
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
        case .design: return "Design"
        case .font: return "Schrift"
        case .archive: return "Archiv"
        case .installer: return "Installer"
        case .threeDModel: return "3D Modell"
        case .data: return "Daten"
        case .link: return "Link"
        case .file: return "Datei"
        }
    }
    
    // EN: String display name for filter buttons
    // DE: String-Anzeigename für Filter-Buttons
    var displayString: String {
        switch self {
        case .image: return "Bild"
        case .text: return "Text-Snippets"
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
        case .design: return "Design"
        case .font: return "Schrift"
        case .archive: return "Archiv"
        case .installer: return "Installer"
        case .threeDModel: return "3D Modell"
        case .data: return "Daten"
        case .link: return "Link"
        case .file: return "Textdatei"
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
            
        // Design files
        case "psd", "ai", "sketch", "fig", "xd", "indd", "eps", "affinity":
            return .design
            
        // Font files
        case "ttf", "otf", "woff", "woff2", "eot", "fon":
            return .font
            
        // Archives
        case "zip", "rar", "7z", "tar", "gz", "bz2", "xz", "dmg", "pkg":
            return .archive
            
        // Installer files
        case "app", "msi", "exe", "deb", "rpm", "appx":
            return .installer
            
        // 3D Model files
        case "obj", "fbx", "dae", "3ds", "blend", "max", "maya", "c4d":
            return .threeDModel
            
        // Data files  
        case "tsv", "db", "sqlite", "plist":
            return .data
            
        default:
            return .file
        }
    }
}