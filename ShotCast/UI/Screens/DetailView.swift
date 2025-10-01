// EN: Detail view for selected clipboard item
// DE: Detailansicht für ausgewähltes Zwischenablage-Element

import SwiftUI

struct DetailView: View {
    let item: ClipboardItem
    @Environment(\.modelContext) private var modelContext
    @State private var editingTitle = false
    @State private var tempTitle = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GlassTheme.largeSpacing) {
                // EN: Header section
                // DE: Kopfbereich
                DetailHeader(
                    item: item,
                    editingTitle: $editingTitle,
                    tempTitle: $tempTitle
                )
                
                // EN: Content preview
                // DE: Inhaltsvorschau
                ContentPreview(item: item)
                
                // EN: Metadata section
                // DE: Metadaten-Bereich
                MetadataSection(item: item)
                
                // EN: Actions section
                // DE: Aktionen-Bereich
                ActionsSection(item: item)
            }
            .padding(GlassTheme.largeSpacing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

// EN: Detail header with editable title
// DE: Detail-Kopfzeile mit bearbeitbarem Titel
struct DetailHeader: View {
    let item: ClipboardItem
    @Binding var editingTitle: Bool
    @Binding var tempTitle: String
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: GlassTheme.mediumSpacing) {
            HStack {
                Image(systemName: item.itemType.icon)
                    .font(.largeTitle)
                    .foregroundColor(item.itemType.color)
                
                Spacer()
                
                Button(action: toggleFavorite) {
                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                        .foregroundColor(item.isFavorite ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }
            
            // EN: Editable title
            // DE: Bearbeitbarer Titel
            if editingTitle {
                HStack {
                    TextField("Title", text: $tempTitle)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(saveTitle)
                    
                    Button("Save", action: saveTitle)
                        .buttonStyle(GlassButtonStyle())
                    
                    Button("Cancel") {
                        editingTitle = false
                        tempTitle = item.title
                    }
                    .buttonStyle(GlassButtonStyle(color: .secondary))
                }
            } else {
                HStack {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Button(action: { 
                        tempTitle = item.title
                        editingTitle = true 
                    }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack(spacing: GlassTheme.mediumSpacing) {
                Label(item.displayDate, systemImage: "calendar")
                Label(item.displayFileSize, systemImage: "doc")
                if !item.sourceApp.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: getAppIcon(for: item.sourceApp))
                            .font(.caption)
                            .foregroundColor(getAppColor(for: item.sourceApp))
                        Text(item.sourceApp)
                    }
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .glassEffect()
        .cornerRadius(GlassTheme.cardRadius)
    }
    
    private func toggleFavorite() {
        item.isFavorite.toggle()
        try? modelContext.save()
    }
    
    private func saveTitle() {
        item.title = tempTitle
        editingTitle = false
        try? modelContext.save()
    }
    
    // EN: Get app-specific icon for source app
    // DE: App-spezifisches Icon für Quell-App ermitteln
    private func getAppIcon(for appName: String) -> String {
        let lowercased = appName.lowercased()
        switch lowercased {
        // Screenshots
        case "shottr", "screenshot", "bildschirmfoto":
            return "camera.viewfinder"
        
        // Browsers
        case "safari":
            return "safari"
        case "chrome", "google chrome":
            return "globe"
        case "firefox":
            return "flame"
        case "edge", "microsoft edge":
            return "globe.europe.africa"
            
        // Creative Apps
        case "photoshop", "adobe photoshop":
            return "paintbrush.pointed.fill"
        case "illustrator", "adobe illustrator":
            return "pencil.and.outline"
        case "figma":
            return "rectangle.on.rectangle"
        case "sketch":
            return "diamond"
            
        // Office Apps
        case "word", "microsoft word":
            return "w.square.fill"
        case "excel", "microsoft excel":
            return "x.square.fill"
        case "powerpoint", "microsoft powerpoint":
            return "p.square.fill"
        case "pages":
            return "doc.richtext"
        case "numbers":
            return "tablecells.fill"
        case "keynote":
            return "k.square.fill"
            
        // Development
        case "xcode":
            return "hammer.fill"
        case "vs code", "visual studio code", "code":
            return "curlybraces.square"
        case "terminal":
            return "terminal"
        case "git", "github":
            return "arrow.triangle.branch"
            
        // Communication
        case "slack":
            return "message.fill"
        case "teams", "microsoft teams":
            return "person.2.fill"
        case "zoom":
            return "video.fill"
        case "mail", "apple mail":
            return "envelope.fill"
            
        // Media
        case "spotify":
            return "music.note.list"
        case "vlc":
            return "play.circle.fill"
        case "quicktime", "quicktime player":
            return "play.rectangle.fill"
            
        default:
            return "app.fill"
        }
    }
    
    // EN: Get app-specific color for source app
    // DE: App-spezifische Farbe für Quell-App ermitteln
    private func getAppColor(for appName: String) -> Color {
        let lowercased = appName.lowercased()
        switch lowercased {
        // Screenshots
        case "shottr", "screenshot", "bildschirmfoto":
            return .orange
            
        // Browsers
        case "safari":
            return .blue
        case "chrome", "google chrome":
            return .red
        case "firefox":
            return .orange
        case "edge", "microsoft edge":
            return .blue
            
        // Creative Apps
        case "photoshop", "adobe photoshop":
            return .blue
        case "illustrator", "adobe illustrator":
            return .orange
        case "figma":
            return .purple
        case "sketch":
            return .yellow
            
        // Office Apps
        case "word", "microsoft word":
            return .blue
        case "excel", "microsoft excel":
            return .green
        case "powerpoint", "microsoft powerpoint":
            return .red
        case "pages":
            return .orange
        case "numbers":
            return .green
        case "keynote":
            return .blue
            
        // Development
        case "xcode":
            return .blue
        case "vs code", "visual studio code", "code":
            return .blue
        case "terminal":
            return .green
        case "git", "github":
            return .gray
            
        // Communication
        case "slack":
            return .purple
        case "teams", "microsoft teams":
            return .blue
        case "zoom":
            return .blue
        case "mail", "apple mail":
            return .blue
            
        // Media
        case "spotify":
            return .green
        case "vlc":
            return .orange
        case "quicktime", "quicktime player":
            return .gray
            
        default:
            return .secondary
        }
    }
}

// EN: Content preview based on item type
// DE: Inhaltsvorschau basierend auf Elementtyp
struct ContentPreview: View {
    let item: ClipboardItem
    
    var body: some View {
        GlassCard {
            switch item.itemType {
            case .image:
                if let data = item.thumbnailData,
                   let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                }
                
            case .text, .code:
                if let data = item.originalData,
                   let text = String(data: data, encoding: .utf8) {
                    ScrollView {
                        Text(text)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 300)
                }
                
            default:
                VStack(spacing: GlassTheme.mediumSpacing) {
                    Image(systemName: item.itemType.icon)
                        .font(.system(size: 60))
                        .foregroundColor(item.itemType.color.opacity(0.6))
                    
                    Text("Preview not available")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(GlassTheme.largeSpacing)
            }
        }
    }
}

// EN: Metadata section
// DE: Metadaten-Bereich
struct MetadataSection: View {
    let item: ClipboardItem
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: GlassTheme.smallSpacing) {
                Text("Metadata")
                    .font(.headline)
                
                if let ocrText = item.ocrText, !ocrText.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("OCR Text")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(ocrText)
                            .textSelection(.enabled)
                            .font(.callout)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Type")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.itemType.displayName)
                }
                .font(.callout)
                
                HStack {
                    Text("Size")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.displayFileSize)
                }
                .font(.callout)
                
                if !item.tags!.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            ForEach(item.tags!) { tag in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(tag.color)
                                        .frame(width: 8, height: 8)
                                    Text(tag.name)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(tag.color.opacity(0.1))
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// EN: Actions section
// DE: Aktionen-Bereich
struct ActionsSection: View {
    let item: ClipboardItem
    @State private var showDeleteConfirmation = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: GlassTheme.mediumSpacing) {
            Button(action: copyToClipboard) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            .buttonStyle(GlassButtonStyle())
            
            Button(action: shareItem) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(GlassButtonStyle(color: GlassTheme.accentPurple))
            
            Spacer()
            
            Button(action: { showDeleteConfirmation = true }) {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(GlassButtonStyle(color: GlassTheme.accentRed))
            .confirmationDialog(
                "Delete this item?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive, action: deleteItem)
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    private func copyToClipboard() {
        // EN: TODO: Implement clipboard copy
        // DE: TODO: Zwischenablage-Kopie implementieren
    }
    
    private func shareItem() {
        // EN: TODO: Implement share
        // DE: TODO: Teilen implementieren  
    }
    
    private func deleteItem() {
        modelContext.delete(item)
        try? modelContext.save()
    }
}