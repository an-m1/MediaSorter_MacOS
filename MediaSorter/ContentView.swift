import SwiftUI
import AVKit

struct Destination: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var url: URL
}

struct ContentView: View {
    @State private var sourceFolder: URL? = nil
    @State private var destinations: [Destination] = []
    @State private var media: [URL] = []
    @State private var index: Int = 0

    @State private var includeSubfolders: Bool = true
    @State private var copyInsteadOfMove: Bool = false

    @State private var statusText: String = ""
    @State private var undoStack: [(from: URL, to: URL)] = []

    // Video player (reused)
    @State private var player: AVPlayer = AVPlayer()

    var body: some View {
        VStack(spacing: 12) {
            header

            Divider()

            if media.isEmpty {
                emptyState
            } else {
                sorterUI
            }

            footer
        }
        .padding(14)
        .frame(minWidth: 980, minHeight: 650)
        .background(
            KeyboardCatcherView(
                onKeyDown: handleKeyEvent(_:),
                wantsFocus: true
            )
        )
        .onChange(of: index) { _, _ in
            syncVideoIfNeeded()
        }
        .onChange(of: media) { _, _ in
            clampIndex()
            syncVideoIfNeeded()
        }
        .onAppear {
            // Restore previously selected source and destinations from bookmarks
            if sourceFolder == nil {
                sourceFolder = BookmarkStore.loadSource()
            }
            let restored = BookmarkStore.loadDestinations()
            if !restored.isEmpty {
                destinations = restored
            }
        }
    }

    // MARK: - UI

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("MediaSorter")
                    .font(.system(size: 22, weight: .semibold))
                Text("←/→ browse • 1–9 send to destination • U undo • Space play/pause")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Toggle("Include subfolders", isOn: $includeSubfolders)
                    .toggleStyle(.switch)
                Toggle("Copy instead of move", isOn: $copyInsteadOfMove)
                    .toggleStyle(.switch)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("Pick a source folder and add destinations to start sorting.")
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Button("Choose Source Folder") { chooseSource() }
                Button("Add Destination") { addDestination() }
                    .disabled(sourceFolder == nil && destinations.count == 0) // still ok either way
                Button("Load Media") { loadMedia() }
                    .disabled(sourceFolder == nil)
            }

            if let src = sourceFolder {
                Text("Source: \(src.path)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if !destinations.isEmpty {
                destinationsList
                    .frame(maxWidth: 900)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sorterUI: some View {
        HStack(spacing: 14) {
            // Preview
            VStack(spacing: 10) {
                MediaPreview(url: media[index], player: $player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                fileInfoBar
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Destinations panel
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button("Change Source…") { chooseSource() }
                    Button("Reload") { loadMedia() }.disabled(sourceFolder == nil)
                }

                destinationsHeader

                destinationsList

                Divider()

                controlButtons
            }
            .frame(width: 330)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var destinationsHeader: some View {
        HStack {
            Text("Destinations")
                .font(.system(size: 14, weight: .semibold))
            Spacer()
            Button("Add") { addDestination() }
        }
    }

    private var destinationsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(destinations.enumerated()), id: \.element.id) { (i, d) in
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.15))
                        Text(i < 9 ? "\(i + 1)" : "•")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 28, height: 26)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(d.name).lineLimit(1)
                        Text(d.url.lastPathComponent)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button {
                        moveCurrent(to: d)
                    } label: {
                        Text("Send")
                    }
                    .disabled(media.isEmpty)

                    Button {
                        removeDestination(d)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.gray.opacity(0.08))
                )
            }

            if destinations.isEmpty {
                Text("No destinations yet. Click Add.")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))
                    .padding(.top, 6)
            }
        }
    }

    private var fileInfoBar: some View {
        let url = media[index]
        return HStack(spacing: 10) {
            Text("\(index + 1) / \(media.count)")
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.12)))

            Text(url.lastPathComponent)
                .font(.system(size: 12))
                .lineLimit(1)

            Spacer()

            Button("Reveal in Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }
        }
        .padding(.top, 6)
    }

    private var controlButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button("← Prev") { prev() }.disabled(media.isEmpty)
                Button("Next →") { next() }.disabled(media.isEmpty)
            }

            HStack(spacing: 10) {
                Button("Undo (U)") { undoLast() }
                    .disabled(undoStack.isEmpty)

                Button("Trash (Del)") { trashCurrent() }
                    .disabled(media.isEmpty)
            }

            Text(statusText)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(nil) // unlimited lines
                .textSelection(.enabled) // allow copy/paste of the message
                .padding(.top, 6)
        }
    }

    private var footer: some View {
        HStack {
            if let src = sourceFolder {
                Text("Source: \(src.path)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text("No source selected")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    // MARK: - Actions

    private func chooseSource() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Choose Source Folder"

        if panel.runModal() == .OK, let url = panel.url {
            sourceFolder = url
            statusText = "Selected source."
            BookmarkStore.saveSource(url)
        }
    }

    private func addDestination() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Choose Destination Folder"

        if panel.runModal() == .OK, let url = panel.url {
            let defaultName = url.lastPathComponent
            destinations.append(Destination(name: defaultName, url: url))
            statusText = "Added destination: \(defaultName)"
            BookmarkStore.saveDestinations(destinations)
        }
    }

    private func removeDestination(_ d: Destination) {
        destinations.removeAll { $0.id == d.id }
    }

    private func loadMedia() {
        guard let src = sourceFolder else { return }
        do {
            let files = try FileScanner.collectMediaFiles(in: src, includeSubfolders: includeSubfolders)
            media = files.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
            index = 0
            undoStack.removeAll()
            statusText = "Loaded \(media.count) files."
        } catch {
            statusText = "Failed to load media: \(error.localizedDescription)"
        }
    }

    private func moveCurrent(to destination: Destination) {
        guard !media.isEmpty else { return }
        let current = media[index]

        do {
            let newURL = try FileMover.moveOrCopy(
                item: current,
                toFolder: destination.url,
                copy: copyInsteadOfMove
            )

            if !copyInsteadOfMove {
                // remove from list
                media.remove(at: index)
                undoStack.append((from: newURL, to: current)) // from=dest, to=original location
                statusText = "Moved → \(destination.name)"
                // After moving (removal), keep index pointing to the same position, which is now the next item
                clampIndex()
            } else {
                statusText = "Copied → \(destination.name)"
                // After copying (no removal), advance to the next item explicitly
                next()
            }
        } catch {
            statusText = "Move failed: \(error.localizedDescription)"
        }
    }

    private func trashCurrent() {
        guard !media.isEmpty else { return }
        let current = media[index]
        do {
            try FileMover.trash(item: current)
            media.remove(at: index)
            statusText = "Moved to Trash."
            clampIndex()
        } catch {
            statusText = "Trash failed: \(error.localizedDescription)"
        }
    }

    private func undoLast() {
        guard let last = undoStack.popLast() else { return }
        do {
            // last.from is where file currently is (destination), last.to is original spot
            // We move it back (reverse)
            _ = try FileMover.moveOrCopy(item: last.from, toFolder: last.to.deletingLastPathComponent(), copy: false, preferredName: last.to.lastPathComponent)
            statusText = "Undo successful."
            // Reload list so it reappears (simpler & reliable)
            loadMedia()
        } catch {
            statusText = "Undo failed: \(error.localizedDescription)"
        }
    }

    private func prev() {
        guard !media.isEmpty else { return }
        index = max(0, index - 1)
    }

    private func next() {
        guard !media.isEmpty else { return }
        index = min(media.count - 1, index + 1)
    }

    private func clampIndex() {
        if media.isEmpty {
            index = 0
        } else if index >= media.count {
            index = max(0, media.count - 1)
        }
    }

    private func syncVideoIfNeeded() {
        guard !media.isEmpty else {
            player.replaceCurrentItem(with: nil)
            return
        }
        let url = media[index]
        if MediaType.isVideo(url) {
            let item = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: item)
        } else {
            player.replaceCurrentItem(with: nil)
        }
    }

    private func togglePlayPause() {
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }

    // MARK: - Keyboard

    private func handleKeyEvent(_ event: NSEvent) {
        guard event.type == .keyDown else { return }

        switch event.keyCode {
        case 123: // left arrow
            prev()
        case 124: // right arrow
            next()
        case 49: // space
            togglePlayPause()
        case 51, 117: // delete / forward delete
            trashCurrent()
        default:
            // Numbers 1–9
            if let chars = event.charactersIgnoringModifiers,
               let first = chars.first,
               let digit = Int(String(first)),
               digit >= 1, digit <= 9 {
                let i = digit - 1
                if i < destinations.count {
                    moveCurrent(to: destinations[i])
                }
                return
            }

            // Undo key
            if let chars = event.charactersIgnoringModifiers?.lowercased(), chars == "u" {
                undoLast()
            }
        }
    }
}

