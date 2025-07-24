//
//  ChatBubbleWithTail.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-22.
//

import SwiftUI

struct ChatBubbleWithTailShape: Shape {
    let isSentMessage: Bool
    let cornerRadius: CGFloat = 16 // A common corner radius for chat bubbles
    var tailWidth: CGFloat = 8 // Width of the tail base

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        // Define the common bubble rectangle without the tail
        let bubbleRect: CGRect
        if isSentMessage {
            // Sent message: tail on the right
            bubbleRect = CGRect(x: 0, y: 0, width: width - tailWidth, height: height)
        } else {
            // Received message: tail on the left
            bubbleRect = CGRect(x: tailWidth, y: 0, width: width - tailWidth, height: height)
        }

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
            path.addLine(to: CGPoint(x: xOffset, y: height - cornerRadius / 2 * 3))

            // Tail
            // Control points for the tail should smoothly connect to the main bubble body.
            // The tail starts from the bottom-left edge.
            // Point 1: Bottom-left corner of the bubble body (before the tail starts)
            path.addCurve(to: CGPoint(x: 0, y: height), // Point of the tail
                          control1: CGPoint(x: xOffset, y: height - cornerRadius / 3 * 2), // Adjust control point for a smooth outward curve
                          control2: CGPoint(x: xOffset / 5 * 4, y: height)) // Adjust control point for the tail tip

            path.addLine(to: CGPoint(x: xOffset + cornerRadius, y: height))
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
            path.addLine(to: CGPoint(x: width - tailWidth, y: height - cornerRadius / 2 * 3))

            // Tail
            // Control points for the tail should smoothly connect to the main bubble body.
            // The tail starts from the bottom-right edge.
            // Point 1: Bottom-right corner of the bubble body (before the tail starts)
            path.addCurve(to: CGPoint(x: width, y: height), // Point of the tail
                          control1: CGPoint(x: width - tailWidth, y: height - cornerRadius / 3 * 2), // Adjust control point for a smooth outward curve
                          control2: CGPoint(x: width - tailWidth / 5 * 4, y: height)) // Adjust control point for the tail tip
            
            path.addLine(to: CGPoint(x: width - tailWidth - cornerRadius, y: height))
        }
        return path
    }
}
