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
            
            // EN: Type filters
            // DE: Typ-Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GlassTheme.smallSpacing) {
                    FilterChip(
                        title: "Alle",
                        isSelected: appState.selectedFilter == nil
                    ) {
                        appState.selectedFilter = nil
                    }
                    
                    ForEach(ItemType.allCases) { type in
                        FilterChip(
                            title: type.displayName,
                            icon: type.icon,
                            color: type.color,
                            isSelected: appState.selectedFilter == type
                        ) {
                            appState.selectedFilter = appState.selectedFilter == type ? nil : type
                        }
                    }
                }
                .padding(.horizontal, GlassTheme.tinySpacing)
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
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.system(size: 13))
            }
        }
        .buttonStyle(GlassButtonStyle(color: isSelected ? color : .secondary))
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
            VStack(alignment: .leading, spacing: GlassTheme.smallSpacing) {
                // EN: Thumbnail or icon
                // DE: Vorschaubild oder Symbol
                if let thumbnailImage = thumbnailImage {
                    Image(nsImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: GlassTheme.smallRadius))
                        .overlay(
                            // EN: Item type badge on thumbnail
                            // DE: Element-Typ-Badge auf Vorschaubild
                            HStack {
                                Spacer()
                                VStack {
                                    HStack(spacing: 4) {
                                        Image(systemName: item.itemType.icon)
                                            .font(.caption)
                                        if item.isFavorite {
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(.ultraThinMaterial, in: Capsule())
                                    .foregroundColor(item.itemType.color)
                                    Spacer()
                                }
                            }
                            .padding(GlassTheme.tinySpacing)
                        )
                } else {
                    // EN: Fallback icon view
                    // DE: Fallback-Symbol-Ansicht
                    HStack {
                        Image(systemName: item.itemType.icon)
                            .font(.title2)
                            .foregroundColor(item.itemType.color)
                        
                        Spacer()
                        
                        if item.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Text(item.title)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(item.displayDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !item.tags!.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(item.tags!) { tag in
                            Text(tag.name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(tag.color.opacity(0.2))
                                )
                        }
                    }
                }
            }
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
    
    // EN: Load thumbnail for images and PDFs
    // DE: Lade Vorschaubild für Bilder und PDFs
    private func loadThumbnailIfNeeded() {
        // EN: Only generate thumbnails for supported types
        // DE: Nur Vorschaubilder für unterstützte Typen generieren
        guard item.itemType == .image || item.itemType == .pdf || item.itemType == .video else {
            return
        }
        
        Task {
            let generator = ThumbnailGenerator()
            if let thumbnailData = await generator.generateThumbnail(for: item),
               let image = NSImage(data: thumbnailData) {
                await MainActor.run {
                    self.thumbnailImage = image
                }
            }
        }
    }
}

