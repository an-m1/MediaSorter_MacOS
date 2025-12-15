//
//  KeyboardCatcherView.swift
//  MediaSorter
//
//  Created by Ankit Modhera on 2025-12-12.
//

import SwiftUI

struct KeyboardCatcherView: NSViewRepresentable {
    let onKeyDown: (NSEvent) -> Void
    var wantsFocus: Bool = true

    func makeNSView(context: Context) -> KeyCatcherNSView {
        let v = KeyCatcherNSView()
        v.onKeyDown = onKeyDown
        DispatchQueue.main.async {
            if wantsFocus {
                v.window?.makeFirstResponder(v)
            }
        }
        return v
    }

    func updateNSView(_ nsView: KeyCatcherNSView, context: Context) {
        nsView.onKeyDown = onKeyDown
        DispatchQueue.main.async {
            if wantsFocus, nsView.window?.firstResponder !== nsView {
                nsView.window?.makeFirstResponder(nsView)
            }
        }
    }
}

final class KeyCatcherNSView: NSView {
    var onKeyDown: ((NSEvent) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        onKeyDown?(event)
    }
}
