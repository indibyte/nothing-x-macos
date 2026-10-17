//
//  BundledImage.swift
//  Nothing X MacOS
//

import SwiftUI
import AppKit

extension Image {
    /// Loads an image via NSImage so it resolves both from the asset catalog (Xcode builds)
    /// and from loose PNGs in Resources (SwiftPM builds via scripts/build-app.sh).
    init(bundled name: String) {
        self.init(nsImage: NSImage(named: name) ?? NSImage())
    }
}
