//
// File: SSApp.swift
// Package: Color Picker
// Created by: Steven Barnett on 24/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//
        

import SwiftUI

enum SSApp {
    static let idString = Bundle.main.bundleIdentifier!
    static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    static let versionWithBuild = "\(version) (\(build))"
    static let icon = NSApp.applicationIconImage!
    static let url = Bundle.main.bundleURL

    static var isDarkMode: Bool { NSApp?.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua }
}
