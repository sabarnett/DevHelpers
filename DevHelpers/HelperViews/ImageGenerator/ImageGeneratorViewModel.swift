//
// File: ImageGeneratorViewModel.swift
// Package: MacTester
// Created by: Steven Barnett on 27/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI
import UserNotifications

enum ImageParametersType {
    case manual
    case random
}

class ImageGeneratorViewModel: ObservableObject {

    @Published var imageWidth: String = "640" {
        didSet {
            let filtered = imageWidth.filter { $0.isNumber }
            
            if imageWidth != filtered {
                imageWidth = filtered
            }
            renderImage()
        }
    }
    
    @Published var imageHeight: String = "480" {
        didSet {
            let filtered = imageHeight.filter { $0.isNumber }
            
            if imageHeight != filtered {
                imageHeight = filtered
            }
            renderImage()
        }
    }
    
    @Published var lineWidthInvalid: Bool = false
    @Published var lineWidth: String = "2" {
        didSet {
            lineWidthInvalid = false
            if lineWidth.isEmpty { return }
            
            let filtered = lineWidth.filter { $0.isNumber }
            
            if lineWidth != filtered {
                lineWidth = filtered
            }
            
            guard let width = Int(lineWidth),
                  width >= 1,
                  width <= 30 else {
                lineWidthInvalid = true
                return
            }
            renderImage()
        }
    }

    @Published var useBackgroundColor: Bool = true { didSet { renderImage() }}
    @Published var useBorderColor: Bool = true { didSet { renderImage() }}
    
    @Published var backgroundColor: CGColor = .white { didSet { renderImage() }}
    @Published var borderColor: CGColor = .black { didSet { renderImage() }}
    
    @Published var previewImage: NSImage = NSImage.init(size: NSSize(width: 200, height: 200))
    
    @Published var generationParameterType: ImageParametersType = .manual { didSet { renderImage() }}
    
    var exportFileName: String {
        "\(imageWidth)x\(imageHeight).png"
    }
    
    private var drawWidth: Int {
        get {
            return imageWidth.isEmpty ? 10 : Int(imageWidth)!
        }
    }
    
    private var drawHeight: Int {
        get {
            return imageHeight.isEmpty ? 10 : Int(imageHeight)!
        }
    }
    
    private var drawLineWidth: CGFloat {
        get {
            return lineWidth.isEmpty ? 1 : CGFloat(Int(lineWidth)!)
        }
    }
    
    private let notify = PopupNotificationCentre.shared
    
    func reset() {
        imageHeight = "480"
        imageWidth = "640"
        
        useBackgroundColor = true
        backgroundColor = CGColor.white
        
        useBorderColor = true
        borderColor = CGColor.black
        lineWidth = "2"
        
        previewImage = NSImage.init(size: NSSize(width: 200, height: 200))
        
        renderImage()
        
        notify.showPopup(systemImage: "arrowshape.turn.up.backward.circle", title: "Reset...", description: "Parameters reset")
    }
    
    func renderImage() {
        let imageSize = CGSize(width: drawWidth, height: drawHeight)
        guard drawWidth > 30, drawHeight > 30 else { return }
        
        switch generationParameterType {
        case .manual:
            let cgImage = createDummyImage(size: imageSize)
            previewImage = NSImage(cgImage: cgImage, size: imageSize)

        case .random:
            //// Example usage:
            if let randomImage = RandomImageGenerator().generateRandomAbstractImage(size: imageSize) {
                previewImage = randomImage
            } else {
                print("Failed to generate random abstract image.")
            }
        }
    }
    
    func saveToFile(toURL url: URL) {

        guard let data = previewImage.tiffRepresentation,
              let rep = NSBitmapImageRep(data: data),
              let imgData = rep.representation(using: .png, properties: [.compressionFactor : NSNumber(floatLiteral: 1.0)]) else {

            notify.showPopup(.failure, title: "Save Failed...", description: "Unable to extract image")

            Swift.print("\(self) Error Function '\(#function)' Line: \(#line) No tiff rep found for image writing to \(url)")
            return
        }

        do {
            try imgData.write(to: url)
        }catch let error {
            notify.showPopup(.failure, title: "Save failed...", description: "Save to file failed")
            Swift.print("\(self) Error Function '\(#function)' Line: \(#line) \(error.localizedDescription)")
        }
        
        notify.showPopup(.saved, title: "Saved...", description: "Image saved to file")
    }
    
    func copyToPasteboard() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([previewImage])
        
        // Make an image from an SF Symbol
        notify.showPopup(.success, title: "Copied...", description: "Copied to the pasteboard")
    }
        
    private func createDummyImage(size: CGSize) -> CGImage {
        
        let pixelsWide = Int(size.width)
        let pixelsHigh = Int(size.height)
        let bitmapBytesPerRow = pixelsWide * 4

        // Create a bitmap of the Hue Saturation colorWheel
        let bufferLength = Int(size.width * size.height * 4)

        let bitmapData: CFMutableData = CFDataCreateMutable(nil, 0)
        CFDataSetLength(bitmapData, CFIndex(bufferLength))
        let bitmap = CFDataGetMutableBytePtr(bitmapData)
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let cgContext = CGContext(data: bitmap,
                                width: pixelsWide,
                                height: pixelsHigh,
                                bitsPerComponent: 8,
                                bytesPerRow: bitmapBytesPerRow,
                                space: colorSpace,
                                  bitmapInfo: bitmapInfo.rawValue)
        
        let context = cgContext!
        let rectangle = CGRect(x: 0,
                               y: 0,
                               width: size.width,
                               height: size.height)

        context.saveGState()
        if useBackgroundColor {
            context.setFillColor(backgroundColor)
            context.addRect(rectangle)
            context.drawPath(using: .fill)
        }
        
        if useBorderColor {
            let rectangle2 = CGRect(x: 1,
                                   y: 1,
                                   width: size.width - 2,
                                   height: size.height - 2)
            
            context.setStrokeColor(borderColor)
            context.setLineWidth(drawLineWidth)
            context.addRect(rectangle2)
            context.drawPath(using: .stroke)
        }

        let image = context.makeImage()
        context.restoreGState()

        return image!
    }
}
