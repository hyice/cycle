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
    
    var cycleInterval: Int {
        return Settings.cycleIntervalInSeconds
    }

    init() {
        updateStatusItem()
    }
    
    private func updateStatusItem() {
        let (elapsed, total) = status.progress()
        statusItem.update(totalSeconds: total, elapsedSeconds: elapsed)
    }
}


extension CycleManager: CycleStatusItemClickable {
    func cycleStatusItemLeftMouseClicked(statusItem: CycleStatusItem) {
        // change to next status
        switch status {
        case .Stopped:
            status.restart(totalSeconds: cycleInterval)
        case .Cycling:
            status.pause()
        case .Paused:
            status.resume()
        }
        
        // if status is not changed to cycling, don't need to start timer
        guard case .Cycling = status else { return }
        
        startCyclingTimer()
    }
    
    func cycleStatusItemRightMouseClicked(statusItem: CycleStatusItem) {
        statusItem.popUpMenu(menu: generatePopUpMenu())
    }
    
    // MARK: - Cycling Timer
    
    private func startCyclingTimer() {
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
                Notification.notify()
                return
            }
            
            self.status.cyclingTo(seconds: interval)
        }
    }
    
    // MARK: - Pop Up Menu
    
    private func generatePopUpMenu() -> NSMenu {
        let menu = NSMenu()
        
        var items = [NSMenuItem]()
        
        // status related operation
        switch status {
        case .Cycling:
            items.append(NSMenuItem(title: "Pause - Just Click The Icon", action: #selector(pause), keyEquivalent: ""))
            items.append(NSMenuItem(title: "Stop", action: #selector(stop), keyEquivalent: ""))
        case .Paused:
            items.append(NSMenuItem(title: "Resume - Just Click The Icon", action: #selector(resume), keyEquivalent: ""))
            items.append(NSMenuItem(title: "Restart", action: #selector(restart), keyEquivalent: ""))
        case .Stopped:
            items.append(NSMenuItem(title: "Start - Just Click The Icon", action: #selector(restart), keyEquivalent: ""))
        }
        
        items.append(NSMenuItem.separator())
        
        // cycle interval settings
        let cycleIntervalMenuItem = NSMenuItem(title: "Cycle Interval", action: nil, keyEquivalent: "")
        cycleIntervalMenuItem.submenu = generateCycleIntervalMenu()
        items.append(cycleIntervalMenuItem)
        
        // notification type settings
        let notificationTypeMenuItem = NSMenuItem(title: "Notification Type", action: nil, keyEquivalent: "")
        notificationTypeMenuItem.submenu = generateNotificationMenu()
        items.append(notificationTypeMenuItem)
        
        items.append(NSMenuItem.separator())
        
        // app level operation
        items.append(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: ""))
        
        for item in items {
            item.target = self
            menu.addItem(item)
        }
        
        return menu
    }
    
    private func generateCycleIntervalMenu() -> NSMenu {
        let menu = NSMenu()
        
        let currentInterval = Settings.cycleIntervalInSeconds / 60
        for i in stride(from: 5, to: 61, by: 5) {
            let menuItem = menu.addItem(withTitle: "\(i) minutes", action: #selector(cycleIntervalChanged(menuItem:)), keyEquivalent: "")
            menuItem.state = currentInterval == i ? .on : .off
            menuItem.target = self
        }
        
        return menu
    }
    
    private func generateNotificationMenu() -> NSMenu {
        let menu = NSMenu()
        
        let items = [
            ("Sound Only", NotificationType.SoundOnly),
            ("Alert", NotificationType.Alert),
            ("Alert And Sound", NotificationType.AlertAndSound),
            ("Notification Banner", NotificationType.NotificationBanner),
            ("Banner And Sound", NotificationType.NotificationBannerAndSound),
            ("Do Not Notify", NotificationType.DoNotNotify)
        ]
        
        for (title, type) in items {
            let item = menu.addItem(withTitle: title, action: #selector(notificationTypeChanged(menuItem:)), keyEquivalent: "")
            item.target = self
            item.representedObject = type
            
            item.state = type == Settings.notificationType ? .on : .off
        }
        
        return menu
    }
    
    @objc private func restart() {
        if case .Cycling = status {
            return
        }
        
        status.restart(totalSeconds: cycleInterval)
        startCyclingTimer()
    }
    
    @objc private func stop() {
        status.stop()
    }
    
    @objc private func pause() {
        status.pause()
    }
    
    @objc private func resume() {
        status.resume()
        startCyclingTimer()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc private func cycleIntervalChanged(menuItem: NSMenuItem) {
        // get interval from menu item's title, etc "20 minutes"
        if let minutes = Int(menuItem.title.split(separator: " ")[0]) {
            Settings.cycleIntervalInSeconds = minutes * 60
        }
    }
    
    @objc private func notificationTypeChanged(menuItem: NSMenuItem) {
        let notificationType = menuItem.representedObject as! NotificationType
        Settings.notificationType = notificationType
    }
}

