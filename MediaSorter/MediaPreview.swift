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
                VideoPlayer(player: player)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(10)

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

