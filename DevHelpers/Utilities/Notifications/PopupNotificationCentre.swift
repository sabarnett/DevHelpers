//
// File: PopupNotificationCentre.swift
// Package: MacTester
// Created by: Steven Barnett on 05/08/2023
// 
// Copyright © 2023 Steven Barnett. All rights reserved.
//

import Foundation
import AppKit

public enum PopupNotifications {
    case success
    case failure
    case saved
}

class PopupNotificationCentre {
  
    public static let shared = PopupNotificationCentre()
    
    init() { }
    
    /// Displays a popup notification window. The icon will be one of a pre-defined set, based off an SF Symbol
    ///
    /// - Parameters:
    ///   - popupType: The type of the popup which defines the icon to show
    ///   - title: The text of the message
    ///   - description: The accessibility description of the icon
    public func showPopup(_ popupType: PopupNotifications, title: String, description: String) {
        
        var imageName: String = ""
        
        switch popupType {
        case .success:
            imageName = "checkmark.circle"
        case .failure:
            imageName = "xmark.circle"
        case .saved:
            imageName = "folder"
        }
        
        let image = imageFromSFSymbol(systemName: imageName, description: description)!
        BezelNotification.show(messageText: title, icon: image)
    }
    
    public func showPopup(systemImage: String, title: String, description: String) {
        if let image = imageFromSFSymbol(systemName: systemImage, description: description) {
            BezelNotification.show(messageText: title, icon: image)
        }
    }
    
    private func imageFromSFSymbol(systemName: String, description: String) -> NSImage? {
        if let image = NSImage(systemSymbolName: systemName,
                               accessibilityDescription: description) {

            var config = NSImage.SymbolConfiguration(pointSize: 90, weight: .thin)
            config = config.applying(.init(paletteColors: [.systemGray, .systemGray]))
            
            return image.withSymbolConfiguration(config)
        }
        
        return nil
    }
}
