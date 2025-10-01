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
                    Label(item.sourceApp, systemImage: "app")
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
}

// EN: Content preview based on item type
// DE: Inhaltsvorschau basierend auf Elementtyp
struct ContentPreview: View {
    let item: ClipboardItem
    
    var body: some View {
        GlassCard {
            switch item.itemType {
            case .image, .screenshot:
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