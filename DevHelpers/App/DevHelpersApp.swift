//
// File: DevHelpersApp.swift
// Package: DevHelpers
// Created by: Steven Barnett on 09/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

@main
struct DevHelpersApp: App {
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        MenuBarExtra("DevTools", systemImage: "wrench.and.screwdriver.fill") {
            Group {
                AdminGroup()
                ToolsGroup()
                QuitGroup()
            }
        }.menuBarExtraStyle(.menu)
        
        Window("LoremIpsum", id: "loremipsum") {
            LoremIpsumView()
        }.defaultSize(width: 500, height: 630)
            .defaultPosition(.center)
        
        Window("ColorWheel", id: "colorwheel") {
            ColorWheelView()
        }.defaultSize(width: 400, height: 200)
            .defaultPosition(.center)
        
        Window("About", id: "about") {
            AboutDevToolsView()
                .frame(minWidth: 440, maxWidth: 440, minHeight: 200, maxHeight: 200)
                .fixedSize()
        }.defaultSize(width: 440, height: 200)
            .defaultPosition(.center)
            .windowResizability(.contentSize)
    }
}

struct ToolsGroup: View {
  
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    Group {
      Divider()
        Button("Lorem Ipsum") {
            openWindow(id: "loremipsum")
            NSApp.activate(ignoringOtherApps: true)
        }

        Button("Color Wheel") {
            openWindow(id: "colorwheel")
            NSApp.activate(ignoringOtherApps: true)
        }
    }
  }
}

struct AdminGroup: View {
  
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    Group {
        Button("About DevTools") {
            openWindow(id: "about")
            NSApp.activate(ignoringOtherApps: true)
        }

        Divider()
    }
  }
}

struct QuitGroup: View {

  var body: some View {
    Group {
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }.keyboardShortcut("q")
    }
  }
}
