//
// File: StringStuff+Extension.swift
// Package: Color Picker
// Created by: Steven Barnett on 24/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

extension String {
    var toNSAttributedString: NSAttributedString { NSAttributedString(string: self) }
}

extension String {
    func copyToPasteboard() {
        NSPasteboard.general.with {
            $0.setString(self, forType: .string)
        }
    }
}
