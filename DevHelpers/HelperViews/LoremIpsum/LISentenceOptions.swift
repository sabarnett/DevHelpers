//
// File: LISentenceOptions.swift
// Package: DevHelpers
// Created by: Steven Barnett on 11/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

struct LISentenceOptions: View {
    @ObservedObject var vm: LoremIpsumModel
    
    var body: some View {
        Picker("Sentence count", selection: $vm.sentenceCount, content: {
            ForEach(1...10, id:\.self) { count in
                Text("\(count)").tag(count)
            }
        }).pickerStyle(.automatic)
        Picker("Minimum words", selection: $vm.sentenceMinWords, content: {
            ForEach(5...10, id:\.self) { count in
                Text("\(count)").tag(count)
            }
        }).pickerStyle(.automatic)
        Picker("Maximum words", selection: $vm.sentenceMaxWords, content: {
            ForEach(5...50, id:\.self) { count in
                Text("\(count)").tag(count)
            }
        }).pickerStyle(.automatic)
    }
}
