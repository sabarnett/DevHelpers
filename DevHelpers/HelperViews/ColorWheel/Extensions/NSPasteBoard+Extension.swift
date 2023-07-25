//
// File: NSPasteBoard+Extension.swift
// Package: Color Picker
// Created by: Steven Barnett on 24/07/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import SwiftUI
import Combine

extension NSPasteboard {
    /**
    Returns a publisher that emits when the pasteboard changes.
    */
    var simplePublisher: AnyPublisher<Void, Never> {
        Timer.publish(every: 0.2, tolerance: 0.1, on: .main, in: .common)
            .autoconnect()
            .prepend([]) // We want the publisher to also emit immediately when someone subscribes.
            .compactMap { [weak self] _ in
                self?.changeCount
            }
            .removeDuplicates()
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

extension NSPasteboard {
    /**
    An observable object that publishes updates when the given pasteboard changes.
    */
    final class SimpleObservable: ObservableObject {
        private var cancellables = Set<AnyCancellable>()
        private var pasteboardPublisherCancellable: AnyCancellable?
        private let onlyWhenAppIsActive: Bool

        @Published var pasteboard: NSPasteboard {
            didSet {
                if onlyWhenAppIsActive, !NSApp.isActive {
                    stop()
                    return
                }

                start()
            }
        }

        /**
        It starts listening to changes automatically, as long as `onlyWhenAppIsActive` is not `true`.

        - Parameters:
            - pasteboard: The pasteboard to listen to changes.
            - onlyWhenAppIsActive: Only listen to changes while the app is active.
        */
        init(_ pasteboard: NSPasteboard, onlyWhileAppIsActive: Bool = false) {
            self.pasteboard = pasteboard
            self.onlyWhenAppIsActive = onlyWhileAppIsActive

            if onlyWhileAppIsActive {
                SSPublishers.appIsActive
                    .sink { [weak self] isActive in
                        guard let self else {
                            return
                        }

                        if isActive {
                            start()
                        } else {
                            stop()
                        }
                    }
                    .store(in: &cancellables)

                if NSApp?.isActive == true {
                    start()
                }
            } else {
                start()
            }
        }

        @discardableResult
        func start() -> Self {
            pasteboardPublisherCancellable = pasteboard.simplePublisher.sink { [weak self] in
                self?.objectWillChange.send()
            }

            return self
        }

        @discardableResult
        func stop() -> Self {
            pasteboardPublisherCancellable = nil
            return self
        }
    }
}

extension NSPasteboard {
    func with(_ callback: (NSPasteboard) -> Void) {
        prepareForNewContents()
        callback(self)
    }
}
