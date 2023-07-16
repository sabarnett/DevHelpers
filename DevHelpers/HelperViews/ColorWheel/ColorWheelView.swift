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
    
    @StateObject var colorWheelSettings = QudiaColorWheelSettings.shared
    @State var selectedColor: NSColor = NSColor(.blue)
    
    var body: some View {
        VStack{
            HStack(alignment: .top) {
                QudiaColorWheel(selectedColor: $selectedColor)
                    .frame(width: 300, height: 300)
                
                ColorPreview(color: $selectedColor)
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
        ColorSelectorView(selectedColor: selectedColor)
            .frame(width: 600, height: 300)
    }
}
