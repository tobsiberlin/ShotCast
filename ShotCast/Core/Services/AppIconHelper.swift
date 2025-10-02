import AppKit
import Foundation

/// Helper class to fetch app icons from installed applications
actor AppIconHelper {
    static let shared = AppIconHelper()
    
    // Cache for fetched icons
    private var iconCache: [String: NSImage] = [:]
    
    // Common app name variations mapping
    private let appNameVariations: [String: String] = [
        "chrome": "Google Chrome",
        "google chrome": "Google Chrome",
        "firefox": "Firefox",
        "mozilla firefox": "Firefox",
        "safari": "Safari",
        "mail": "Mail",
        "apple mail": "Mail",
        "messages": "Messages",
        "imessage": "Messages",
        "slack": "Slack",
        "discord": "Discord",
        "vscode": "Visual Studio Code",
        "visual studio code": "Visual Studio Code",
        "code": "Visual Studio Code",
        "xcode": "Xcode",
        "terminal": "Terminal",
        "iterm": "iTerm",
        "iterm2": "iTerm",
        "photoshop": "Adobe Photoshop 2024",
        "adobe photoshop": "Adobe Photoshop 2024",
        "illustrator": "Adobe Illustrator 2024",
        "adobe illustrator": "Adobe Illustrator 2024",
        "figma": "Figma",
        "sketch": "Sketch",
        "notion": "Notion",
        "obsidian": "Obsidian",
        "spotify": "Spotify",
        "music": "Music",
        "apple music": "Music",
        "finder": "Finder",
        "preview": "Preview",
        "notes": "Notes",
        "apple notes": "Notes",
        "reminder": "Reminders",
        "reminders": "Reminders",
        "calendar": "Calendar",
        "ical": "Calendar",
        "zoom": "zoom.us",
        "teams": "Microsoft Teams",
        "microsoft teams": "Microsoft Teams",
        "excel": "Microsoft Excel",
        "microsoft excel": "Microsoft Excel",
        "word": "Microsoft Word",
        "microsoft word": "Microsoft Word",
        "powerpoint": "Microsoft PowerPoint",
        "microsoft powerpoint": "Microsoft PowerPoint",
        "outlook": "Microsoft Outlook",
        "microsoft outlook": "Microsoft Outlook"
    ]
    
    private init() {}
    
    /// Get icon for app by name or bundle identifier
    /// - Parameters:
    ///   - identifier: App name or bundle identifier
    ///   - size: Desired icon size (default 16x16)
    /// - Returns: App icon or fallback SF Symbol
    func getIcon(for identifier: String, size: CGSize = CGSize(width: 16, height: 16)) async -> NSImage {
        // Check cache first
        let cacheKey = "\(identifier)_\(size.width)x\(size.height)"
        if let cachedIcon = iconCache[cacheKey] {
            return cachedIcon
        }
        
        // Try to find the app
        var icon: NSImage?
        
        // First try as bundle identifier
        if let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: identifier) {
            icon = await getIconFromURL(app, size: size)
        }
        
        // If not found, try as app name
        if icon == nil {
            let normalizedName = normalizeAppName(identifier)
            
            // Try to find by display name
            if let app = findApplicationByName(normalizedName) {
                icon = await getIconFromURL(app, size: size)
            }
        }
        
        // If still not found, try variations
        if icon == nil {
            if let variation = appNameVariations[identifier.lowercased()] {
                if let app = findApplicationByName(variation) {
                    icon = await getIconFromURL(app, size: size)
                }
            }
        }
        
        // Fallback to SF Symbol
        if icon == nil {
            icon = getFallbackIcon(for: identifier, size: size)
        }
        
        // Cache the result
        if let finalIcon = icon {
            iconCache[cacheKey] = finalIcon
            return finalIcon
        }
        
        // Ultimate fallback
        return NSImage(systemSymbolName: "app", accessibilityDescription: "Generic App")!
    }
    
    /// Clear the icon cache
    func clearCache() {
        iconCache.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func normalizeAppName(_ name: String) -> String {
        // Remove .app extension if present
        let normalized = name.replacingOccurrences(of: ".app", with: "", options: .caseInsensitive)
        return normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func findApplicationByName(_ name: String) -> URL? {
        let fileManager = FileManager.default
        let applicationDirs = [
            "/Applications",
            "/System/Applications",
            "/Applications/Utilities",
            "/System/Applications/Utilities",
            NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first
        ].compactMap { $0 }
        
        for dir in applicationDirs {
            guard let url = URL(string: dir) else { continue }
            
            do {
                let contents = try fileManager.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )
                
                for appURL in contents {
                    if appURL.pathExtension == "app" {
                        let appName = appURL.deletingPathExtension().lastPathComponent
                        if appName.lowercased() == name.lowercased() {
                            return appURL
                        }
                    }
                }
            } catch {
                continue
            }
        }
        
        // Try using NSWorkspace to find by localized name
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        
        for app in runningApps {
            if let localizedName = app.localizedName,
               localizedName.lowercased() == name.lowercased(),
               let bundleURL = app.bundleURL {
                return bundleURL
            }
        }
        
        return nil
    }
    
    private func getIconFromURL(_ url: URL, size: CGSize) async -> NSImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                icon.size = size
                continuation.resume(returning: icon)
            }
        }
    }
    
    private func getFallbackIcon(for identifier: String, size: CGSize) -> NSImage {
        // Map common app types to appropriate SF Symbols
        let lowercased = identifier.lowercased()
        
        let symbolName: String
        if lowercased.contains("browser") || lowercased.contains("chrome") || lowercased.contains("firefox") || lowercased.contains("safari") {
            symbolName = "globe"
        } else if lowercased.contains("mail") || lowercased.contains("outlook") {
            symbolName = "envelope"
        } else if lowercased.contains("message") || lowercased.contains("chat") || lowercased.contains("slack") || lowercased.contains("discord") {
            symbolName = "message"
        } else if lowercased.contains("terminal") || lowercased.contains("iterm") {
            symbolName = "terminal"
        } else if lowercased.contains("code") || lowercased.contains("xcode") || lowercased.contains("vscode") {
            symbolName = "chevron.left.forwardslash.chevron.right"
        } else if lowercased.contains("music") || lowercased.contains("spotify") {
            symbolName = "music.note"
        } else if lowercased.contains("video") || lowercased.contains("movie") || lowercased.contains("tv") {
            symbolName = "play.rectangle"
        } else if lowercased.contains("photo") || lowercased.contains("image") {
            symbolName = "photo"
        } else if lowercased.contains("calendar") || lowercased.contains("ical") {
            symbolName = "calendar"
        } else if lowercased.contains("note") || lowercased.contains("notion") || lowercased.contains("obsidian") {
            symbolName = "note.text"
        } else if lowercased.contains("finder") {
            symbolName = "folder"
        } else if lowercased.contains("settings") || lowercased.contains("preferences") || lowercased.contains("system") {
            symbolName = "gearshape"
        } else if lowercased.contains("download") {
            symbolName = "arrow.down.circle"
        } else if lowercased.contains("trash") || lowercased.contains("bin") {
            symbolName = "trash"
        } else {
            symbolName = "app"
        }
        
        if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: identifier) {
            image.size = size
            return image
        }
        
        // Ultimate fallback
        let fallback = NSImage(systemSymbolName: "app", accessibilityDescription: "Generic App")!
        fallback.size = size
        return fallback
    }
}

// MARK: - Convenience Extensions

extension AppIconHelper {
    /// Get icon for multiple identifiers at once
    func getIcons(for identifiers: [String], size: CGSize = CGSize(width: 16, height: 16)) async -> [String: NSImage] {
        var icons: [String: NSImage] = [:]
        
        await withTaskGroup(of: (String, NSImage).self) { group in
            for identifier in identifiers {
                group.addTask {
                    let icon = await self.getIcon(for: identifier, size: size)
                    return (identifier, icon)
                }
            }
            
            for await (identifier, icon) in group {
                icons[identifier] = icon
            }
        }
        
        return icons
    }
    
    /// Check if an app is installed
    func isAppInstalled(_ identifier: String) async -> Bool {
        // Check by bundle ID
        if NSWorkspace.shared.urlForApplication(withBundleIdentifier: identifier) != nil {
            return true
        }
        
        // Check by name
        let normalizedName = normalizeAppName(identifier)
        if findApplicationByName(normalizedName) != nil {
            return true
        }
        
        // Check variations
        if let variation = appNameVariations[identifier.lowercased()],
           findApplicationByName(variation) != nil {
            return true
        }
        
        return false
    }
}