//
//  CycleStatusItem.swift
//  cycle
//
//  Created by hyice on 2018/2/26.
//  Copyright © 2018年 hyice. All rights reserved.
//

import Cocoa


extension CycleStatusItem {
    /*
     * Convenience methods for updating status item appearance.
     */
    func update(totalSeconds total: Int, elapsedSeconds elapsed: Int) {
        let progress = total == 0 || elapsed == total ? 0 : Float(elapsed) / Float(total)
        
        icon = IconGenerator.statusBarIcon(withProgress: progress)
        text = timeString(fromSeconds: total - elapsed)
    }
    
    private func timeString(fromSeconds seconds: Int) -> String {
        let second = String(format:"%.02d", seconds % 60)
        let minute = String(format:"%.02d", seconds / 60 % 60)
        let hour = seconds / 60 / 60 % 60
        
        if hour != 0 {
            return "\(hour):\(minute):\(second)"
        } else {
            return "\(minute):\(second)"
        }
    }
}

extension CycleStatusItem {
    /*
     * Pop up menu for item.
     */
    
    func popUpMenu(menu: NSMenu) {
        self.statusItem.popUpMenu(menu)
    }
}


protocol CycleStatusItemClickable: class {
    func cycleStatusItemLeftMouseClicked(statusItem: CycleStatusItem)
    func cycleStatusItemRightMouseClicked(statusItem: CycleStatusItem)
}


class CycleStatusItem {
    var icon: NSImage? {
        get {
            return statusItem.button?.image
        }
        set {
            statusItem.button?.image = newValue
        }
    }
    
    var text: String {
        get {
            return statusItem.button?.title ?? ""
        }
        set {
            statusItem.button?.title = newValue
        }
    }
    
    weak var clickableDelegate: CycleStatusItemClickable?
    
    private lazy var statusItem: NSStatusItem = { [unowned self] in
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.imagePosition = .imageLeft
            button.font = NSFont(name: "Courier New", size: 16)
            
            button.target = self
            button.action = #selector(statusItemClicked(sender:))
            button.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.rightMouseUp])
        }
        return item
    }()
    
    @objc private func statusItemClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        let isRightClick = event.type == NSEvent.EventType.rightMouseUp
        let isControlClick = event.modifierFlags.contains(NSEvent.ModifierFlags.control)
        
        if isRightClick || isControlClick {
            clickableDelegate?.cycleStatusItemRightMouseClicked(statusItem: self)
        } else {
            clickableDelegate?.cycleStatusItemLeftMouseClicked(statusItem: self)
        }
    }
}
