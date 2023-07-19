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
    
    @State var brightness: CGFloat = 1
    @State var selectedColor: NSColor = NSColor.white.usingColorSpace(.sRGB)!

    var body: some View {
        VStack {
            ColorPickerUI(selectedColor: $selectedColor,
                          brightness: $brightness)
                .frame(width: 300, height: 300)

            VStack(alignment: .leading) {
                Text("Brightness")
                Slider(value: $brightness, in: 0...1, label: {})
            }

            VStack(alignment: .leading) {
                Text("Sample color")
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(nsColor: selectedColor))
                    .frame(height: 80)
            }

            VStack(alignment: .leading) {
                Text(getRGBColor())
                Text(getHSBColor())
            }
        }
        .padding()
    }

    func getRGBColor() -> String {
        let color = selectedColor.rgb
        let red = "\(intVal(color.red))"
        let green = "\(intVal(color.green))"
        let blue = "\(intVal(color.blue))"

        return "RGB(\(red), \(green), \(blue)), alpha(\(color.alpha))"
    }

    func getHSBColor() -> String {
        let color = selectedColor.hsb
        let hue = "\(intVal(color.hue, multiplier: 360))"
        let saturation = "\(intVal(color.saturation, multiplier: 100))"
        let brightness = "\(intVal(color.brightness, multiplier: 100))"

        return "HSB(\(hue), \(saturation), \(brightness), alpha(\(color.alpha))"
    }

    func intVal(_ value: CGFloat, multiplier: CGFloat = 256) -> Int {
        Int(value * multiplier)
    }
}

struct ColorWheelView_Previews: PreviewProvider {

    static var previews: some View {
        ColorSelectorView()
            .frame(width: 400, height: 600)
    }
}
