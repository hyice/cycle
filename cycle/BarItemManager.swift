//
//  BarItemManager.swift
//  cycle
//
//  Created by hyice on 2016/12/26.
//  Copyright © 2016年 hyice. All rights reserved.
//

import Cocoa

class BarItemManager: CycleTimerDelegate {
    
    let statusItem = {
        return NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength);
    }()

    lazy var statusMenu: NSMenu = {
        let menu = NSMenu()

        let item = NSMenuItem.init(title: "Quit", action: #selector(quit), keyEquivalent: "")
        item.target = self

        menu.addItem(item)
        return menu
    }()

    let cycleSeconds = 60 * 25

    let cycleTimer = CycleTimer.init()

    private var lastIconUpdateProgress: Float = 0

    // MARK: - Public -
    func setup() {
        if let statusButton = statusItem.button {
            statusButton.image = IconGenerator.statusBarIcon(withProgress: 0)
            statusButton.target = self
            statusButton.action = #selector(statusButtonClicked(sender:))

            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    // MARK: - Event -
    @objc private func statusButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        let isRightClick = event.type == NSEventType.rightMouseUp
        let isControlClick = event.modifierFlags.contains(NSEventModifierFlags.control)

        if isRightClick || isControlClick {
            checkAndShowMenu()
        } else {
            updateCycleTimerStatus()
        }
    }

    // MARK: Menu Action
    @objc private func quit() {
        NSApplication.shared().terminate(nil)
    }

    // MARK: - Delegate -
    // MARK: CycleTimerDelegate
    func cycleTimerFired(passed: Int, total: Int) {
        let progress = Float(passed) / Float(total)
        updateStatusBarIcon(withProgress: progress)
    }

    func cycleTimerDidStop(total: Int) {
        updateStatusBarIcon(withProgress: 0)
    }

    // MARK: - Private -
    private func updateCycleTimerStatus() {
        if cycleTimer.isStarted {
            cycleTimer.stop()
        } else {
            cycleTimer.start(withSeconds: cycleSeconds, delegate: self)
        }
    }

    private func checkAndShowMenu() {
        statusItem.popUpMenu(statusMenu)
    }

    private func updateStatusBarIcon(withProgress progress: Float) {
        if (progress - lastIconUpdateProgress) < 0.05
            && progress != 0
            && lastIconUpdateProgress != 0 {
            return
        }

        if let statusButton = statusItem.button {
            statusButton.image = IconGenerator.statusBarIcon(withProgress: progress)
            lastIconUpdateProgress = progress
        }
    }
}
