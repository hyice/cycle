//
//  CycleTimer.swift
//  cycle
//
//  Created by hyice on 2016/12/26.
//  Copyright © 2016年 hyice. All rights reserved.
//

import Foundation

protocol CycleTimerDelegate {

    func cycleTimerFired(passed: Int, total: Int)
    func cycleTimerDidStop(total: Int)
}



class CycleTimer {

    private(set) var isStarted: Bool

    private var totalSeconds: Int
    private var startDate: NSDate?
    private var timer: Timer?
    private var delegate: CycleTimerDelegate?

    init() {
        totalSeconds = 0
        isStarted = false
    }

    deinit {
        timer?.invalidate()
        timer = nil
        delegate = nil
    }

    func start(withSeconds seconds: Int, delegate: CycleTimerDelegate) {
        totalSeconds = seconds
        self.delegate = delegate
        startDate = NSDate.init()
        isStarted = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in

            let now = NSDate.init()
            let interval = Int(now.timeIntervalSince(self.startDate as Date!))

            if interval > self.totalSeconds {
                self.stop()
                return
            }

            if let delegate = self.delegate {
                delegate.cycleTimerFired(passed: interval, total: self.totalSeconds)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        if let delegate = self.delegate {
            delegate.cycleTimerDidStop(total: totalSeconds)
        }

        delegate = nil
        startDate = nil
        totalSeconds = 0
        isStarted = false
    }
}
