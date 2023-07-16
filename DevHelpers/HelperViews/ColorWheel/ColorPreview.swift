//
// File: ColorPreview.swift
// Package: DevHelpers
// Created by: Steven Barnett on 16/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

struct ColorPreview: View {
    
    @Binding var color: HSVColor
    
    var body: some View {
        Rectangle()
            .fill(Color(nsColor: color.uiColor))
            .frame(width: 200, height: 100)
    }
}
