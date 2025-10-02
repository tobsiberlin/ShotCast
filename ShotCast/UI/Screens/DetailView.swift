// EN: Detail view for selected clipboard item
// DE: Detailansicht für ausgewähltes Zwischenablage-Element

import SwiftUI

struct DetailView: View {
    let item: ClipboardItem
    @Environment(\.modelContext) private var modelContext
    @State private var editingTitle = false
    @State private var tempTitle = ""
    
    var body: some View {
        HStack(spacing: 0) {
            // EN: App sidebar (Option 3 style)
            // DE: App-Seitenleiste (Option 3 Stil)
            AppSidebar(item: item)
            
            // EN: Main content area
            // DE: Haupt-Inhaltsbereich
            ScrollView {
                VStack(alignment: .leading, spacing: GlassTheme.largeSpacing) {
                    // EN: Title section
                    // DE: Titel-Bereich
                    DetailTitleSection(
                        item: item,
                        editingTitle: $editingTitle,
                        tempTitle: $tempTitle
                    )
                    
                    // EN: Content preview
                    // DE: Inhaltsvorschau
                    ContentPreview(item: item)
                    
                    // EN: Properties section
                    // DE: Eigenschaften-Bereich
                    PropertiesSection(item: item)
                    
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
}

// EN: App sidebar with large app logo (Option 3 style)
// DE: App-Seitenleiste mit großem App-Logo (Option 3 Stil)
struct AppSidebar: View {
    let item: ClipboardItem
    @State private var appIcon: NSImage?
    
    var body: some View {
        VStack(spacing: GlassTheme.mediumSpacing) {
            Spacer(minLength: 20)
            
            // EN: Large app logo
            // DE: Großes App-Logo
            Group {
                if let appIcon = appIcon {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.2),
                                Color.gray.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "app.fill")
                                .font(.title)
                                .foregroundColor(.gray.opacity(0.6))
                        )
                }
            }
            
            // EN: App name
            // DE: App-Name
            Text(item.sourceApp.isEmpty ? "Unbekannt" : item.sourceApp)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // EN: App category
            // DE: App-Kategorie
            Text(getAppCategory())
                .font(.caption2)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Spacer()
        }
        .frame(width: 120)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(NSColor.controlBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(width: 1),
            alignment: .trailing
        )
        .task {
            if !item.sourceApp.isEmpty {
                appIcon = await AppIconHelper.shared.getIcon(for: item.sourceApp, size: CGSize(width: 64, height: 64))
            }
        }
    }
    
    private func getAppCategory() -> String {
        let appName = item.sourceApp.lowercased()
        
        if appName.contains("finder") { return "Datei-Manager" }
        if appName.contains("safari") || appName.contains("chrome") || appName.contains("firefox") { return "Web-Browser" }
        if appName.contains("mail") || appName.contains("outlook") { return "E-Mail" }
        if appName.contains("message") || appName.contains("slack") || appName.contains("discord") { return "Kommunikation" }
        if appName.contains("word") || appName.contains("pages") { return "Textverarbeitung" }
        if appName.contains("excel") || appName.contains("numbers") { return "Tabellenkalkulation" }
        if appName.contains("powerpoint") || appName.contains("keynote") { return "Präsentation" }
        if appName.contains("code") || appName.contains("xcode") { return "Entwicklung" }
        if appName.contains("photoshop") || appName.contains("figma") || appName.contains("sketch") { return "Design" }
        
        return "Anwendung"
    }
}

// EN: Detail title section
// DE: Detail-Titel-Bereich
struct DetailTitleSection: View {
    let item: ClipboardItem
    @Binding var editingTitle: Bool
    @Binding var tempTitle: String
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: GlassTheme.smallSpacing) {
            HStack {
                // EN: Editable title
                // DE: Bearbeitbarer Titel
                if editingTitle {
                    HStack {
                        TextField("Title", text: $tempTitle)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit(saveTitle)
                        
                        Button("Speichern", action: saveTitle)
                            .buttonStyle(GlassButtonStyle())
                        
                        Button("Abbrechen") {
                            editingTitle = false
                            tempTitle = item.title
                        }
                        .buttonStyle(GlassButtonStyle(color: .secondary))
                    }
                } else {
                    Text(item.title)
                        .font(.title2)
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
                
                Spacer()
                
                Button(action: toggleFavorite) {
                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                        .foregroundColor(item.isFavorite ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }
            
            // EN: File type subtitle
            // DE: Dateityp-Untertitel
            Text(item.itemType.displayString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
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

// EN: Properties section with tags
// DE: Eigenschaften-Bereich mit Tags
struct PropertiesSection: View {
    let item: ClipboardItem
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: GlassTheme.smallSpacing) {
                Text("Eigenschaften")
                    .font(.headline)
                
                // EN: Property tags
                // DE: Eigenschafts-Tags
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    PropertyTag(label: "Größe", value: item.displayFileSize)
                    PropertyTag(label: "Datum", value: formatDate(item.timestamp))
                    PropertyTag(label: "Zeit", value: formatTime(item.timestamp))
                    PropertyTag(label: "Typ", value: item.itemType.displayString)
                }
                
                if let ocrText = item.ocrText, !ocrText.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("OCR Text")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(ocrText)
                            .textSelection(.enabled)
                            .font(.callout)
                            .lineLimit(4)
                    }
                }
                
                if !item.tags!.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(spacing: 6) {
                            ForEach(item.tags!) { tag in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(tag.color)
                                        .frame(width: 8, height: 8)
                                    Text(tag.name)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 8)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// EN: Property tag component
// DE: Eigenschafts-Tag-Komponente
struct PropertyTag: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

// EN: Simple flow layout for tags
// DE: Einfaches Flow-Layout für Tags
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content
    
    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            content()
        }
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
                    AppIconView(appName: item.sourceApp)
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

// EN: App icon view that loads actual app icons
// DE: App-Icon-Ansicht die echte App-Icons lädt
struct AppIconView: View {
    let appName: String
    @State private var appIcon: NSImage?
    
    var body: some View {
        HStack(spacing: 4) {
            if let appIcon = appIcon {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .cornerRadius(3)
            } else {
                Image(systemName: "app.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(appName)
                .font(.caption)
        }
        .task {
            appIcon = await AppIconHelper.shared.getIcon(for: appName, size: CGSize(width: 16, height: 16))
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