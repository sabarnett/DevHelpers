//
// File: MetalGenerator.swift
// Package: MacTester
// Created by: Steven Barnett on 02/08/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import AppKit

struct RandomImageGenerator {
    
    public func generateRandomAbstractImage(size: CGSize) -> NSImage? {
        let pixelsWide = Int(size.width)
        let pixelsHigh = Int(size.height)
        let bitmapBytesPerRow = pixelsWide * 4
        
        // Create a bitmap for the final image
        let bufferLength = Int(size.width * size.height * 4)
        
        let bitmapData: CFMutableData = CFDataCreateMutable(nil, 0)
        CFDataSetLength(bitmapData, CFIndex(bufferLength))
        let bitmap = CFDataGetMutableBytePtr(bitmapData)
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: bitmap,
                                      width: pixelsWide,
                                      height: pixelsHigh,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bitmapBytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue)
        else { return nil }
        
        // Set a random background color
        let randomBackgroundColor = getRandomColor()
        context.setFillColor(randomBackgroundColor.cgColor)
        context.fill(CGRect(origin: CGPoint.zero, size: size))
        
        // Draw random shapes
        let numberOfShapes = Int.random(in: 3...10)
        for _ in 0..<numberOfShapes {
            let shapeType = Int.random(in: 0...1)
            switch shapeType {
            case 0:
                drawRandomCircle(in: context, size: size)
            case 1:
                drawRandomRectangle(in: context, size: size)
            default:
                break
            }
        }
        
        // Generate UIImage from the context
        if let image = context.makeImage() {
            return NSImage(cgImage: image, size: size)
        } else {
            return nil
        }
    }
    
    private func drawRandomCircle(in context: CGContext, size: CGSize) {
        let radius = CGFloat.random(in: 10...min(size.width, size.height)/2)
        let x = CGFloat.random(in: 0...(size.width - radius))
        let y = CGFloat.random(in: 0...(size.height - radius))
        let randomColor = getRandomColor()
        context.setFillColor(randomColor.cgColor)
        context.fillEllipse(in: CGRect(x: x, y: y, width: radius * 2, height: radius * 2))
    }
    
    private func drawRandomRectangle(in context: CGContext, size: CGSize) {
        let width = CGFloat.random(in: 10...size.width)
        let height = CGFloat.random(in: 10...size.height)
        let x = CGFloat.random(in: 0...(size.width - width))
        let y = CGFloat.random(in: 0...(size.height - height))
        let randomColor = getRandomColor()
        context.setFillColor(randomColor.cgColor)
        context.fill(CGRect(x: x, y: y, width: width, height: height))
    }
    
    private func getRandomColor() -> NSColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
