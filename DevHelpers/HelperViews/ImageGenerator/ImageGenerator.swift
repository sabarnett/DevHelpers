//
// File: ImageGenerator.swift
// Package: MacTester
// Created by: Steven Barnett on 27/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

struct ImageGenerator: View {
    
    let myWindow:NSWindow?
    @StateObject private var vm: ImageGeneratorViewModel = ImageGeneratorViewModel()
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                // Options down th eleft hand side
                VStack(alignment: .leading, spacing: 15){
                    Text("Image attributes")
                    imageSizeAttributes()
                    
                    Picker("", selection: $vm.generationParameterType) {
                        Text("Manual").tag(ImageParametersType.manual)
                        Text("Random").tag(ImageParametersType.random)
                    }.pickerStyle(.segmented)
                        .padding(.horizontal, 30)
                    
                    switch vm.generationParameterType {
                    case .manual:
                        backgroundColorAttributes()
                        borderColorAttributes()

                    case .random:
                        Button(action: { vm.renderImage() },
                               label: { Text("New Image")})
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // Preview on the right hand side
                imagePreview()
            }
            // Buttons along the bottom
            actionButtons()
                .padding(.top, 10)
            
        }
        .padding()
        .onAppear {
            vm.renderImage()
        }
    }
    
    func imageSizeAttributes() -> some View {
        HStack {
            Text("Width: ")
            TextField("Image width", text: $vm.imageWidth)
                .frame(width: 60)
            Text("Height: ")
            TextField("Image height", text: $vm.imageHeight)
                .frame(width: 60)
        }
    }
    
    func backgroundColorAttributes() -> some View {
        HStack {
            Toggle("Use background color", isOn: $vm.useBackgroundColor)
            ColorPicker(selection: $vm.backgroundColor, label: {})
        }
    }
    
    func borderColorAttributes() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Toggle("Use border color", isOn: $vm.useBorderColor)
                ColorPicker(selection: $vm.borderColor, label: {})
            }
            if vm.useBorderColor {
                HStack {
                    Text("Line Width:").padding(.leading, 20)
                    TextField("line width", text: $vm.lineWidth).frame(width: 40)
                    if vm.lineWidthInvalid {
                        Text("Valid values: 1-30")
                            .font(.body)
                            .foregroundColor(Color(.systemRed))
                    }
                }
            }
        }
    }
    
    func imagePreview() -> some View {
        VStack {
            Text("Preview")
            Image(nsImage: vm.previewImage)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            Spacer()
        }
    }
    
    func actionButtons() -> some View {
        HStack {
            Spacer()
            
            Button(action: {
                vm.copyToPasteboard()
            }, label: { Text("Copy")})
            
            Button(action: {
                if let exportName = showSavePanel() {
                    vm.saveToFile(toURL: exportName)
                }
            }, label: { Text("Save")})

            Divider().frame(height: 20)
            
            Button(action: {
                vm.reset()
            }, label: { Text("Reset")})
            
            Button(action: {
                myWindow?.close()
            }, label: { Text("Close")})
        }
    }
    
    func showSavePanel() -> URL? {
        // Targets -> Signing & Capabilities -> File Access - set to read/write
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save your image"
        savePanel.message = "Choose a folder and a name to store your image."
        savePanel.nameFieldLabel = "File name:"
        savePanel.nameFieldStringValue = vm.exportFileName
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
}

struct ImageGenerator_Previews: PreviewProvider {
    static var previews: some View {
        ImageGenerator(myWindow: nil)
            .frame(width: Constants.imageGenWindowSize.width,
                   height: Constants.imageGenWindowSize.height)
    }
}
