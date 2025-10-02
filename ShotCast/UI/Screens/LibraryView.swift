// EN: Library view showing all clipboard items
// DE: Bibliotheksansicht zeigt alle Zwischenablage-Elemente

import SwiftUI
import SwiftData

struct LibraryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    
    // EN: Query items with dynamic filter
    // DE: Elemente mit dynamischem Filter abfragen
    @Query(sort: \ClipboardItem.timestamp, order: .reverse)
    private var items: [ClipboardItem]
    
    @Binding var selectedItem: ClipboardItem?
    
    // EN: Track latest item for notifications
    // DE: Verfolge neuestes Element für Benachrichtigungen
    @State private var latestItemId: UUID?
    @State private var showNewItemBadge = false
    
    // EN: Filter items based on search and type
    // DE: Elemente basierend auf Suche und Typ filtern
    private var filteredItems: [ClipboardItem] {
        let searchQuery = appState.searchQuery
        let selectedFilter = appState.selectedFilter
        
        return items.filter { item in
            // Search filter
            let matchesSearch = searchQuery.isEmpty || 
                item.title.localizedCaseInsensitiveContains(searchQuery) ||
                (item.ocrText ?? "").localizedCaseInsensitiveContains(searchQuery)
            
            // Type filter
            let matchesType = selectedFilter == nil || item.itemType == selectedFilter
            
            return matchesSearch && matchesType
        }
    }
    
    // EN: Main content area
    // DE: Haupt-Inhaltsbereich
    private var contentArea: some View {
        VStack(spacing: 0) {
            LibraryHeader()
                .padding(GlassTheme.mediumSpacing)
            
            Divider()
            
            itemsGridView
        }
        .background(.ultraThinMaterial)
    }
    
    // EN: Items grid view
    // DE: Elemente-Raster-Ansicht
    private var itemsGridView: some View {
        Group {
            if filteredItems.isEmpty {
                EmptyLibraryView()
            } else {
                itemsScrollView
            }
        }
    }
    
    // EN: Scrollable items view
    // DE: Scrollbare Elemente-Ansicht
    private var itemsScrollView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], 
                     spacing: GlassTheme.mediumSpacing) {
                ForEach(filteredItems) { item in
                    LibraryItemCard(
                        item: item,
                        isSelected: selectedItem?.id == item.id
                    ) {
                        selectedItem = item
                    }
                }
            }
            .padding(GlassTheme.mediumSpacing)
        }
    }
    
    // EN: Notification badge
    // DE: Benachrichtigungs-Badge
    private var notificationBadge: some View {
        Group {
            if showNewItemBadge {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                    Text("Neues Element hinzugefügt")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(GlassTheme.standardAnimation, value: showNewItemBadge)
            }
        }
    }
    
    var body: some View {
        contentArea
            .onChange(of: items.count) { _, newCount in
                handleNewItems()
            }
            .overlay(alignment: .topTrailing) {
                notificationBadge
            }
    }
    
    // EN: Handle new items notification
    // DE: Behandle neue Elemente Benachrichtigung
    private func handleNewItems() {
        if let firstItem = items.first, 
           firstItem.id != latestItemId {
            latestItemId = firstItem.id
            showNewItemBadge = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showNewItemBadge = false
            }
        }
    }
}

// EN: Library header with search and filters
// DE: Bibliotheks-Kopfzeile mit Suche und Filtern
struct LibraryHeader: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: GlassTheme.smallSpacing) {
            // EN: Search field
            // DE: Suchfeld
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search...", text: $appState.searchQuery)
                    .textFieldStyle(.plain)
            }
            .padding(GlassTheme.smallSpacing)
            .background(
                RoundedRectangle(cornerRadius: GlassTheme.smallRadius)
                    .fill(GlassTheme.glassBackground)
            )
            
            // EN: Type filter dropdown
            // DE: Typ-Filter Dropdown
            FilterDropdown(selectedFilter: $appState.selectedFilter)
        }
    }
}

// EN: Filter dropdown component for better space efficiency
// DE: Filter-Dropdown-Komponente für bessere Platzeffizienz  
struct FilterDropdown: View {
    @Binding var selectedFilter: ItemType?
    @State private var isExpanded = false
    
    private var selectedDisplayText: String {
        if let selectedFilter = selectedFilter {
            return selectedFilter.displayString
        } else {
            return "Alle"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // EN: Dropdown toggle button
            // DE: Dropdown-Umschaltknopf
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    if let selectedFilter = selectedFilter {
                        Image(systemName: selectedFilter.icon)
                            .font(.system(size: 13))
                            .foregroundColor(selectedFilter.color)
                    } else {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(selectedDisplayText)
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: GlassTheme.smallRadius)
                        .fill(GlassTheme.glassBackground)
                        .stroke(isExpanded ? GlassTheme.accentBlue : Color.clear, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // EN: Expandable filter grid
            // DE: Ausklappbares Filter-Grid
            if isExpanded {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 90, maximum: 110), spacing: 6)
                ], spacing: 6) {
                    FilterChip(
                        title: "Alle",
                        isSelected: selectedFilter == nil
                    ) {
                        selectedFilter = nil
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded = false
                        }
                    }
                    
                    ForEach(ItemType.allCases) { type in
                        FilterChip(
                            title: LocalizedStringKey(type.displayString),
                            icon: type.icon,
                            color: type.color,
                            isSelected: selectedFilter == type
                        ) {
                            selectedFilter = selectedFilter == type ? nil : type
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded = false
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// EN: Filter chip component
// DE: Filter-Chip-Komponente
struct FilterChip: View {
    let title: LocalizedStringKey
    var icon: String? = nil
    var color: Color = GlassTheme.accentBlue
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? color : .secondary)
                }
                Text(title)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(isSelected ? color : .primary)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? color.opacity(0.1) : Color.clear)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// EN: Empty library state
// DE: Leerer Bibliothekszustand
struct EmptyLibraryView: View {
    var body: some View {
        VStack(spacing: GlassTheme.largeSpacing) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No items found")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Copy something to your clipboard to get started")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// EN: Library item card
// DE: Bibliotheks-Element-Karte
struct LibraryItemCard: View {
    let item: ClipboardItem
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isHovered = false
    @State private var thumbnailImage: NSImage?
    
    var body: some View {
        GlassCard {
            HStack(alignment: .center, spacing: GlassTheme.mediumSpacing) {
                // EN: Preview container with floating badge
                // DE: Vorschau-Container mit schwebendem Badge
                ZStack {
                    // EN: Preview image or placeholder
                    // DE: Vorschaubild oder Platzhalter
                    if let thumbnailImage = thumbnailImage {
                        Image(nsImage: thumbnailImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        // EN: Fallback preview with pattern
                        // DE: Fallback-Vorschau mit Muster
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: getPreviewIcon())
                                    .font(.title2)
                                    .foregroundColor(.gray.opacity(0.6))
                            )
                    }
                    
                    // EN: Floating type badge (Option 2 style)
                    // DE: Schwebendes Typ-Badge (Option 2 Stil)
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: item.itemType.icon)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(item.itemType.color)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                .offset(x: 6, y: -6)
                        }
                        Spacer()
                    }
                }
                
                // EN: Content information
                // DE: Inhaltsinformationen
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(item.displayDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
            }
            .padding(GlassTheme.smallSpacing)
        }
        .overlay(
            RoundedRectangle(cornerRadius: GlassTheme.cardRadius)
                .stroke(
                    isSelected ? GlassTheme.accentBlue : Color.clear,
                    lineWidth: 2
                )
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(GlassTheme.quickAnimation, value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture(perform: onTap)
        .onAppear {
            loadThumbnailIfNeeded()
        }
    }
    
    // EN: Get preview icon for file type
    // DE: Vorschau-Icon für Dateityp abrufen
    private func getPreviewIcon() -> String {
        switch item.itemType {
        case .image: return "photo"
        case .pdf: return "doc.text"
        case .video: return "play.rectangle"
        case .text: return "doc.plaintext"
        case .word: return "doc.richtext"
        case .excel: return "tablecells"
        case .powerpoint: return "rectangle.on.rectangle"
        case .code: return "curlybraces"
        case .audio: return "waveform"
        default: return "doc"
        }
    }
    
    // EN: Load thumbnail for images and PDFs
    // DE: Lade Vorschaubild für Bilder und PDFs
    private func loadThumbnailIfNeeded() {
        // EN: Only generate thumbnails for supported types
        // DE: Nur Vorschaubilder für unterstützte Typen generieren
        guard item.itemType == .image || item.itemType == .pdf || item.itemType == .video else {
            return
        }
        
        // EN: Capture values needed for async task
        // DE: Erfasse Werte für asynchrone Aufgabe
        let itemCopy = item
        
        Task {
            let generator = ThumbnailGenerator()
            if let thumbnailData = await generator.generateThumbnail(for: itemCopy),
               let image = NSImage(data: thumbnailData) {
                await MainActor.run {
                    self.thumbnailImage = image
                }
            }
        }
    }
}

