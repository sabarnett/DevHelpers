//
// File: Defaults+Extension.swift
// Package: Color Picker
// Created by: Steven Barnett on 25/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//
        
import SwiftUI

extension Defaults.Keys {
    static let recentlyPickedColors = Key<[NSColor]>("recentlyPickedColors", default: [])

    // Settings
    static let showColorSamplerOnOpen = Key<Bool>("showColorSamplerOnOpen", default: false)
    static let menuBarItemClickAction = Key<MenuBarItemClickAction>("menuBarItemClickAction", default: .showMenu)
    static let preferredColorFormat = Key<ColorFormat>("preferredColorFormat", default: .hex)
    static let stayOnTop = Key<Bool>("stayOnTop", default: true)
    static let uppercaseHexColor = Key<Bool>("uppercaseHexColor", default: false)
    static let hashPrefixInHexColor = Key<Bool>("hashPrefixInHexColor", default: false)
    static let legacyColorSyntax = Key<Bool>("legacyColorSyntax", default: false)
    static let shownColorFormats = Key<Set<ColorFormat>>("shownColorFormats", default: [.hex, .hsl, .rgb, .lch])
    static let largerText = Key<Bool>("largerText", default: false)
    static let copyColorAfterPicking = Key<Bool>("copyColorAfterPicking", default: false)
    static let showAccessibilityColorName = Key<Bool>("showAccessibilityColorName", default: false)
}
