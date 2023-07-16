//
// File: ColorWheelView.swift
// Package: DevHelpers
// Created by: Steven Barnett on 09/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//
   
import Combine
import SwiftUI

struct ColorSelectorView: View {
    
    @StateObject var colorSettings = QudiaColorWheelSettings()
    
    var body: some View {
        VStack{
            HStack(alignment: .top) {
                QudiaColorWheel(settings: colorSettings)
                    .frame(width: 300, height: 300)
                
                ColorPreview(color: $colorSettings.hsvColor)
                    .padding(.top, 15)
            }.padding(12)
        }
    }
    
    func colorInHex() -> String {
        return "#001122"
    }
}

struct ColorWheelView_Previews: PreviewProvider {
    
    @State static var selectedColor: NSColor = NSColor(.blue)
    
    static var previews: some View {
        ColorSelectorView()
            .frame(width: 600, height: 300)
    }
}
