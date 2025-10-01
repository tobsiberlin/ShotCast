// EN: ThumbnailGenerator creates async thumbnails for clipboard items
// DE: ThumbnailGenerator erstellt asynchrone Vorschaubilder für Zwischenablage-Elemente

import Foundation
import AppKit
import QuickLook
import QuickLookThumbnailing
import PDFKit
import AVFoundation

actor ThumbnailGenerator {
    
    // EN: Maximum thumbnail dimensions
    // DE: Maximale Vorschaubild-Abmessungen
    private let maxThumbnailSize = CGSize(width: 400, height: 300)
    
    // EN: JPEG compression quality (0.0 to 1.0)
    // DE: JPEG-Komprimierungsqualität (0.0 bis 1.0)
    private let compressionQuality: CGFloat = 0.8
    
    // EN: Generate thumbnail for clipboard item asynchronously
    // DE: Generiere Vorschaubild für Zwischenablage-Element asynchron
    func generateThumbnail(for item: ClipboardItem) async -> Data? {
        print("🖼️ Generating thumbnail for: \(item.title)")
        
        switch item.itemType {
        case .image:
            if let content = item.content {
                return await generateImageThumbnail(from: content)
            }
            return nil
            
        case .pdf:
            if let content = item.content {
                return await generatePDFThumbnail(from: content)
            }
            return nil
            
        case .video:
            if let fileURL = item.fileURL {
                return await generateVideoThumbnail(from: fileURL)
            }
            return nil
            
        case .design:
            if let fileURL = item.fileURL {
                return await generateQuickLookThumbnail(from: fileURL)
            }
            return nil
            
        default:
            // EN: No thumbnail for other types
            // DE: Kein Vorschaubild für andere Typen
            return nil
        }
    }
    
    // EN: Generate thumbnail from image data
    // DE: Generiere Vorschaubild aus Bilddaten
    private func generateImageThumbnail(from data: Data) async -> Data? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let image = NSImage(data: data) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let thumbnailImage = self.resizeImage(image, to: self.maxThumbnailSize)
                let thumbnailData = self.compressImage(thumbnailImage)
                
                continuation.resume(returning: thumbnailData)
            }
        }
    }
    
    // EN: Generate thumbnail from PDF data
    // DE: Generiere Vorschaubild aus PDF-Daten
    private func generatePDFThumbnail(from data: Data) async -> Data? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let pdfDocument = PDFDocument(data: data),
                      let firstPage = pdfDocument.page(at: 0) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // EN: Get page bounds
                // DE: Hole Seitengrenzen
                let pageRect = firstPage.bounds(for: .mediaBox)
                
                // EN: Calculate scale to fit thumbnail size
                // DE: Berechne Skalierung für Vorschaubildgröße
                let scale = min(
                    self.maxThumbnailSize.width / pageRect.width,
                    self.maxThumbnailSize.height / pageRect.height
                )
                
                let scaledSize = CGSize(
                    width: pageRect.width * scale,
                    height: pageRect.height * scale
                )
                
                // EN: Create thumbnail image
                // DE: Erstelle Vorschaubild
                let image = NSImage(size: scaledSize)
                image.lockFocus()
                
                let context = NSGraphicsContext.current?.cgContext
                context?.scaleBy(x: scale, y: scale)
                firstPage.draw(with: .mediaBox, to: context!)
                
                image.unlockFocus()
                
                let thumbnailData = self.compressImage(image)
                continuation.resume(returning: thumbnailData)
            }
        }
    }
    
    // EN: Generate thumbnail from video file
    // DE: Generiere Vorschaubild aus Videodatei
    private func generateVideoThumbnail(from fileURL: URL) async -> Data? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                // EN: Use AVFoundation for video thumbnails
                // DE: Verwende AVFoundation für Video-Vorschaubilder
                
                let asset = AVAsset(url: fileURL)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = self.maxThumbnailSize
                
                do {
                    let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
                    let image = NSImage(cgImage: cgImage, size: self.maxThumbnailSize)
                    let thumbnailData = self.compressImage(image)
                    
                    continuation.resume(returning: thumbnailData)
                } catch {
                    print("⚠️ Error generating video thumbnail: \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // EN: Generate thumbnail using QuickLook for various file types
    // DE: Generiere Vorschaubild mit QuickLook für verschiedene Dateitypen
    private func generateQuickLookThumbnail(from fileURL: URL) async -> Data? {
        return await withCheckedContinuation { continuation in
            let request = QLThumbnailGenerator.Request(
                fileAt: fileURL,
                size: maxThumbnailSize,
                scale: NSScreen.main?.backingScaleFactor ?? 1.0,
                representationTypes: .thumbnail
            )
            
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
                if let error = error {
                    print("⚠️ QuickLook thumbnail error: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let thumbnail = thumbnail else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let image = thumbnail.nsImage
                let thumbnailData = self.compressImage(image)
                continuation.resume(returning: thumbnailData)
            }
        }
    }
    
    // EN: Resize image to fit within maximum dimensions while maintaining aspect ratio
    // DE: Skaliere Bild auf maximale Abmessungen unter Beibehaltung des Seitenverhältnisses
    private func resizeImage(_ image: NSImage, to maxSize: CGSize) -> NSImage {
        let imageSize = image.size
        
        // EN: Calculate scale to fit within bounds
        // DE: Berechne Skalierung für Anpassung in Grenzen
        let scale = min(
            maxSize.width / imageSize.width,
            maxSize.height / imageSize.height
        )
        
        // EN: Don't scale up, only down
        // DE: Nicht vergrößern, nur verkleinern
        let finalScale = min(scale, 1.0)
        
        let newSize = CGSize(
            width: imageSize.width * finalScale,
            height: imageSize.height * finalScale
        )
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        
        image.draw(
            in: NSRect(origin: .zero, size: newSize),
            from: NSRect(origin: .zero, size: imageSize),
            operation: .sourceOver,
            fraction: 1.0
        )
        
        resizedImage.unlockFocus()
        return resizedImage
    }
    
    // EN: Compress image to JPEG data with specified quality
    // DE: Komprimiere Bild zu JPEG-Daten mit angegebener Qualität
    private func compressImage(_ image: NSImage) -> Data? {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        return bitmap.representation(
            using: .jpeg,
            properties: [.compressionFactor: compressionQuality]
        )
    }
    
    // EN: Generate text preview for code and text files
    // DE: Generiere Textvorschau für Code- und Textdateien
    func generateTextPreview(for item: ClipboardItem) async -> NSImage? {
        guard item.itemType == .text || item.itemType == .code,
              let content = item.content,
              let text = String(data: content, encoding: .utf8) else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let preview = self.createTextPreviewImage(from: text, isCode: item.itemType == .code)
                continuation.resume(returning: preview)
            }
        }
    }
    
    // EN: Create preview image from text content
    // DE: Erstelle Vorschaubild aus Textinhalt
    private func createTextPreviewImage(from text: String, isCode: Bool) -> NSImage {
        let maxPreviewLength = 500
        let previewText = String(text.prefix(maxPreviewLength))
        
        // EN: Configure text attributes
        // DE: Konfiguriere Textattribute
        let font = isCode ? 
            NSFont.monospacedSystemFont(ofSize: 12, weight: .regular) :
            NSFont.systemFont(ofSize: 14)
        
        let textColor = NSColor.labelColor
        let backgroundColor = isCode ? 
            NSColor.controlBackgroundColor :
            NSColor.textBackgroundColor
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        let attributedString = NSAttributedString(string: previewText, attributes: attributes)
        
        // EN: Calculate text size
        // DE: Berechne Textgröße
        let textSize = attributedString.size()
        let imageSize = CGSize(
            width: min(textSize.width + 20, maxThumbnailSize.width),
            height: min(textSize.height + 20, maxThumbnailSize.height)
        )
        
        // EN: Create image
        // DE: Erstelle Bild
        let image = NSImage(size: imageSize)
        image.lockFocus()
        
        // EN: Fill background
        // DE: Fülle Hintergrund
        backgroundColor.setFill()
        NSRect(origin: .zero, size: imageSize).fill()
        
        // EN: Draw text
        // DE: Zeichne Text
        let textRect = NSRect(
            x: 10,
            y: 10,
            width: imageSize.width - 20,
            height: imageSize.height - 20
        )
        
        attributedString.draw(in: textRect)
        
        image.unlockFocus()
        return image
    }
}