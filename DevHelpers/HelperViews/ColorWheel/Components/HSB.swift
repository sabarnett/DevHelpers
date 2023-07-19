//
//  HSB.swift
//  ColorPicker
//
//  Created by Matsuoka Yoshiteru on 2018/10/19.
//  Copyright © 2018年 culumn. All rights reserved.
//

import Foundation
import SwiftUI

public struct HSB {
    public var hue: CGFloat
    public var saturation: CGFloat
    public var brightness: CGFloat
    public var alpha: CGFloat

    public init(
        hue: CGFloat,
        saturation: CGFloat,
        brightness: CGFloat,
        alpha: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }

    public var color: NSColor {
        return NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}
