import Foundation

struct FileScanner {
    static func collectMediaFiles(in folder: URL, includeSubfolders: Bool) throws -> [URL] {
        var results: [URL] = []
        let fm = FileManager.default

        if includeSubfolders {
            let enumerator = fm.enumerator(at: folder, includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey, .contentTypeKey], options: [.skipsHiddenFiles])
            while let item = enumerator?.nextObject() as? URL {
                if try isMediaFile(url: item) {
                    results.append(item)
                }
            }
        } else {
            let contents = try fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.isRegularFileKey, .contentTypeKey], options: [.skipsHiddenFiles])
            for url in contents {
                if try isMediaFile(url: url) {
                    results.append(url)
                }
            }
        }

        return results
    }

    private static func isMediaFile(url: URL) throws -> Bool {
        let values = try? url.resourceValues(forKeys: [.isRegularFileKey])
        guard values?.isRegularFile == true else { return false }
        return MediaType.isImage(url) || MediaType.isVideo(url)
    }
}
