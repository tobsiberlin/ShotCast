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
    
    // EN: Filter items based on search and type
    // DE: Elemente basierend auf Suche und Typ filtern
    private var filteredItems: [ClipboardItem] {
        items.filter { item in
            let matchesSearch = appState.searchQuery.isEmpty || 
                item.title.localizedCaseInsensitiveContains(appState.searchQuery) ||
                (item.ocrText ?? "").localizedCaseInsensitiveContains(appState.searchQuery)
            
            let matchesType = appState.selectedFilter == nil || 
                item.itemType == appState.selectedFilter
            
            return matchesSearch && matchesType
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // EN: Search and filter header
            // DE: Such- und Filter-Kopfzeile
            LibraryHeader()
                .padding(GlassTheme.mediumSpacing)
            
            Divider()
            
            // EN: Items grid
            // DE: Elemente-Raster
            if filteredItems.isEmpty {
                EmptyLibraryView()
            } else {
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
        }
        .background(.ultraThinMaterial)
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
                        title: "All",
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
                            appState.selectedFilter = type
                        }
                    }
                }
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
                .foregroundColor(.tertiary)
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
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: GlassTheme.smallSpacing) {
                // EN: Item icon and title
                // DE: Element-Symbol und Titel
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
    }
}