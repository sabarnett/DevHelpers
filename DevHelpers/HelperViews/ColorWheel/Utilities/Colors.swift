//
// File: Colors.swift
// Package: Color Picker
// Created by: Steven Barnett on 24/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

// TODO: I plan to extract this out into a Swift package when it's more mature.
enum Colors {}

extension Colors {
    /**
    RGB color in the `extendedSRGB` color space.

    The components are usually in the range `0...1` but could extend it (except `alpha`).
    */
    struct RGB: Hashable {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }

    /**
    HSL color.

    The components are in the range `0...1`.
    */
    struct HSL: Hashable {
        let hue: Double
        let saturation: Double
        let lightness: Double
        let alpha: Double
    }

    struct LCH: Hashable {
        /**
        Range: `0...100`
        */
        let lightness: Double

        /**
        Range: `0...132` *(Could be higher)*
        */
        let chroma: Double

        /**
        Range: `0...360`
        */
        let hue: Double

        /**
        Range: `0...1`
        */
        let alpha: Double
    }
}

extension Colors {
    /**
    Convert a color component of a gamma-corrected form of sRGB to linear-light sRGB.

    https://en.wikipedia.org/wiki/SRGB
    */
    fileprivate static func sRGBToLinearSRGB(colorComponent: Double) -> Double {
        colorComponent > 0.04045
            ? pow((colorComponent + 0.055) / 1.055, 2.40)
            : (colorComponent / 12.92)
    }

    /**
    Convert a color component of a linear-light sRGB to a gamma-corrected form.

    https://en.wikipedia.org/wiki/SRGB
    */
    fileprivate static func linearSRGBToSRGB(colorComponent: Double) -> Double {
        colorComponent > 0.0031308
            ? (pow(colorComponent, 1.0 / 2.4) * 1.055 - 0.055)
            : (colorComponent * 12.92)
    }

    /**
    Convert a linear-light sRGB to XYZ, using sRGB's own white, D65 (no chromatic adaptation).

    - http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
    - https://www.image-engineering.de/library/technotes/958-how-to-convert-between-srgb-and-ciexyz
    */
    fileprivate static func linearSRGBToXYZ(
        red: Double,
        green: Double,
        blue: Double
    ) -> (x: Double, y: Double, z: Double) {
        (
            x: (red * 0.4124564) + (green * 0.3575761) + (blue * 0.1804375),
            y: (red * 0.2126729) + (green * 0.7151522) + (blue * 0.0721750),
            z: (red * 0.0193339) + (green * 0.1191920) + (blue * 0.9503041)
        )
    }

    /**
    Convert D65-adapted XYZ to linear-light sRGB.
    */
    fileprivate static func xyzToLinearSRGB(
        x: Double,
        y: Double,
        z: Double
    ) -> (red: Double, green: Double, blue: Double) {
        (
            red: (x * 3.2404542) + (y * -1.5371385) + (z * -0.4985314),
            green: (x * -0.9692660) + (y * 1.8760108) + (z * 0.0415560),
            blue: (x * 0.0556434) + (y * -0.2040259) + (z * 1.0572252)
        )
    }

    /**
    Bradford chromatic adaptation from D65 to D50 for XYZ.

    http://www.brucelindbloom.com/index.html?Eqn_ChromAdapt.html
    */
    fileprivate static func d65ToD50(
        x: Double,
        y: Double,
        z: Double
    ) -> (x: Double, y: Double, z: Double) {
        (
            x: (x * 1.0478112) + (y * 0.0228866) + (z * -0.0501270),
            y: (x * 0.0295424) + (y * 0.9904844) + (z * -0.0170491),
            z: (x * -0.0092345) + (y * 0.0150436) + (z * 0.7521316)
        )
    }

    /**
    Bradford chromatic adaptation from D50 to D65 for XYZ.

    http://www.brucelindbloom.com/index.html?Eqn_ChromAdapt.html
    */
    fileprivate static func d50ToD65(
        x: Double,
        y: Double,
        z: Double
    ) -> (x: Double, y: Double, z: Double) {
        (
            x: (x * 0.9555766) + (y * -0.0230393) + (z * 0.0631636),
            y: (x * -0.0282895) + (y * 1.0099416) + (z * 0.0210077),
            z: (x * 0.0122982) + (y * -0.0204830) + (z * 1.3299098)
        )
    }

    /**
    Convert D50-adapted XYZ to Lab.
    */
    fileprivate static func xyzToLab(
        x: Double,
        y: Double,
        z: Double
    ) -> (lightness: Double, a: Double, b: Double) {
        // Assuming XYZ is relative to D50, convert to CIE Lab
        // from CIE standard, which now defines these as a rational fraction.
        // swiftlint:disable identifier_name
        let ε = 216.0 / 24_389.0 // 6^3 / 29^3
        let κ = 24_389.0 / 27.0 // 29^3 / 3^3
        // swiftlint:enable identifier_name

        // Compute XYZ scaled relative to reference white.
        let scaledX = x / 0.96422
        let scaledY = y / 1.0
        let scaledZ = z / 0.82521

        func computeF(_ value: Double) -> Double {
            value > ε ? cbrt(value) : (κ * value + 16) / 116
        }

        let fX = computeF(scaledX)
        let fY = computeF(scaledY)
        let fZ = computeF(scaledZ)

        return (
            lightness: (116 * fY) - 16,
            a: 500 * (fX - fY),
            b: 200 * (fY - fZ)
        )
    }

    /**
    Convert Lab to D50-adapted XYZ.
    */
    fileprivate static func labToXYZ(
        lightness: Double,
        a: Double,
        b: Double
    ) -> (x: Double, y: Double, z: Double) {
        // http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html

        // swiftlint:disable identifier_name
        let κ = 24_389.0 / 27.0 // 29^3 / 3^3
        let ε = 216.0 / 24_389.0 // 6^3 / 29^3
        // swiftlint:enable identifier_name

        // Compute f, starting with the luminance-related term.
        let fY = (lightness + 16) / 116
        let fX = a / 500 + fY
        let fZ = fY - b / 200

        let x = pow(fX, 3) > ε ? pow(fX, 3) : (116 * fX - 16) / κ
        let y = lightness > (κ * ε) ? pow((lightness + 16) / 116, 3) : lightness / κ
        let z = pow(fZ, 3) > ε ? pow(fZ, 3) : (116 * fZ - 16) / κ

        // Scaled by reference white.
        return (
            x: x * 0.96422,
            y: y * 1.0,
            z: z * 0.82521
        )
    }

    /**
    Convert Lab to LCH.

    The returned `hue` is in degrees (`0...360`).
    */
    fileprivate static func labToLCH(
        lightness: Double,
        a: Double,
        b: Double
    ) -> (lightness: Double, chroma: Double, hue: Double) {
        let hue = atan2(b, a) * 180 / .pi

        return (
            lightness: lightness,
            chroma: sqrt(pow(a, 2) + pow(b, 2)),
            hue: hue >= 0 ? hue : hue + 360
        )
    }

    /**
    Convert LCH to Lab.
    */
    fileprivate static func lchToLab(
        lightness: Double,
        chroma: Double,
        hue: Double
    ) -> (lightness: Double, a: Double, b: Double) {
        (
            lightness: lightness,
            a: chroma * cos(hue * .pi / 180),
            b: chroma * sin(hue * .pi / 180)
        )
    }
}

extension Colors.RGB {
    /**
    Convert sRGB to LCH.
    */
    func toLCH() -> Colors.LCH {
        // Algorithm: https://www.w3.org/TR/css-color-4/#rgb-to-lab

        // Convert from sRGB to linear-light sRGB (undo gamma encoding).
        let red = Colors.sRGBToLinearSRGB(colorComponent: red)
        let green = Colors.sRGBToLinearSRGB(colorComponent: green)
        let blue = Colors.sRGBToLinearSRGB(colorComponent: blue)

        // Convert from linear sRGB to D65-adapted XYZ.
        let xyz = Colors.linearSRGBToXYZ(red: red, green: green, blue: blue)

        // Convert from a D65 whitepoint (used by sRGB) to the D50 whitepoint used in Lab, with the Bradford transform.
        let xyz2 = Colors.d65ToD50(x: xyz.x, y: xyz.y, z: xyz.z)

        // Convert D50-adapted XYZ to Lab.
        let lab = Colors.xyzToLab(x: xyz2.x, y: xyz2.y, z: xyz2.z)

        // Convert Lab to LCH.
        let lch = Colors.labToLCH(lightness: lab.lightness, a: lab.a, b: lab.b)

        return .init(
            lightness: lch.lightness,
            chroma: lch.chroma,
            hue: lch.hue,
            alpha: alpha
        )
    }

    // Convert to NSColor/UIColor.
    func toXColor() -> NSColor { .init(self) }
}

extension Colors.LCH {
    /**
    Convert LCH to sRGB.
    */
    func toRGB() -> Colors.RGB {
        // Algorithm: https://www.w3.org/TR/css-color-4/#lab-to-rgb

        // Convert LCH to Lab.
        let lab = Colors.lchToLab(lightness: lightness, chroma: chroma, hue: hue)

        // Convert Lab to D50-adapted XYZ.
        let xyz = Colors.labToXYZ(lightness: lab.lightness, a: lab.a, b: lab.b)

        // Convert from a D50 whitepoint (used by Lab) to the D65 whitepoint used in sRGB, with the Bradford transform.
        let xyz2 = Colors.d50ToD65(x: xyz.x, y: xyz.y, z: xyz.z)

        // Convert from D65-adapted XYZ to linear-light sRGB.
        let rgb = Colors.xyzToLinearSRGB(x: xyz2.x, y: xyz2.y, z: xyz2.z)

        // Convert from linear-light sRGB to sRGB (do gamma encoding).
        let red = Colors.linearSRGBToSRGB(colorComponent: rgb.red)
        let green = Colors.linearSRGBToSRGB(colorComponent: rgb.green)
        let blue = Colors.linearSRGBToSRGB(colorComponent: rgb.blue)

        return .init(
            red: red,
            green: green,
            blue: blue,
            alpha: alpha
        )
    }
}

