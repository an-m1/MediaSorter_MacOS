import Foundation

struct BookmarkStore {
    private static let sourceKey = "BookmarkStore.source"
    private static let destinationsKey = "BookmarkStore.destinations"

    struct DestinationBookmark: Codable, Hashable {
        var name: String
        var bookmarkData: Data
    }

    // MARK: - Save

    static func saveSource(_ url: URL) {
        do {
            let data = try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(data, forKey: sourceKey)
        } catch {
            print("BookmarkStore: failed to save source bookmark: \(error)")
        }
    }

    static func saveDestinations(_ destinations: [Destination]) {
        do {
            let items: [DestinationBookmark] = try destinations.map { d in
                let data = try d.url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
                return DestinationBookmark(name: d.name, bookmarkData: data)
            }
            let encoded = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encoded, forKey: destinationsKey)
        } catch {
            print("BookmarkStore: failed to save destination bookmarks: \(error)")
        }
    }

    // MARK: - Load

    static func loadSource() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: sourceKey) else { return nil }
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: data, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // Refresh bookmark
                try refreshSource(url)
            }
            return url
        } catch {
            print("BookmarkStore: failed to load source bookmark: \(error)")
            return nil
        }
    }

    static func loadDestinations() -> [Destination] {
        guard let data = UserDefaults.standard.data(forKey: destinationsKey) else { return [] }
        do {
            let items = try JSONDecoder().decode([DestinationBookmark].self, from: data)
            var result: [Destination] = []
            for item in items {
                var isStale = false
                let url = try URL(resolvingBookmarkData: item.bookmarkData, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale)
                if isStale {
                    // Try to refresh the bookmark and continue
                    try refreshDestination(name: item.name, url: url)
                }
                result.append(Destination(name: item.name, url: url))
            }
            return result
        } catch {
            print("BookmarkStore: failed to load destination bookmarks: \(error)")
            return []
        }
    }

    // MARK: - Refresh helpers

    private static func refreshSource(_ url: URL) throws {
        let data = try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(data, forKey: sourceKey)
    }

    private static func refreshDestination(name: String, url: URL) throws {
        _ = try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        let existing = loadDestinations()
        var updated = existing
        if let idx = updated.firstIndex(where: { $0.name == name && $0.url == url }) {
            updated[idx] = Destination(name: name, url: url)
        }
        // Re-save all destinations with new bookmark for this one
        saveDestinations(updated)
    }
}
