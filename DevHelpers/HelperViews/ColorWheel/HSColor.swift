//
// File: HSColor.swift
// Package: DevHelpers
// Created by: Steven Barnett on 16/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import Foundation

struct HSColor: Equatable {
    let hue, saturation: CGFloat

    func with(brightness: CGFloat) -> HSVColor {
        HSVColor(hue: hue, saturation: saturation, brightness: brightness)
    }
}
