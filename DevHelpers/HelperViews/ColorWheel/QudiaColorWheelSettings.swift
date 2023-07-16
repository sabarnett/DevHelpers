//
// File: QudiaColorWheelSettings.swift
// Package: DevHelpers
// Created by: Steven Barnett on 16/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

public class QudiaColorWheelSettings: ObservableObject {
    public static let shared = QudiaColorWheelSettings()

    @Published var hsvColor = HSVColor(hue: 0.66, saturation: 1, brightness: 1)

    public var color: NSColor {
        get {
            hsvColor.uiColor
        }

        set {
            hsvColor = HSVColor(color: newValue) ?? .init(hue: 1, saturation: 1, brightness: 1)
        }
    }

    public var borderColor: NSColor {
        hsvColor.borderColor
    }

    public var isLightColor: Bool {
        hsvColor.isLightColor
    }
}
