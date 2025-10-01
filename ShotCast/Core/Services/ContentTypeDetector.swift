// EN: ContentTypeDetector identifies clipboard content type with comprehensive format support
// DE: ContentTypeDetector identifiziert Zwischenablage-Inhaltstyp mit umfassender Format-Unterstützung

import Foundation
import AppKit
import ImageIO
import CoreGraphics

struct ContentTypeDetector {
    
    // EN: Detect item type from pasteboard content
    // DE: Erkenne Element-Typ aus Zwischenablage-Inhalt
    func detectType(from pasteboard: NSPasteboard) -> ItemType {
        // EN: Check for URLs first
        // DE: Prüfe zuerst auf URLs
        if let urlString = pasteboard.string(forType: .URL) {
            if urlString.hasPrefix("http") || urlString.hasPrefix("https") {
                return .link
            }
        }
        
        // EN: Check for file URLs with extensions
        // DE: Prüfe auf Datei-URLs mit Endungen
        if let fileURLString = pasteboard.string(forType: .fileURL),
           let url = URL(string: fileURLString) {
            return detectTypeFromExtension(url.pathExtension)
        }
        
        // EN: Check for images
        // DE: Prüfe auf Bilder
        if pasteboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes) {
            return .image
        }
        
        // EN: Check for plain text
        // DE: Prüfe auf einfachen Text
        if let textContent = pasteboard.string(forType: .string) {
            // EN: Check if text looks like code
            // DE: Prüfe ob Text wie Code aussieht
            if looksLikeCode(textContent) {
                return .code
            }
            return .text
        }
        
        // EN: Fallback
        // DE: Fallback
        return .file
    }
    
    // EN: Detect type from file extension with comprehensive support for 50+ formats
    // DE: Erkenne Typ aus Dateiendung mit umfassender Unterstützung für 50+ Formate
    private func detectTypeFromExtension(_ ext: String) -> ItemType {
        let lowercased = ext.lowercased()
        
        // EN: Images (12 formats)
        // DE: Bilder (12 Formate)
        let imageExts = ["jpg", "jpeg", "png", "gif", "heic", "heif", "bmp", "tiff", "tif", "webp", "svg", "ico"]
        if imageExts.contains(lowercased) {
            return .image
        }
        
        // EN: Documents (PDF)
        // DE: Dokumente (PDF)
        if lowercased == "pdf" { 
            return .pdf 
        }
        
        // EN: Text files (6 formats)
        // DE: Text-Dateien (6 Formate)
        let textExts = ["txt", "rtf", "log", "readme", "md", "markdown"]
        if textExts.contains(lowercased) {
            return .text
        }
        
        // EN: Code files (35+ formats)
        // DE: Code-Dateien (35+ Formate)
        let codeExts = [
            // Web
            "html", "htm", "css", "scss", "sass", "less", "js", "jsx", "ts", "tsx", "vue", "svelte",
            // Mobile
            "swift", "kt", "java", "dart", "flutter",
            // Backend
            "py", "rb", "php", "go", "rs", "cpp", "c", "h", "m", "mm", "cs",
            // Data
            "json", "xml", "yaml", "yml", "toml", "ini", "env",
            // Shell/Scripts
            "sh", "bash", "zsh", "fish", "ps1", "bat", "cmd",
            // Databases
            "sql", "sqlite", "db",
            // Other
            "r", "pl", "scala", "clj", "elm", "haskell", "lua"
        ]
        if codeExts.contains(lowercased) {
            return .code
        }
        
        // EN: Audio files (12 formats)
        // DE: Audio-Dateien (12 Formate)
        let audioExts = ["mp3", "wav", "aac", "flac", "m4a", "ogg", "wma", "aiff", "ape", "opus", "alac", "dsd"]
        if audioExts.contains(lowercased) {
            return .audio
        }
        
        // EN: Video files (15 formats)
        // DE: Video-Dateien (15 Formate)
        let videoExts = ["mp4", "mov", "avi", "mkv", "webm", "flv", "wmv", "m4v", "mpg", "mpeg", "3gp", "ogv", "mxf", "prores", "dnxhd"]
        if videoExts.contains(lowercased) {
            return .video
        }
        
        // EN: Design files (8 formats)
        // DE: Design-Dateien (8 Formate)
        let designExts = ["psd", "ai", "sketch", "fig", "xd", "indd", "eps", "affinity"]
        if designExts.contains(lowercased) {
            return .design
        }
        
        // EN: Font files (6 formats)
        // DE: Schriftart-Dateien (6 Formate)
        let fontExts = ["ttf", "otf", "woff", "woff2", "eot", "fon"]
        if fontExts.contains(lowercased) {
            return .font
        }
        
        // EN: Archive files (12 formats)
        // DE: Archiv-Dateien (12 Formate)
        let archiveExts = ["zip", "rar", "7z", "tar", "gz", "bz2", "xz", "dmg", "pkg", "deb", "rpm", "cab"]
        if archiveExts.contains(lowercased) {
            return .archive
        }
        
        // EN: Installer files (8 formats)
        // DE: Installer-Dateien (8 Formate)
        let installerExts = ["app", "dmg", "pkg", "msi", "exe", "deb", "rpm", "appx"]
        if installerExts.contains(lowercased) {
            return .installer
        }
        
        // EN: 3D Model files (8 formats)
        // DE: 3D-Modell-Dateien (8 Formate)
        let threeDExts = ["obj", "fbx", "dae", "3ds", "blend", "max", "maya", "c4d"]
        if threeDExts.contains(lowercased) {
            return .threeDModel
        }
        
        // EN: Data files (10 formats)
        // DE: Daten-Dateien (10 Formate)
        let dataExts = ["csv", "tsv", "json", "xml", "xlsx", "xls", "numbers", "db", "sqlite", "plist"]
        if dataExts.contains(lowercased) {
            return .data
        }
        
        // EN: Default fallback
        // DE: Standard-Fallback
        return .file
    }
    
    
    // EN: Check if text content looks like code
    // DE: Prüfe ob Textinhalt wie Code aussieht
    private func looksLikeCode(_ text: String) -> Bool {
        let codeIndicators = [
            "function", "def ", "class ", "import ", "export ",
            "var ", "let ", "const ", "if (", "for (", "while (",
            "{", "}", "[", "]", "//", "/*", "*/", "#include",
            "<?php", "<!DOCTYPE", "<html>", "SELECT ", "FROM ",
            "print(", "console.log", "println!", "fmt.Print"
        ]
        
        let lowercasedText = text.lowercased()
        let codeScore = codeIndicators.reduce(0) { score, indicator in
            score + (lowercasedText.contains(indicator.lowercased()) ? 1 : 0)
        }
        
        // EN: If text contains multiple code indicators, likely code
        // DE: Wenn Text mehrere Code-Indikatoren enthält, wahrscheinlich Code
        return codeScore >= 2 || text.contains("```") // Markdown code blocks
    }
}

// EN: Extension to add more file type detection capabilities
// DE: Erweiterung um weitere Dateityp-Erkennungsfähigkeiten hinzuzufügen
extension ContentTypeDetector {
    
    // EN: Get human-readable description for detected type
    // DE: Hole menschenlesbare Beschreibung für erkannten Typ
    func getTypeDescription(for itemType: ItemType) -> String {
        switch itemType {
        case .image: return "Image"
        case .text: return "Text Document"
        case .pdf: return "PDF Document"
        case .word: return "Word Document"
        case .excel: return "Excel Spreadsheet"
        case .powerpoint: return "PowerPoint Presentation"
        case .pages: return "Pages Document"
        case .numbers: return "Numbers Spreadsheet"
        case .keynote: return "Keynote Presentation"
        case .code: return "Source Code"
        case .audio: return "Audio File"
        case .video: return "Video File"
        case .design: return "Design File"
        case .font: return "Font File"
        case .archive: return "Archive"
        case .installer: return "Installer"
        case .threeDModel: return "3D Model"
        case .data: return "Data File"
        case .link: return "Web Link"
        case .file: return "File"
        }
    }
    
    // EN: Check if file type supports thumbnail generation
    // DE: Prüfe ob Dateityp Vorschaubild-Generierung unterstützt
    func supportsThumbnails(_ itemType: ItemType) -> Bool {
        switch itemType {
        case .image, .pdf, .video, .design:
            return true
        default:
            return false
        }
    }
}