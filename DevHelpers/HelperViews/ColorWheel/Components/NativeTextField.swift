//
// File: NativeTextField.swift
// Package: Color Picker
// Created by: Steven Barnett on 24/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI
import Carbon

struct NativeTextField: NSViewRepresentable {
    typealias NSViewType = InternalTextField

    @Binding var text: String
    var placeholder: String?
    var font: NSFont?
    var isFirstResponder = false
    @Binding var isFocused: Bool // Note: This is only readable.
    var isSingleLine = true

    final class InternalTextField: NSTextField {
        private var globalEventMonitor: GlobalEventMonitor?
        private var localEventMonitor: LocalEventMonitor?

        var parent: NativeTextField

        init(_ parent: NativeTextField) {
            self.parent = parent
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func becomeFirstResponder() -> Bool {
            parent.isFocused = true

            // This is required so that it correctly loses focus when the user clicks in the menu bar or uses the dropper from a keyboard shortcut.
            globalEventMonitor = GlobalEventMonitor(events: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                guard let self else {
                    return
                }

                unfocus()
            }.start()

            // Cannot be `.leftMouseUp` as the color wheel swallows it.
            localEventMonitor = LocalEventMonitor(events: [.leftMouseDown, .rightMouseDown, .keyDown]) { [weak self] event in
                guard let self else {
                    return event
                }

                if event.type == .keyDown {
                    if event.keyCode == kVK_Escape {
                        return nil
                    }

                    return event
                }

                let clickPoint = convert(event.locationInWindow, from: nil)
                let clickMargin = 3.0

                if !frame.insetBy(dx: -clickMargin, dy: -clickMargin).contains(clickPoint) {
                    unfocus()
                } else {
                    parent.isFocused = true
                }

                return event
            }.start()

            return super.becomeFirstResponder()
        }

        private func unfocus() {
            parent.isFocused = false
            blur()
        }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: NativeTextField
        var didBecomeFirstResponder = false

        init(_ autoFocusTextField: NativeTextField) {
            self.parent = autoFocusTextField
        }

        func controlTextDidChange(_ notification: Notification) {
            parent.text = (notification.object as? NSTextField)?.stringValue ?? ""
        }

        func controlTextDidEndEditing(_ notification: Notification) {
            guard let textField = notification.object as? NSTextField else {
                return
            }

            // The text field needs some time to transition into a new state.
            DispatchQueue.main.async { [self] in
                parent.isFocused = textField.currentEditor() == textField.window?.firstResponder
            }
        }

        // This ensures the app doesn't close when pressing `Esc` (closing is the default behavior for `NSPanel`.
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                parent.text = ""
                return true
            }

            return false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSViewType {
        let nsView = NSViewType(self)
        nsView.delegate = context.coordinator

        // This makes it scroll horizontally when text overflows instead of moving to a new line.
        if isSingleLine {
            nsView.cell?.usesSingleLineMode = true
            nsView.cell?.wraps = false
            nsView.cell?.isScrollable = true
            nsView.maximumNumberOfLines = 1
        }

        return nsView
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.bezelStyle = .roundedBezel
        nsView.stringValue = text
        nsView.placeholderString = placeholder

        if let font {
            nsView.font = font
        }

        // Note: Does not work without the dispatch call.
        DispatchQueue.main.async {
            if
                isFirstResponder,
                !context.coordinator.didBecomeFirstResponder,
                let window = nsView.window,
                window.firstResponder != nsView
            {
                window.makeFirstResponder(nsView)
                context.coordinator.didBecomeFirstResponder = true
            }
        }
    }
}

