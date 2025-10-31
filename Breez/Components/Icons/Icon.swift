//
//  Icon.swift
//  Breez
//
//  Created by Advaith Akella on 9/19/25.
//

import SwiftUI

struct Icon<Content: View>: View {
    let icon: Content
    var size: CGFloat = 40
    var backgroundColor: Color = Color(hex: "D0CAB6")
    var action: (() -> Void)? = nil

    var body: some View {
        let iconView = icon
            .frame(width: size * 0.6, height: size * 0.6)

        let content = ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            iconView
        }
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 4)

        if let action {
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                action()
            } label: {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Icon with action
        Icon(icon: Image(systemName: Ph.gear).foregroundColor(.primary), action: { print("Settings tapped") })
        
        // Icon without action
        Icon(icon: Image(systemName: Ph.heart).foregroundColor(.red))
        
        // Different sizes and colors
        Icon(icon: Image(systemName: Ph.camera).foregroundColor(.white), size: 60, backgroundColor: .blue)
        Icon(icon: Image(systemName: Ph.user).foregroundColor(.primary), size: 30, backgroundColor: .green)
    }
    .padding()
}