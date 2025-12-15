//
//  MediaPreview.swift
//  MediaSorter
//
//  Created by Ankit Modhera on 2025-12-12.
//

import SwiftUI
import AVKit

struct MediaPreview: View {
    let url: URL
    @Binding var player: AVPlayer

    private var videoView: some View {
        PlayerContainerView(player: player)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(10)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.06))

            if MediaType.isImage(url) {
                if let img = NSImage(contentsOf: url) {
                    GeometryReader { geo in
                        Image(nsImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                    .padding(10)
                } else {
                    Text("Could not load image.")
                        .foregroundStyle(.secondary)
                }
            } else if MediaType.isVideo(url) {
                videoView

                VStack {
                    Spacer()
                    HStack {
                        Text("Video • Space to play/pause")
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.15)))
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(18)
                }
            } else {
                Text("Unsupported file type.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - AVPlayerView wrapper

private struct PlayerContainerView: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .floating
        view.videoGravity = .resizeAspect
        view.player = player
        view.showsFullScreenToggleButton = false
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        nsView.player = player
    }
}

