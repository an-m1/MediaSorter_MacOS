import Foundation
import UniformTypeIdentifiers

enum MediaType {
    static func isVideo(_ url: URL) -> Bool {
        guard let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType else {
            return isVideoByExtension(url)
        }
        return type.conforms(to: .movie) || type.conforms(to: .audiovisualContent)
    }

    static func isImage(_ url: URL) -> Bool {
        guard let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType else {
            return isImageByExtension(url)
        }
        return type.conforms(to: .image)
    }

    private static func isVideoByExtension(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        let known: Set<String> = ["mp4", "mov", "m4v", "avi", "mkv", "hevc", "heif", "webm", "mpg", "mpeg"]
        return known.contains(ext)
    }

    private static func isImageByExtension(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        let known: Set<String> = ["jpg", "jpeg", "png", "gif", "tiff", "tif", "bmp", "heic", "heif", "webp"]
        return known.contains(ext)
    }

    static func isSupported(_ url: URL) -> Bool {
        return isImage(url) || isVideo(url)
    }
}
