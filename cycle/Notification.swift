//
//  Notification.swift
//  cycle
//
//  Created by hyice on 2018/2/27.
//  Copyright © 2018年 hyice. All rights reserved.
//

import Cocoa

class Notification: NSObject {
    static let notifyTitle = "Cycle Has Finished"
    static let notifyMessage = "You may take a 5 minutes' rest, then start a new cycle!"
    
    class func notify() {
        switch Settings.notificationType {
        case .DoNotNotify:
            return
        case .NotificationBanner:
            showNotificationBanner()
        case .NotificationBannerAndSound:
            playSound()
            showNotificationBanner()
        case .SoundOnly:
            playSound()
        case .Alert:
            showAlert()
        case .AlertAndSound:
            playSound()
            showAlert()
        }
    }
    
    private class func showNotificationBanner() {
        let notification = NSUserNotification()
        notification.title = notifyTitle
        notification.informativeText = notifyMessage
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private class func playSound() {
        let sound = NSSound(named: NSSound.Name("alert.wav"))
        sound?.play()
    }
    
    private class func showAlert() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = notifyTitle
        alert.informativeText = notifyMessage
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
