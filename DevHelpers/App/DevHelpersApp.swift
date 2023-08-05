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
        
        Window("About", id: "about") {
            AboutDevToolsView()
                .frame(minWidth: Constants.aboutWindowSize.width, maxWidth: Constants.aboutWindowSize.width + 200,
                       minHeight: Constants.aboutWindowSize.height, maxHeight: Constants.aboutWindowSize.height)
                .fixedSize()
        }.defaultSize(width: Constants.aboutWindowSize.width, height: Constants.aboutWindowSize.height)
            .defaultPosition(.center)
            .windowResizability(.contentSize)
        
        Window("Settings", id: "settings") {
            SettingsScreen()
                .frame(minWidth: Constants.settingsWindowSize.width)
        }.defaultSize(width: Constants.settingsWindowSize.width, height: Constants.settingsWindowSize.height)
            .defaultPosition(.center)
            .windowResizability(.contentSize)
    }
}

struct ToolsGroup: View {
    
    @Environment(\.openWindow) private var openWindow
    @StateObject private var appState: ColorWindowState = ColorWindowState.shared
    
    
    var body: some View {
        Group {
            Divider()
            Button("Lorem Ipsum") {
                openLoremIpsum()
                NSApp.activate(ignoringOtherApps: true)
            }
            
            Button("Color Wheel") {
                self.appState.openColorPicker()
                NSApp.activate(ignoringOtherApps: true)
            }
            
            Button("Image Generator") {
                openImageGenerator()
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    func openLoremIpsum() {
        let windowRef:NSWindow = NSWindow(
            contentRect: NSRect(x: 50,
                                y: 50,
                                width: Constants.loremIpsumWindowSize.width,
                                height: Constants.loremIpsumWindowSize.height),
            styleMask: [.titled,
                        .closable,
                        .miniaturizable,
                        .fullSizeContentView],        // .resizable
            backing: .buffered,
            defer: false)
        
        windowRef.contentView = NSHostingView(rootView: LoremIpsumView(myWindow: windowRef))
        windowRef.center()
        windowRef.setFrameAutosaveName("Lorem Ipsum")
        windowRef.standardWindowButton(.zoomButton)?.isHidden = true
        windowRef.standardWindowButton(.miniaturizeButton)?.isHidden = true
        windowRef.makeKeyAndOrderFront(nil)
    }

    func openImageGenerator() {
        let windowRef:NSWindow = NSWindow(
            contentRect: NSRect(x: 50,
                                y: 50,
                                width: Constants.imageGenWindowSize.width,
                                height: Constants.imageGenWindowSize.height),
            styleMask: [.titled,
                        .closable,
                        .miniaturizable,
                        .fullSizeContentView],        // .resizable
            backing: .buffered,
            defer: false)
        
        windowRef.contentView = NSHostingView(rootView: ImageGenerator(myWindow: windowRef))
        windowRef.center()
        windowRef.setFrameAutosaveName("Image Generator")
        windowRef.standardWindowButton(.zoomButton)?.isHidden = true
        windowRef.standardWindowButton(.miniaturizeButton)?.isHidden = true
        windowRef.makeKeyAndOrderFront(nil)
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
            Button("Settings") {
                openWindow(id: "settings")
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
