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
            HostingWindowFinder { window in
                window?.standardWindowButton(.zoomButton)?.isHidden = true
                window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
            }.frame(height: 0)
            HStack {
                Image(nsImage: SSApp.icon)
                    .resizable()
                    .frame(width: 160, height: 160)
                VStack(alignment: .leading, spacing: 15) {
                    Text("\(SSApp.name)").font(.largeTitle)
                    Text("Version \(SSApp.versionWithBuild)").font(.title2)
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
