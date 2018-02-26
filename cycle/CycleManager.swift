//
//  CycleManager.swift
//  cycle
//
//  Created by hyice on 2016/12/26.
//  Copyright © 2016年 hyice. All rights reserved.
//

import Cocoa


class CycleManager {
    enum CycleStatus {
        case Stopped
        case Cycling(totalSeconds: Int, elapsedSeconds: Int)
        case Paused(totalSeconds: Int, elapsedSeconds: Int)
    }
    
    let statusItem: CycleStatusItem
    
    var status: CycleStatus = .Stopped {
        didSet {
            let elapsed: Int!
            let total: Int!
            
            switch status {
            case .Stopped:
                elapsed = 0
                total = 0
            case .Cycling(let totalSeconds, let elapsedSeconds), .Paused(let totalSeconds, let elapsedSeconds):
                elapsed = elapsedSeconds
                total = totalSeconds
            }
            
            statusItem.update(totalSeconds: total, elapsedSeconds: elapsed)
        }
    }

    lazy var statusMenu: NSMenu = { [unowned self] in
        let menu = NSMenu()

        let item = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "")
        item.target = self

        menu.addItem(item)
        return menu
    }()

    init() {
        statusItem = CycleStatusItem()
        statusItem.clickableDelegate = self
        statusItem.update(totalSeconds: 0, elapsedSeconds: 0)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}


extension CycleManager: CycleStatusItemClickable {
    func cycleStatusItemLeftMouseClicked(statusItem: CycleStatusItem) {
        let totalSeconds = 25 * 60
        let elapsedSeconds: Int!
        
        switch self.status {
        case .Stopped:
            elapsedSeconds = 0
            self.status = .Cycling(totalSeconds: totalSeconds, elapsedSeconds: 0)
        case let .Cycling(total, elapsed):
            self.status = .Paused(totalSeconds: total, elapsedSeconds: elapsed)
            return
        case let .Paused(total, elapsed):
            self.status = .Cycling(totalSeconds: total, elapsedSeconds: elapsed)
            elapsedSeconds = elapsed
        }
        
        let startDate = NSDate(timeIntervalSinceNow: TimeInterval(-elapsedSeconds))
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            guard let `self` = self, case .Cycling = self.status else {
                timer.invalidate()
                return
            }
            
            let interval = Int(NSDate().timeIntervalSince(startDate as Date))
            
            if interval > totalSeconds {
                timer.invalidate()
                self.status = .Stopped
                return
            }
            
            self.status = .Cycling(totalSeconds: totalSeconds, elapsedSeconds: interval)
        }
    }
    
    func cycleStatusItemRightMouseClicked(statusItem: CycleStatusItem) {
        statusItem.popUpMenu(menu: statusMenu)
    }
}
