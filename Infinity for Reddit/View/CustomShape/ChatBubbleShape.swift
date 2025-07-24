//
//  ChatBubbleShape.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-22.
//

import SwiftUI

struct ChatBubbleShape: Shape {
    let isSentMessage: Bool
    let cornerRadius: CGFloat = 16
    var tailWidth: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        var path = Path()

        if !isSentMessage { // Received message (tail on left)
            let xOffset = tailWidth

            // Start from the bottom-left corner of the main bubble body
            path.move(to: CGPoint(x: xOffset + cornerRadius, y: height))

            // Bottom line (excluding tail area)
            path.addLine(to: CGPoint(x: width - cornerRadius, y: height))

            // Bottom-right curve
            path.addArc(center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(90),
                        endAngle: .degrees(0),
                        clockwise: true)

            // Right line
            path.addLine(to: CGPoint(x: width, y: cornerRadius))

            // Top-right curve
            path.addArc(center: CGPoint(x: width - cornerRadius, y: cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(0),
                        endAngle: .degrees(270),
                        clockwise: true)

            // Top line
            path.addLine(to: CGPoint(x: xOffset + cornerRadius, y: 0))

            // Top-left curve
            path.addArc(center: CGPoint(x: xOffset + cornerRadius, y: cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(270),
                        endAngle: .degrees(180),
                        clockwise: true)

            // Left line, connecting to the tail base
            path.addLine(to: CGPoint(x: xOffset, y: height - cornerRadius))

            path.addArc(center: CGPoint(x: xOffset + cornerRadius, y: height - cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(180),
                        endAngle: .degrees(90),
                        clockwise: true)
        } else { // Sent message (tail on right)
            let xOffset = 0.0 // The main bubble body starts at x=0

            // Start from the bottom-right corner of the main bubble body, just before the tail starts
            path.move(to: CGPoint(x: width - tailWidth - cornerRadius, y: height))

            // Bottom line
            path.addLine(to: CGPoint(x: cornerRadius, y: height))

            // Bottom-left curve
            path.addArc(center: CGPoint(x: cornerRadius, y: height - cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(90),
                        endAngle: .degrees(180),
                        clockwise: false)

            // Left line
            path.addLine(to: CGPoint(x: 0, y: cornerRadius))

            // Top-left curve
            path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(180),
                        endAngle: .degrees(270),
                        clockwise: false)

            // Top line
            path.addLine(to: CGPoint(x: width - tailWidth - cornerRadius, y: 0))

            // Top-right curve
            path.addArc(center: CGPoint(x: width - tailWidth - cornerRadius, y: cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(270),
                        endAngle: .degrees(0),
                        clockwise: false)

            // Right line, connecting to the tail base
            path.addLine(to: CGPoint(x: width - tailWidth, y: height - cornerRadius))

            path.addArc(center: CGPoint(x: width - tailWidth - cornerRadius, y: height - cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(0),
                        endAngle: .degrees(90),
                        clockwise: false)
        }
        return path
    }
}
