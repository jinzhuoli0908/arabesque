import AppKit

/// Renders the menu-bar icon: a bold "Ä" in a 16 pt (32 px) TIFF.
enum IconRenderer {
    enum Failure: Error { case bitmap, encoding }

    static func write(to url: URL) throws {
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: 32, pixelsHigh: 32, bitsPerSample: 8, samplesPerPixel: 4,
            hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) else { throw Failure.bitmap }
        rep.size = NSSize(width: 16, height: 16)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        let text = NSAttributedString(string: "Ä", attributes: [
            .font: NSFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: NSColor.black,
        ])
        let size = text.size()
        text.draw(at: NSPoint(x: (16 - size.width) / 2, y: (16 - size.height) / 2))
        NSGraphicsContext.restoreGraphicsState()
        guard let data = rep.tiffRepresentation else { throw Failure.encoding }
        try data.write(to: url)
    }
}
