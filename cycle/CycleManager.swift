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
        
        func progress() -> (elapsedSeconds: Int, totalSeconds: Int) {
            switch self {
            case .Stopped:
                return (0, 0)
            case .Cycling(let totalSeconds, let elapsedSeconds), .Paused(let totalSeconds, let elapsedSeconds):
                return (elapsedSeconds, totalSeconds)
            }
        }
        
        mutating func restart(totalSeconds total: Int) {
            self = .Cycling(totalSeconds: total, elapsedSeconds: 0)
        }
        
        mutating func stop() {
            self = .Stopped
        }
        
        mutating func pause() {
            if case let .Cycling(total, elapsed) = self {
                self = .Paused(totalSeconds: total, elapsedSeconds: elapsed)
            }
        }
        
        mutating func resume() {
            if case let .Paused(total, elapsed) = self {
                self = .Cycling(totalSeconds: total, elapsedSeconds: elapsed)
            }
        }
        
        mutating func cyclingTo(seconds elapsed: Int) {
            if case let .Cycling(total, _) = self {
                self = .Cycling(totalSeconds: total, elapsedSeconds: elapsed)
            }
        }
    }
    
    lazy var statusItem: CycleStatusItem = { [unowned self] in
        $0.clickableDelegate = self
        return $0
    }(CycleStatusItem())
    
    var status: CycleStatus = .Stopped {
        didSet {
            updateStatusItem()
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
        updateStatusItem()
    }
    
    private func updateStatusItem() {
        let (elapsed, total) = status.progress()
        statusItem.update(totalSeconds: total, elapsedSeconds: elapsed)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}


extension CycleManager: CycleStatusItemClickable {
    func cycleStatusItemLeftMouseClicked(statusItem: CycleStatusItem) {
        // change to next status
        switch status {
        case .Stopped:
            status.restart(totalSeconds: 25 * 60)
        case .Cycling:
            status.pause()
        case .Paused:
            status.resume()
        }
        
        // if status is not changed to cycling, don't need to start timer
        guard case .Cycling = status else { return }
        
        let (alreadyElapsedSeconds, totalSeconds) = status.progress()
        let startDate = NSDate()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            // if self was released or status was changed outside, just stop the timer
            guard let `self` = self, case .Cycling = self.status else {
                timer.invalidate()
                return
            }
            
            // interval is added from two parts, time elapsed in this period and elapsed before this period
            let interval = Int(NSDate().timeIntervalSince(startDate as Date)) + alreadyElapsedSeconds
            
            // cycling stop detection
            guard interval <= totalSeconds else {
                timer.invalidate()
                self.status.stop()
                return
            }
            
            self.status.cyclingTo(seconds: interval)
        }
    }
    
    func cycleStatusItemRightMouseClicked(statusItem: CycleStatusItem) {
        statusItem.popUpMenu(menu: statusMenu)
    }
}
