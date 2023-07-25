//
// File: NSView+Extension.swift
// Package: Color Picker
// Created by: Steven Barnett on 24/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI

extension NSView {
    func focus() {
        window?.makeFirstResponder(self)
    }

    func blur() {
        window?.makeFirstResponder(nil)
    }
}

extension NSView {
    func constrainEdges(to view: NSView) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func constrainEdgesToSuperview() {
        guard let superview else {
            assertionFailure("There is no superview for this view")
            return
        }

        constrainEdges(to: superview)
    }
}
