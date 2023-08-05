//
// File: LoremIpsumView.swift
// Package: DevHelpers
// Created by: Steven Barnett on 09/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

struct LoremIpsumView: View {
    
    let myWindow:NSWindow?
    @StateObject var vm: LoremIpsumModel = LoremIpsumModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 30) {
                VStack(alignment: .leading) {
                    Text("Generate what?")
                    Picker(selection: $vm.generateWhat, label: Text("   ")) {
                        Text("Word(s)").tag(LoremIpsumOutput.word)
                        Text("Sentence(s)").tag(LoremIpsumOutput.sentence)
                        Text("Paragraph(s)").tag(LoremIpsumOutput.paragraph)
                    }.pickerStyle(RadioGroupPickerStyle())
                }
                VStack(alignment: .leading) {
                    switch vm.generateWhat {
                    case .word:
                        LIWordOptions(vm: vm)
                    case .sentence:
                        LISentenceOptions(vm: vm)
                    case .paragraph:
                        LIParagraphOptions(vm: vm)
                    }
                }
                
                VStack(alignment: .leading) {
                    Defaults.Toggle("Classic first line", key: .useClassicFirstLine)
                    Defaults.Toggle("Add Quotes", key: .addQuotes)
                    Defaults.Toggle("Double Space", key: .doubleSpace)
                }
            }
            
            HStack {
                Button(action: { vm.generate() }, label: { Text("Generate") })
                Button(action: { vm.copyToClipboard() }, label: { Text("Copy to clipboard") })
            }
            Spacer()
            TextEditor(text: $vm.generatedText)
            HStack {
                Spacer()
                Button(
                    action: { myWindow?.close()},
                    label: { Text("Close")})
            }
        }.padding(20)
    }
}

struct LoremIpsumView_Previews: PreviewProvider {
    static var previews: some View {
        LoremIpsumView(myWindow: nil)
            .frame(width: 400, height: 350)
    }
}
