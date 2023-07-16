//
// File: HSVColor.swift
// Package: DevHelpers
// Created by: Steven Barnett on 16/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

struct HSVColor: Equatable {
    var hue, saturation, brightness: CGFloat

    var hsColor: HSColor { HSColor(hue: hue, saturation: saturation) }

    var uiColor: NSColor {
        NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    var isLightColor: Bool {
        brightness > 0.75 && (saturation < 0.5 || (hue >= 0.05 && hue <= 0.55))
    }

    var borderColor: NSColor { .init(white: isLightColor ? 0.1 : 1, alpha: 1) }

    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
    }

    init?(color: NSColor) {
        guard let cgColorSpace = CGColorSpace(name: CGColorSpace.displayP3) else {
            return nil
        }

        let converted = color.cgColor.converted(to: cgColorSpace, intent: .defaultIntent, options: nil)
        let components: [CGFloat] = converted?.components ?? []

        let red, green, blue: CGFloat

        if components.count >= 3 {
            red = components[0]
            green = components[1]
            blue = components[2]
        } else {
            red = components[0]
            green = components[0]
            blue = components[0]
        }

        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0

        let color = NSColor(red: red, green: green, blue: blue, alpha: 1)

        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
    }
}
