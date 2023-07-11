//
// File: LIWordOptions.swift
// Package: DevHelpers
// Created by: Steven Barnett on 11/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

struct LIWordOptions: View {
    
    @ObservedObject var vm: LoremIpsumModel
    
    var body: some View {
        Picker("Word count", selection: $vm.wordCount, content: {
            ForEach(1...20, id:\.self) { count in
                Text("\(count)").tag(count)
            }
        }).pickerStyle(.automatic)
    }
}
