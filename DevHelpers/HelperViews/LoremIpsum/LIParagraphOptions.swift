//
// File: LIParagraphOptions.swift
// Package: DevHelpers
// Created by: Steven Barnett on 11/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

struct LIParagraphOptions: View {
    
    @ObservedObject var vm: LoremIpsumModel
    
    var body: some View {
        Picker("Paragraph count", selection: $vm.paragraphCount, content: {
            ForEach(1...15, id:\.self) { count in
                Text("\(count)").tag(count)
            }
        }).pickerStyle(.automatic)
        Picker("Min sentences", selection: $vm.paragraphMinSentenceCount, content: {
            ForEach(1...10, id:\.self) { count in
                Text("\(count)").tag(count)
            }
        }).pickerStyle(.automatic)
        Picker("Max sentences", selection: $vm.paragraphMaxSentenceCount, content: {
            ForEach(3...15, id:\.self) { count in
                Text("\(count)").tag(count)
            }
        }).pickerStyle(.automatic)
        Picker("Sentence min words", selection: $vm.sentenceMinWords, content: {
            ForEach(1...10, id:\.self) { count in
                Text("\(count)").tag(count)
            }
        }).pickerStyle(.automatic)
        Picker("Sentence max words", selection: $vm.sentenceMaxWords, content: {
            ForEach(5...50, id:\.self) { count in
                Text("\(count)").tag(count)
            }
        }).pickerStyle(.automatic)
    }
}
