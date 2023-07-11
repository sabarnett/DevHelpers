//
// File: AboutDevToolsView.swift
// Package: DevHelpers
// Created by: Steven Barnett on 09/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//
        

import SwiftUI

struct AboutDevToolsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("aboutIcon")
                    .resizable()
                    .frame(width: 160, height: 160)
                VStack(alignment: .leading, spacing: 15) {
                    Text("DevTools").font(.largeTitle)
                    Text("Version 0.1").font(.title2)
                    Text("Copyright (c) Steve Barnett")
                }

                Spacer()
            }
        }.padding()
    }
}

struct AboutDevToolsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutDevToolsView()
            .frame(width: 440, height: 200)
    }
}
