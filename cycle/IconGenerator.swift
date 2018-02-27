//
//  IconGenerator.swift
//  cycle
//
//  Created by hyice on 2016/12/26.
//  Copyright © 2016年 hyice. All rights reserved.
//

import Cocoa

struct IconGenerator {
    
    static func statusBarIcon(withProgress progress: Double, eyesOpened: Bool = true) -> NSImage {
        let thickness = NSStatusBar.system.thickness
        let size = NSSize(width: thickness, height: thickness)
        let image = NSImage(size: size)
        
        let totalProgress = 330.0 / 360

        image.lockFocus()

        // backgroundPath
        drawCyclePath(progress: totalProgress, color: .lightGray)

        // progressPath
        drawCyclePath(progress: progress * totalProgress, color: .black)

        if eyesOpened {
            drawCenterPoint(color: .lightGray)
        }

        image.unlockFocus()
        
        return image
    }

    private static func drawCyclePath(progress: Double, color: NSColor) {
        let thickness = NSStatusBar.system.thickness
        let radius = thickness * 0.618 / 2.0
        let center = NSMakePoint(thickness/2.0, thickness/2.0)

        let path = NSBezierPath()
        path.lineWidth = radius

        path.appendArc(withCenter: center,
                       radius: radius,
                       startAngle: 0 ,
                       endAngle: CGFloat(360.0 * progress),
                       clockwise: false)
        
        color.setStroke()
        path.stroke()
    }

    private static func drawCenterPoint(color: NSColor) {
        let thickness = NSStatusBar.system.thickness
        let center = NSMakePoint(thickness/2.0, thickness/2.0)

        let path = NSBezierPath()
        let size = CGFloat(2.0)
        path.appendOval(in: NSMakeRect(center.x - size/2.0, center.y - size/2.0, size, size))

        color.setStroke()
        path.stroke()
    }

}
