//
// File: NSColor+Extension.swift
// Package: Color Picker
// Created by: Steven Barnett on 22/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

extension NSColor {
    var toSRGB: NSColor {
        guard let color = usingColorSpace(.sRGB) else {
            let error = NSError.appError("Failed to convert color with color space \(colorSpace.localizedName ?? "<Unknown>") to sRGB")

            DispatchQueue.main.async {
                NSApp.presentError(error)
            }

            return self
        }

        return color
    }

    var hexColorString: String {
        toSRGB.format(
            .hex(
                isUppercased: Defaults[.uppercaseHexColor],
                hasPrefix: NSEvent.modifiers == .option ? !Defaults[.hashPrefixInHexColor] : Defaults[.hashPrefixInHexColor]
            )
        )
    }

    var hslColorString: String { toSRGB.format(Defaults[.legacyColorSyntax] ? .cssHSLLegacy : .cssHSL) }

    var rgbColorString: String { toSRGB.format(Defaults[.legacyColorSyntax] ? .cssRGBLegacy : .cssRGB) }

    var lchColorString: String { toSRGB.format(.cssLCH) }

    var hsbColorString: String { format(.hsb) }

    var stringRepresentation: String {
        switch Defaults[.preferredColorFormat] {
        case .hex:
            return hexColorString
        case .hsl:
            return hslColorString
        case .rgb:
            return rgbColorString
        case .lch:
            return lchColorString
        }
    }
}

extension NSColor {
    var swatchImage: NSImage {
        .color(
            self,
            size: CGSize(width: 16, height: 16),
            borderWidth: 1,
            borderColor: (SSApp.isDarkMode ? NSColor.white : .black).withAlphaComponent(0.2),
            cornerRadius: 4
        )
    }
}

extension NSColor {
    /**
    Initialize from a `RGB` color.
    */
    convenience init(_ rgbColor: Colors.RGB) {
        self.init(
            red: rgbColor.red,
            green: rgbColor.green,
            blue: rgbColor.blue,
            alpha: rgbColor.alpha
        )
    }
}

extension NSColor {
    var rgb: Colors.RGB {
        #if canImport(AppKit)
        guard let color = usingColorSpace(.extendedSRGB) else {
            assertionFailure("Unsupported color space")
            return .init(red: 0, green: 0, blue: 0, alpha: 0)
        }
        #elseif canImport(UIKit)
        let color = self
        #endif

        // swiftlint:disable no_cgfloat
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        // swiftlint:enable no_cgfloat

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return .init(
            red: red,
            green: green,
            blue: blue,
            alpha: alpha
        )
    }
}

extension NSColor {
    typealias HSB = (hue: Double, saturation: Double, brightness: Double, alpha: Double)

    /**
    This preserves the original color space as long as it is RGB, otherwise, it is normalized to extended sRGB.
    */
    var hsbRaw: HSB {
        var color = self

        if colorSpace.colorSpaceModel != .rgb {
            guard let color_ = usingColorSpace(.extendedSRGB) else {
                assertionFailure("Unsupported color space")
                return HSB(0, 0, 0, 0)
            }

            color = color_
        }

        // swiftlint:disable no_cgfloat
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        // swiftlint:enable no_cgfloat

        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return HSB(
            hue: Double(hue),
            saturation: Double(saturation),
            brightness: Double(brightness),
            alpha: Double(alpha)
        )
    }

    var hsb: HSB {
        #if canImport(AppKit)
        guard let color = usingColorSpace(.extendedSRGB) else {
            assertionFailure("Unsupported color space")
            return HSB(0, 0, 0, 0)
        }
        #elseif canImport(UIKit)
        let color = self
        #endif

        // swiftlint:disable no_cgfloat
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        // swiftlint:enable no_cgfloat

        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return HSB(
            hue: Double(hue),
            saturation: Double(saturation),
            brightness: Double(brightness),
            alpha: Double(alpha)
        )
    }
}


extension NSColor {
    /**
    - Important: Ensure you use a compatible color space, otherwise it will just be black.
    */
    var hsl: Colors.HSL {
        let hsb = hsb

        var saturation = hsb.saturation * hsb.brightness
        var lightness = (2.0 - hsb.saturation) * hsb.brightness

        let saturationDivider = (lightness <= 1.0 ? lightness : 2.0 - lightness)
        if saturationDivider != 0 {
            saturation /= saturationDivider
        }

        lightness /= 2.0

        return .init(
            hue: hsb.hue,
            saturation: saturation,
            lightness: lightness,
            alpha: hsb.alpha
        )
    }

    /**
    Create from HSL components.
    */
    convenience init(
        colorSpace: NSColorSpace,
        hue: Double,
        saturation: Double,
        lightness: Double,
        alpha: Double
    ) {
        precondition(
            0...1 ~= hue
                && 0...1 ~= saturation
                && 0...1 ~= lightness
                && 0...1 ~= alpha,
            "Input is out of range 0...1"
        )

        let brightness = lightness + saturation * min(lightness, 1 - lightness)
        let newSaturation = brightness == 0 ? 0 : (2 * (1 - lightness / brightness))

        self.init(
            colorSpace: colorSpace,
            hue: hue,
            saturation: newSaturation,
            brightness: brightness,
            alpha: alpha
        )
    }
}

extension NSColor {
    private static let cssHSLRegex = /^\s*hsla?\((?<hue>\d+)(?:deg)?[\s,]*(?<saturation>[\d.]+)%[\s,]*(?<lightness>[\d.]+)%\);?\s*$/

    /**
    Assumes `sRGB` color space.
    */
    convenience init?(cssHSLString: String) {
        guard
            let match = cssHSLString.wholeMatch(of: Self.cssHSLRegex)?.output,
            let hue = Double(match.hue),
            let saturation = Double(match.saturation),
            let lightness = Double(match.lightness),
            (0...360).contains(hue),
            (0...100).contains(saturation),
            (0...100).contains(lightness)
        else {
            return nil
        }

        self.init(
            colorSpace: .sRGB,
            hue: hue / 360,
            saturation: saturation / 100,
            lightness: lightness / 100,
            alpha: 1
        )
    }
}

extension NSColor {
    private static let cssRGBRegex = /^\s*rgba?\((?<red>[\d.]+)[\s,]*(?<green>[\d.]+)[\s,]*(?<blue>[\d.]+)\);?\s*$/

    // Fixture: rgb(27.59% 41.23% 100%)
    /**
    Assumes `sRGB` color space.
    */
    convenience init?(cssRGBString: String) {
        guard
            let match = cssRGBString.wholeMatch(of: Self.cssRGBRegex)?.output,
            let red = Double(match.red),
            let green = Double(match.green),
            let blue = Double(match.blue),
            (0...255).contains(red),
            (0...255).contains(green),
            (0...255).contains(blue)
        else {
            return nil
        }

        self.init(
            srgbRed: red / 255,
            green: green / 255,
            blue: blue / 255,
            alpha: 1
        )
    }
}

extension NSColor {
    private static let cssLCHRegex = /^\s*lch\((?<lightness>[\d.]+)%\s+(?<chroma>[\d.]+)\s+(?<hue>[\d.]+)(?:deg)?\s*(?<alpha>\/\s+[\d.]+%?)?\)?;?$/

    /**
    Assumes `sRGB` color space.
    */
    convenience init?(cssLCHString: String) {
        guard
            let match = cssLCHString.wholeMatch(of: Self.cssLCHRegex)?.output,
            let lightness = Double(match.lightness),
            let chroma = Double(match.chroma),
            let hue = Double(match.hue),
            (0...100).contains(lightness),
            chroma >= 0, // Usually max 230, but theoretically unbounded.
            (0...360).contains(hue)
        else {
            return nil
        }

        let lch = Colors.LCH(
            lightness: lightness,
            chroma: chroma,
            hue: hue,
            alpha: 1
        )

        self.init(lch.toRGB())
    }
}


extension NSColor {
    /**
    Create a color from a CSS color string in the format Hex, HSL, or RGB.

    Assumes `sRGB` color space.
    */
    static func from(cssString: String) -> NSColor? {
        if let color = NSColor(hexString: cssString) {
            return color
        }

        if let color = NSColor(cssHSLString: cssString) {
            return color
        }

        if let color = NSColor(cssRGBString: cssString) {
            return color
        }

        if let color = NSColor(cssLCHString: cssString) {
            return color
        }

        return nil
    }
}


extension NSColor {
    /**
    Loosely gets a color from the pasteboard.

    It first tries to get an actual `NSColor` and then tries to parse a CSS string (ignoring leading/trailing whitespace) for Hex, HSL, and RGB.
    */
    static func fromPasteboardGraceful(_ pasteboard: NSPasteboard) -> NSColor? {
        if let color = self.init(from: pasteboard) {
            return color
        }

        guard
            let string = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespaces),
            let color = from(cssString: string)
        else {
            return nil
        }

        return color
    }
}


extension NSColor {
    /**
    ```
    NSColor(hex: 0xFFFFFF)
    ```
    */
    convenience init(hex: Int, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    convenience init?(hexString: String, alpha: Double = 1) {
        var string = hexString

        if hexString.hasPrefix("#") {
            string = String(hexString.dropFirst())
        }

        if string.count == 3 {
            string = string.map { "\($0)\($0)" }.joined()
        }

        guard let hex = Int(string, radix: 16) else {
            return nil
        }

        self.init(hex: hex, alpha: alpha)
    }

    /**
    - Important: Don't forget to convert it to the correct color space first.

    ```
    NSColor(hexString: "#fefefe")!.hex
    //=> 0xFEFEFE
    ```
    */
    var hex: Int {
        #if canImport(AppKit)
        guard numberOfComponents == 4 else {
            assertionFailure()
            return 0x0
        }
        #endif

        let red = Int((redComponent * 0xFF).rounded())
        let green = Int((greenComponent * 0xFF).rounded())
        let blue = Int((blueComponent * 0xFF).rounded())

        return red << 16 | green << 8 | blue
    }

    /**
    - Important: Don't forget to convert it to the correct color space first.

    ```
    NSColor(hexString: "#fefefe")!.hexString
    //=> "#fefefe"
    ```
    */
    var hexString: String {
        String(format: "#%06x", hex)
    }
}


extension NSColor {
    enum ColorStringFormat {
        case hex(isUppercased: Bool = false, hasPrefix: Bool = false)
        case cssHSL
        case cssRGB
        case cssLCH
        case cssHSLLegacy
        case cssRGBLegacy
        case hsb
    }

    /**
    Format the color to a string using the given format.
    */
    func format(_ format: ColorStringFormat) -> String {
        switch format {
        case .hex(let isUppercased, let hasPrefix):
            var string = hexString

            if isUppercased {
                string = string.uppercased()
            }

            if !hasPrefix {
                string = String(string.dropFirst())
            }

            return string
        case .cssHSL:
            let hsl = hsl
            let hue = Int((hsl.hue * 360).rounded())
            let saturation = Int((hsl.saturation * 100).rounded())
            let lightness = Int((hsl.lightness * 100).rounded())
            return String(format: "hsl(%ddeg %d%% %d%%)", hue, saturation, lightness)
        case .cssRGB:
            let rgb = rgb
            let red = Int((rgb.red * 0xFF).rounded())
            let green = Int((rgb.green * 0xFF).rounded())
            let blue = Int((rgb.blue * 0xFF).rounded())
            return String(format: "rgb(%d %d %d)", red, green, blue)
        case .cssLCH:
            let lch = rgb.toLCH()
            let lightness = Int(lch.lightness.rounded())
            let chroma = Int(lch.chroma.rounded())
            let hue = Int(lch.hue.rounded())
            return String(format: "lch(%d%% %d %ddeg)", lightness, chroma, hue)
        case .cssHSLLegacy:
            let hsl = hsl
            let hue = Int((hsl.hue * 360).rounded())
            let saturation = Int((hsl.saturation * 100).rounded())
            let lightness = Int((hsl.lightness * 100).rounded())
            return String(format: "hsl(%d, %d%%, %d%%)", hue, saturation, lightness)
        case .cssRGBLegacy:
            let rgb = rgb
            let red = Int((rgb.red * 0xFF).rounded())
            let green = Int((rgb.green * 0xFF).rounded())
            let blue = Int((rgb.blue * 0xFF).rounded())
            return String(format: "rgb(%d, %d, %d)", red, green, blue)
        case .hsb:
            let hsb = hsbRaw // We use the current color space.
            let hue = Int((hsb.hue * 360).rounded())
            let saturation = Int((hsb.saturation * 100).rounded())
            let brightness = Int((hsb.brightness * 100).rounded())
            return String(format: "%d %d%% %d%%", hue, saturation, brightness)
        }
    }
}

extension NSColor: Identifiable {
    public var id: String { "\(rgb.hashValue) - \(colorSpace.localizedName ?? "")" }
}

// MARK: - Color extensions

extension Color {
    /**
    Create a `Color` from HSL components.

    Assumes `extendedSRGB` input.
    */
    init(
        hue: Double,
        saturation: Double,
        lightness: Double,
        opacity: Double
    ) {
        precondition(
            0...1 ~= hue
                && 0...1 ~= saturation
                && 0...1 ~= lightness
                && 0...1 ~= opacity,
            "Input is out of range 0...1"
        )

        let brightness = lightness + saturation * min(lightness, 1 - lightness)
        let newSaturation = brightness == 0 ? 0 : (2 * (1 - lightness / brightness))

        self.init(
            hue: hue,
            saturation: newSaturation,
            brightness: brightness,
            opacity: opacity
        )
    }
}
