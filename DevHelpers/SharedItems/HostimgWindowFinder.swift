//
// File: HostimgWindowFinder.swift
// Package: DevHelpers
// Created by: Steven Barnett on 25/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//
    
import SwiftUI

struct HostingWindowFinder: NSViewRepresentable {
    var callback: (NSWindow?) -> ()

    func makeNSView(context: Self.Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
