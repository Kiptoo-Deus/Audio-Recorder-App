//
//  Theme.swift
//  AudioRecorder
//
//  Created by Joel on 09/05/2025.
//

import Foundation
import SwiftUI

struct Theme {
    static let backgroundColor = Color.black
    static let secondaryBackground = Color.gray.opacity(0.2)
    static let accentColor = Color.green
    static let secondaryAccent = Color.purple
    static let textColor = Color.white
    static let secondaryTextColor = Color.gray
    
    static let primaryFont = Font.system(.title, design: .rounded, weight: .bold)
    static let secondaryFont = Font.system(.caption, design: .rounded, weight: .medium)
    
    static let gradient = LinearGradient(
        gradient: Gradient(colors: [accentColor, secondaryAccent]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let shadowRadius: CGFloat = 8
    static let cornerRadius: CGFloat = 12
}
