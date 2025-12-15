import Foundation

struct FileMover {
    static func moveOrCopy(item: URL, toFolder: URL, copy: Bool, preferredName: String? = nil) throws -> URL {
        let fm = FileManager.default

        // Begin security-scoped access if available (for sandboxed apps)
        let didStartItemAccess = item.startAccessingSecurityScopedResource()
        let didStartFolderAccess = toFolder.startAccessingSecurityScopedResource()
        defer {
            if didStartItemAccess { item.stopAccessingSecurityScopedResource() }
            if didStartFolderAccess { toFolder.stopAccessingSecurityScopedResource() }
        }

        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: toFolder.path, isDirectory: &isDir), isDir.boolValue else {
            throw NSError(domain: "FileMover", code: 1, userInfo: [NSLocalizedDescriptionKey: "Destination folder does not exist."])
        }

        let baseName = (preferredName ?? item.lastPathComponent)
        let dest = uniqueDestinationURL(folder: toFolder, fileName: baseName)

        if copy {
            // Remove partial file if previous failed attempt exists
            if fm.fileExists(atPath: dest.path) {
                try fm.removeItem(at: dest)
            }
            try fm.copyItem(at: item, to: dest)
        } else {
            // Ensure any existing partial is removed before moving
            if fm.fileExists(atPath: dest.path) {
                try fm.removeItem(at: dest)
            }
            try fm.moveItem(at: item, to: dest)
        }
        return dest
    }

    static func trash(item: URL) throws {
        let fm = FileManager.default
        try fm.trashItem(at: item, resultingItemURL: nil)
    }

    private static func uniqueDestinationURL(folder: URL, fileName: String) -> URL {
        let fm = FileManager.default
        var candidate = folder.appendingPathComponent(fileName)
        if !fm.fileExists(atPath: candidate.path) {
            return candidate
        }

        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        var counter = 1
        while true {
            let newName = ext.isEmpty ? "\(name) \(counter)" : "\(name) \(counter).\(ext)"
            candidate = folder.appendingPathComponent(newName)
            if !fm.fileExists(atPath: candidate.path) { return candidate }
            counter += 1
        }
    }
}
