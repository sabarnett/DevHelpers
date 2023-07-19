//
// File: ColorPickerUI.swift
// Package: ExampleUI
// Created by: Steven Barnett on 18/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import Foundation
import SwiftUI

struct ColorPickerUI: NSViewRepresentable {

    typealias NSViewType = ColorPickerView

    @Binding var selectedColor: NSColor
    @Binding var brightness: CGFloat

    func makeCoordinator() -> ColorPickerViewCoordinator {
        WriteLog.info("makeCoordinator Called")

        return ColorPickerViewCoordinator(selectedColor: $selectedColor,
                                          brightness: $brightness)
    }

    func makeNSView(context: Context) -> ColorPickerView {
        WriteLog.info("makeNSView Started")
        let picker = ColorPickerView()
        picker.isIndicatorHidden = false
        picker.indicatorDiameter = 20
        picker.delegate = context.coordinator

        picker.updateSelectedColor(self.selectedColor)
        picker.updateBrightness(self.brightness)
        WriteLog.info("makeNSView Completed")
        return picker
    }

    func updateNSView(_ uiView: ColorPickerView, context: Context) {
        WriteLog.info("updateNSView Started")
        if uiView.selectedColor != self.selectedColor {
            uiView.updateSelectedColor(self.selectedColor)
        }
        if uiView.selectedColor.brightnessComponent != self.brightness {
            uiView.updateBrightness(self.brightness)
        }
        WriteLog.info("updateNSView Completed")
    }
}

class ColorPickerViewCoordinator: NSObject, ColorPickerViewDelegate {

    @Binding var selectedColor: NSColor
    @Binding var brightness: CGFloat

    init(selectedColor: Binding<NSColor>, brightness: Binding<CGFloat>) {
        _selectedColor = selectedColor
        _brightness = brightness
    }

    func colorPickerWillBeginDragging(_ colorPicker: ColorPickerView) { }

    func colorPickerDidSelectColor(_ colorPicker: ColorPickerView) {
        DispatchQueue.main.async {
            self.selectedColor = colorPicker.selectedColor
        }
    }

    func colorPickerDidEndDagging(_ colorPicker: ColorPickerView) { }
}
